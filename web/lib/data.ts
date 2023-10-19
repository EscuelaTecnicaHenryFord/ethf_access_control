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
    enrollment: string
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
    enrollment: string
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

export async function getGlobalData() {
    if (Date.now() > 60000 + lastFetch) {
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
        getRange('Eventos!A2:E'),
    ])

    const guests = guestsData.values!.map(([first_name, surname, dni_cuil, invited_by, event_id, timestamp]) => ({
        first_name,
        surname,
        dni_cuil,
        invited_by,
        event_id,
        timestamp,
    }) as Guest)

    const staffs = staffsData.values?.map(([username, name, email, dni_cuil]) => ({
        username: username.toLowerCase().trim(),
        name,
        email,
        dni_cuil,
    }) as Staff) ?? []

    const students = studentsData.values?.map(([enrollment, course, name, dni_cuil, mother_name, father_name, mother_email, father_email, mother_dni_cuil, father_dni_cuil]) => ({
        enrollment: enrollment.toLowerCase().trim(),
        course,
        name,
        dni_cuil,
        mother_name,
        father_name,
        mother_email,
        father_email,
        mother_dni_cuil,
        father_dni_cuil,
    }) as Student) ?? []

    const formerStudents = formerStudentsData.values?.map(([enrollment, year, name, dni_cuil, email]) => ({
        enrollment: enrollment.toLowerCase().trim(),
        year,
        name,
        dni_cuil,
        email,
    }) as FormerStudent) ?? []

    const events = eventsData.values?.map(([name, id, description, start_date, end_date]) => ({
        name,
        id,
        description,
        start_date,
        end_date,
    }) as Event) ?? []

    const studentsParents: StudentParent[] = []

    for (const student of students) {
        if (student.mother_name.trim() && (student.mother_dni_cuil || student.mother_email.trim())) {
            studentsParents.push({
                name: student.mother_name,
                dni_cuil: student.mother_dni_cuil,
                invited_by: student.enrollment,
                email: student.mother_email,
            })
        }

        if (student.father_name.trim() && (student.mother_dni_cuil || student.mother_email.trim())) {
            studentsParents.push({
                name: student.father_name,
                dni_cuil: student.father_dni_cuil,
                invited_by: student.enrollment,
                email: student.father_email,
            })
        }
    }

    let allIdentitys = [
        ...guests.map(identityFromGuest),
        ...staffs.map(identityFromStaff),
        ...students.map(identityFromStudent),
        ...formerStudents.map(identityFromFormerStudent),
        ...studentsParents.map(identityFromStudentParent),
    ]

    const identities_by_dni = new Map<number, Identity[]>()
    const identitie_by_cuil = new Map<string, Identity>()
    const identities_by_username = new Map<string, Identity>()

    for (const identity of allIdentitys) {
        if (identity.dni) {
            const identities = identities_by_dni.get(identity.dni) || []
            identities.push(identity)
            identities_by_dni.set(identity.dni, identities)
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

            const ids = identities_by_dni.get(cuild.cuildata!.dni) ?? []

            for (const id of ids) {
                if (id.cuil_prefix == cuild.cuildata!.prefix && id.cuil_sufix == cuild.cuildata!.sufix && id.dni === cuild.cuildata?.dni) return id
            }

            for (const id of ids) {
                if ((!id.cuil_prefix || id.cuil_prefix == 0 || !id.cuil_sufix || id.cuil_sufix == 0) && id.dni === cuild.cuildata?.dni) return id
            }
        }

        if (cuild.valid && !cuild.cuildata!.full) {
            const id = identities_by_dni.get(cuild.cuildata!.dni)?.[0]

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
        id: student.enrollment,
        name: student.name,
        username: student.enrollment,
        dni: cuildata?.dni,
        cuil_prefix: cuildata?.prefix,
        cuil_sufix: cuildata?.sufix,
        type: 'student',
    }
}

function identityFromFormerStudent(formerStudent: FormerStudent): Identity {
    const { cuildata } = cuildFromIdSafe(formerStudent.dni_cuil)

    if (!cuildata && !formerStudent.enrollment) {
        throw new Error(`Former student ${formerStudent.name} has no enrollment nor CUIL`)
    }

    return {
        ref: [formerStudent],
        id: formerStudent.enrollment,
        name: formerStudent.name,
        username: formerStudent.enrollment,
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

function cuildFromIdSafe(id: string) {
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

function cuilFromId(id: string): Cuil {
    id = id.trim()

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