import { getRange } from "./spreadsheet";
import * as EmailValidator from 'email-validator';
import dayjs from 'dayjs'

export type Guest = {
    first_name: string
    surname: string
    dni_cuil: string
    invited_by: string
    event_id: string
    timestamp?: Date | string
}

export type Staff = {
    username: string
    name: string
    email: string
    dni_cuil: string
}

// Matrícula	Curso	Nombre	DNI o CUIL	Nombre Madre	Nombre Padre	E-mail Padre	E-mail Madre	DNI o CUIL Madre	DNI o CUIL Padre
export type Student = {
    enrolment: string
    course: string
    name: string
    dni_cuil: string
    mother_name: string
    father_name: string
    mother_email: string
    father_email: string
    mother_dni_cuil: string
    father_dni_cuil: string
}

// Matricula	Año de egreso	Nombre Completo	DNI	E-mail
export type FormerStudent = {
    enrolment: string
    year: string
    name: string
    dni_cuil: string
    email: string
}


export type StudentParent = {
    name: string
    dni_cuil: string
    email?: string
    invited_by: string
}

export type Event = {
    name: string
    id: string
    former_students_invited: boolean
    description: string
    start_date: string
    end_date: string
}


// final String id;
// final String name;
// final String dni;
// final String? cuilPrefixSufix;
// final PersonType type;

export type Identity = {
    ref: (Guest | Staff | Student | FormerStudent | StudentParent)[]
    id: string
    name: string
    username?: string
    dni?: number
    invited_by?: string
    cuil_prefix?: number
    cuil_sufix?: number
    type: 'student' | 'former-student' | 'staff' | 'parent' | 'former_student' | 'guest'
    events?: string[]
}

export type GlobalData = Awaited<ReturnType<typeof fetchAll>>

export let globalData: GlobalData | null = null

let lastFetch = 0

function getCacheTime() {
    if (process.env.NODE_ENV == 'production') {
        return 60000
    }

    return 10000
}

export async function getGlobalData() {
    if (Date.now() > getCacheTime() + lastFetch) {
        await fetchAll()
        lastFetch = Date.now()
    }

    if (globalData === null) {
        globalData = await fetchAll()
    }

    return globalData
}

export async function fetchAll() {
    const [
        guestsData,
        staffsData,
        studentsData,
        formerStudentsData,
        eventsData,
    ] = await Promise.all([
        getRange('Invitados!A2:F'),
        getRange('Docentes!A2:D'),
        getRange('Alumnos!A2:J'),
        getRange('Ex-Alumnos!A2:E'),
        getRange('Eventos!A2:F'),
    ])

    const guests = guestsData.values!.map(([first_name, surname, dni_cuil, invited_by, event_id, timestamp]) => ({
        first_name,
        surname,
        dni_cuil,
        invited_by,
        event_id,
        timestamp,
    }) as Guest)

    const staffs = (staffsData.values?.map(([username, name, email, dni_cuil]) => ({
        username: username?.toLowerCase().trim(),
        name,
        email,
        dni_cuil,
    }) as Staff) ?? []).filter(student => student.username)

    const students = (studentsData.values?.map(([enrolment, course, name, dni_cuil, mother_name, father_name, mother_email, father_email, mother_dni_cuil, father_dni_cuil]) => ({
        enrolment: enrolment?.toLowerCase().trim(),
        course,
        name,
        dni_cuil,
        mother_name,
        father_name,
        mother_email,
        father_email,
        mother_dni_cuil,
        father_dni_cuil,
    }) as Student) ?? []).filter(student => student.enrolment)

    const formerStudents = (formerStudentsData.values?.map(([year, enrolment, name, dni_cuil, email]) => ({
        enrolment: enrolment?.toLowerCase().trim(),
        year,
        name,
        dni_cuil,
        email,
    }) as FormerStudent) ?? []).filter(student => student.enrolment || student.dni_cuil)

    const events = (eventsData.values?.map(([name, id, description, former_students_invited, start_date, end_date]) => {
        former_students_invited = former_students_invited?.toLowerCase().trim()

        return ({
            name,
            id,
            description,
            former_students_invited: former_students_invited === 'si' || former_students_invited === 'sí' || former_students_invited === 'x' || former_students_invited === 'y' || former_students_invited === 'yes' || former_students_invited === 'true',
            start_date,
            end_date,
        }) as Event
    }) ?? []).filter(event => event.id && event.name)

    const studentsParents: StudentParent[] = []

    for (const student of students) {
        if (student.mother_name.trim() && (student.mother_dni_cuil || student.mother_email.trim())) {
            studentsParents.push({
                name: student.mother_name,
                dni_cuil: student.mother_dni_cuil,
                invited_by: student.enrolment,
                email: student.mother_email,
            })
        }

        if (student.father_name.trim() && (student.mother_dni_cuil || student.mother_email.trim())) {
            studentsParents.push({
                name: student.father_name,
                dni_cuil: student.father_dni_cuil,
                invited_by: student.enrolment,
                email: student.father_email,
            })
        }
    }

    let allIdentitys = [
        ...guests.map((d) => {
            try {
                return identityFromGuest(d)
            } catch (error) {
                return null
            }
        }).filter((d): d is Identity => d !== null),
        ...staffs.map(identityFromStaff),
        ...students.map(identityFromStudent),
        ...formerStudents.map((s) => {
            try {
                return identityFromFormerStudent(s)
            } catch (error) {
                return null
            }
        }).filter((d): d is Identity => d !== null),
        ...studentsParents.map((s) => {
            try {
                return identityFromStudentParent(s)
            } catch (error) {
                return null
            }
        }).filter((d): d is Identity => d !== null),
    ]

    const identities_by_dni = new Map<number, Identity>()
    const identitie_by_cuil = new Map<string, Identity>()
    const identities_by_username = new Map<string, Identity>()

    for (const identity of allIdentitys) {
        if (identity.dni) {
            const duplicatedIdentity = identities_by_dni.get(identity.dni)

            for (const key in duplicatedIdentity) {
                if (!(key in identity)) {
                    (identity as any)[key] = (duplicatedIdentity as any)[key]
                }
            }

            identities_by_dni.set(identity.dni, identity)
        }

        if (identity.cuil_prefix && identity.cuil_sufix) {
            const cuil = cuilFromId(`${identity.cuil_prefix}-${identity.dni}-${identity.cuil_sufix}`)
            identitie_by_cuil.set(cuil.toString(), identity)
        }

        if (identity.username && (identity.type == 'staff' || identity.type == 'student')) {
            identities_by_username.set(identity.username, identity)
        }

        if (identity.type == 'guest') {
            const prevIdentity = getIdentity(identity.id)
            const eventsSet = new Set<string>(prevIdentity?.events ?? [])
            const refSet = new Set(prevIdentity?.ref ?? [])

            identity.events?.forEach(event => eventsSet.add(event))
            identity.ref?.forEach(ref => refSet.add(ref))

            identity.events = Array.from(eventsSet)
            identity.ref = Array.from(refSet)
            if (prevIdentity) prevIdentity.events = identity.events
            if (prevIdentity) prevIdentity.ref = identity.ref
        }
    }

    const deduplicate = new Set<string>()
    allIdentitys.reverse()
    allIdentitys = allIdentitys.filter(identity => {
        if (identity.type == 'guest') {
            if (deduplicate.has(identity.id)) return false
            deduplicate.add(identity.id)
        }

        return true
    })
    allIdentitys.reverse()

    function getIdentity(dni_cuil_username: string): Identity | undefined {
        if (!dni_cuil_username) return undefined

        const cuild = cuildFromIdSafe(dni_cuil_username)

        if (cuild.valid && cuild.cuildata!.full) {
            const id = identitie_by_cuil.get(cuild.cuildata!.toString())

            if (id) return id

            const id_by_dni = identities_by_dni.get(cuild.cuildata!.dni)

            if (id_by_dni && id_by_dni.cuil_prefix == cuild.cuildata!.prefix && id_by_dni.cuil_sufix == cuild.cuildata!.sufix && id_by_dni.dni === cuild.cuildata?.dni) return id


            if (id_by_dni && (!id_by_dni.cuil_prefix || id_by_dni.cuil_prefix == 0 || !id_by_dni.cuil_sufix || id_by_dni.cuil_sufix == 0) && id_by_dni.dni === cuild.cuildata?.dni) return id
        }

        if (cuild.valid && !cuild.cuildata!.full) {
            const id = identities_by_dni.get(cuild.cuildata!.dni)

            if (id) return id
        }

        const id = identities_by_username.get(dni_cuil_username)

        if (id) return id
    }

    function getCurrentEvents() {
        const now = new Date()

        return events.filter(event => {
            const start = dayjs(event.start_date).startOf('day').toDate()
            const end = dayjs(event.end_date).add(1, 'day').startOf('day').toDate()

            return start <= now && end >= now
        })
    }

    const data = {
        guests,
        staffs,
        students,
        formerStudents,
        studentsParents,
        events,
        getCurrentEvents,
        identities: allIdentitys,
        getIdentity,
    }

    globalData = data

    return data
}

function identityFromStudent(student: Student): Identity {
    const { cuildata } = cuildFromIdSafe(student.dni_cuil)

    return {
        ref: [student],
        id: student.enrolment,
        name: student.name,
        username: student.enrolment,
        dni: cuildata?.dni,
        cuil_prefix: cuildata?.prefix,
        cuil_sufix: cuildata?.sufix,
        type: 'student',
    }
}

function identityFromFormerStudent(formerStudent: FormerStudent): Identity {
    const { cuildata } = cuildFromIdSafe(formerStudent.dni_cuil)

    if (!cuildata && !formerStudent.enrolment) {
        const le_ci = formerStudent.dni_cuil.toLowerCase().trim()

        if (le_ci.startsWith('l.e.') || le_ci.startsWith('c.i.')) {
            return {
                ref: [formerStudent],
                id: le_ci.toUpperCase(),
                name: formerStudent.name,
                username: le_ci.toUpperCase(),
                dni: undefined,
                cuil_prefix: undefined,
                cuil_sufix: undefined,
                type: 'former-student',
            }
        }

        throw new Error(`Former student ${formerStudent.name} has no enrolment nor CUIL`)
    }

    return {
        ref: [formerStudent],
        id: formerStudent.enrolment ?? cuildata?.dni,
        name: formerStudent.name,
        username: formerStudent.enrolment,
        dni: cuildata?.dni,
        cuil_prefix: cuildata?.prefix,
        cuil_sufix: cuildata?.sufix,
        type: 'former-student',
    }
}

function identityFromStaff(staff: Staff): Identity {
    const { cuildata } = cuildFromIdSafe(staff.dni_cuil)

    return {
        ref: [staff],
        id: staff.username,
        name: staff.name,
        username: staff.username,
        cuil_prefix: cuildata?.prefix,
        cuil_sufix: cuildata?.sufix,
        dni: cuildata?.dni,
        type: 'staff',
    }
}

function identityFromGuest(guest: Guest): Identity {
    return {
        ref: [guest],
        id: guest.dni_cuil,
        name: `${guest.first_name} ${guest.surname}`,
        dni: cuilFromId(guest.dni_cuil).dni,
        invited_by: guest.invited_by,
        cuil_prefix: cuilFromId(guest.dni_cuil).prefix,
        cuil_sufix: cuilFromId(guest.dni_cuil).sufix,
        events: guest.event_id ? [guest.event_id] : [],
        type: 'guest',
    }
}

function identityFromStudentParent(parent: StudentParent): Identity {
    const { cuildata } = cuildFromIdSafe(parent.dni_cuil)

    const isValidEmail = parent.email ? EmailValidator.validate(parent.email) : false

    if (!cuildata && !isValidEmail) {
        throw new Error(`Student parent ${parent.name} has no CUIL nor email`)
    }

    return {
        ref: [parent],
        id: parent.dni_cuil,
        username: parent.email,
        name: parent.name,
        dni: cuildata?.dni,
        invited_by: parent.invited_by,
        cuil_prefix: cuildata?.prefix,
        cuil_sufix: cuildata?.sufix,
        type: 'parent',
    }
}


type Cuil = {
    prefix: number
    sufix: number
    dni: number

    full: boolean

    toString(): string
}

export function cuildFromIdSafe(id: string) {
    try {
        return {
            cuildata: cuilFromId(id),
            valid: true,
            error: null,
        }
    } catch (e) {
        return {
            cuildata: null,
            valid: false,
            error: (e as Error).message,
        }
    }
}

export function cuilFromId(id: string): Cuil {
    id = id.trim().replaceAll('.', '').replaceAll('-', '')



    let prefixNum = 0
    let dniNum = 0
    let sufixNum = 0

    let prefix = ''
    let dni = ''
    let sufix = ''

    // If length == 7, 8 or 9, it's a DNI 0-DNI-00
    // If length > 9, it's a CUIL PREFIX-CUIL-SUFIX
    if (id.search('-') != -1) {
        // Cuil
        [prefix, dni, sufix] = id.split('-')
    } else if (id.length == 7 || id.length == 8 || id.length == 9) {
        // DNI
        prefix = '0'
        dni = id
        sufix = '00'
    } else if (id.length > 9) {
        prefix = id.substring(0, 2)
        dni = id.substring(2, id.length - 1)
        sufix = id.substring(id.length - 1)
    } else {
        throw new Error(`Invalid id: ${id}`)
    }


    prefixNum = parseInt(prefix)
    if (!Number.isInteger(prefixNum)) {
        throw new Error(`Invalid prefix: ${prefix}`)
    }

    if (prefixNum < 0 || prefixNum > 99) {
        throw new Error(`Invalid prefix: ${prefix}`)
    }

    dniNum = parseInt(dni)
    if (!Number.isInteger(dniNum)) {
        throw new Error(`Invalid dni: ${dni}`)
    }

    if (dniNum < 0 || dniNum > 999_999_999) {
        throw new Error(`Invalid dni: ${dni}`)
    }

    sufixNum = parseInt(sufix)
    if (!Number.isInteger(sufixNum)) {
        throw new Error(`Invalid sufix: ${sufix}`)
    }

    return {
        prefix: prefixNum,
        dni: dniNum,
        sufix: sufixNum,

        full: sufixNum != 0 && prefixNum != 0,

        toString() {
            return `${padWithLeadingZeros(prefixNum, 2)}-${(padWithLeadingZeros(dniNum, 8))}-${padWithLeadingZeros(sufixNum, 1)}`
        },
    }
}

function padWithLeadingZeros(num: number, totalLength: number) {
    return String(num).padStart(totalLength, '0');
}