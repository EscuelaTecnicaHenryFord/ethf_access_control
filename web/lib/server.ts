import { TRPCError, inferRouterInputs, inferRouterOutputs } from "@trpc/server";
import { enrolmentRegex, studentDataSchema, parentDataVerificationSchema, verificationDataSchema, addGuestSchema } from "./client";
import { Student, cuildFromIdSafe, fetchAll, getGlobalData } from "./data";
import { publicProcedure, router } from "./trpc";
import z from "zod";
import { appendTo, clearRows } from "./spreadsheet";

export const appRouter = router({
    verifyStudentData: publicProcedure.input(studentDataSchema).query(async ({ ctx, input }) => {
        const data = await getGlobalData();

        const studentIdentity = data.getIdentity(input.studentDNI);

        if (!studentIdentity) {
            throw new TRPCError({
                code: "NOT_FOUND",
            })
        }

        const student = studentIdentity?.ref[0] as Student | undefined

        const enrolmentInput = input.studentEnrolment.match(enrolmentRegex)?.[2];
        const studentEnrolment = student?.enrolment.match(enrolmentRegex)?.[2];

        if (enrolmentInput !== studentEnrolment) {
            throw new TRPCError({
                code: "NOT_FOUND",
            })
        }

        if (!student) {
            throw new TRPCError({
                code: "NOT_FOUND",
            })
        }

        const dni = cuildFromIdSafe(student.dni_cuil).cuildata?.dni?.toString() || ''

        const result = {
            father_name: student.father_name || null,
            mother_name: student.mother_name || null,
            student_name: student.name,
            student_dni: dni,
            student_enrolment: studentEnrolment,
            father_dni: null,
            mother_dni: null,
        }

        if (ctx.server) {
            const cuildataFather = cuildFromIdSafe(student.father_dni_cuil?.replaceAll('.', ''))
            const cuildataMother = cuildFromIdSafe(student.mother_dni_cuil?.replaceAll('.', ''))

            return {
                ...result,
                father_dni: cuildataFather.cuildata?.dni || null,
                mother_dni: cuildataMother.cuildata?.dni || null,
            }
        }

        return result
    }),
    verifyStudentDataWithParents: publicProcedure.input(z.object({
        ...studentDataSchema.shape,
        ...parentDataVerificationSchema.shape,
    })).mutation(async ({ ctx, input }) => {
        const studentData = await appRouter.createCaller({ server: true }).verifyStudentData(input)
        const dniMother: number | null = cuildFromIdSafe(input.motherDNI?.replaceAll('.', '') || '').cuildata?.dni || null
        const dniFather: number | null = cuildFromIdSafe(input.fatherDNI?.replaceAll('.', '') || '').cuildata?.dni || null

        if (!dniFather && !dniMother) {
            throw new TRPCError({
                code: "BAD_REQUEST",
            })
        }

        if (!dniFather && !studentData.mother_name) {
            throw new TRPCError({
                code: "BAD_REQUEST",
            })
        }


        if (!dniMother && !studentData.father_name) {
            throw new TRPCError({
                code: "BAD_REQUEST",
            })
        }

        if (studentData.father_name && dniFather) {
            if (studentData.father_dni && studentData.father_dni !== dniFather) {
                console.log("dni padre no coinciden", studentData.father_dni, dniFather)
                throw new TRPCError({
                    code: "NOT_FOUND",
                })
            } else if (!studentData.father_dni) {
                // Registar dni padre
            }
        }


        if (studentData.mother_dni && dniMother) {
            if (studentData.mother_dni && studentData.mother_dni !== dniMother) {
                console.log("dni madre no coinciden", studentData.mother_dni, dniMother)
                throw new TRPCError({
                    code: "NOT_FOUND",
                })
            } else if (!studentData.mother_dni) {
                // Registar dni madre
            }
        }

        const student_dni: string = studentData.student_dni
        const student_enrolment: string = studentData.student_enrolment!

        const dni_father: number | null = (dniFather as any)
        const dni_mother: number | null = (dniMother as any)

        return {
            student_dni,
            student_enrolment,
            dni_father,
            dni_mother,
        }
    }),
    addGuest: publicProcedure.input(z.object({
        verificationData: verificationDataSchema,
        guestData: addGuestSchema,
    })).mutation(async ({ ctx, input }) => {
        console.log(input)
        await appRouter.createCaller({ server: true }).verifyStudentDataWithParents({
            fatherDNI: input.verificationData.dni_father?.toString() || '',
            motherDNI: input.verificationData.dni_mother?.toString() || '',
            studentDNI: input.verificationData.student_dni,
            studentEnrolment: input.verificationData.student_enrolment,
        })

        const inputCuilData = cuildFromIdSafe(input.guestData.dni.replaceAll('.', ''))

        if(!inputCuilData.cuildata?.dni){
            throw new TRPCError({
                code: "BAD_REQUEST",
                message: "Ingrese un DNI válido"
            })
        }

        const guests = await appRouter.createCaller({ server: true }).getGuests({
            verificationData: input.verificationData,
        })


        if (guests.find(guest => {
            const guestCuilData = cuildFromIdSafe(guest.dni_cuil.replaceAll('.', ''))

            return guestCuilData.cuildata?.dni === inputCuilData.cuildata?.dni && `HF${input.verificationData.student_enrolment}` === guest.invited_by
        })) {
            throw new TRPCError({
                code: "BAD_REQUEST",
                message: "Ya se ha registrado un invitado con este DNI"
            })
        }

        await appendTo('Invitados!A2:F', [[
            input.guestData.first_name,
            input.guestData.last_name,
            inputCuilData.cuildata!.dni,
            "HF" + input.verificationData.student_enrolment,
            'expo_2023',
            new Date,
        ]])

        await fetchAll()
    }),

    getGuests: publicProcedure.input(z.object({
        verificationData: verificationDataSchema,
    })).query(async ({ ctx, input }) => {

        await appRouter.createCaller({ server: true }).verifyStudentDataWithParents({
            fatherDNI: input.verificationData.dni_father?.toString() || '',
            motherDNI: input.verificationData.dni_mother?.toString() || '',
            studentDNI: input.verificationData.student_dni,
            studentEnrolment: input.verificationData.student_enrolment,
        })

        const data = await getGlobalData();

        const guests = data.guests.filter(guest => {
            return guest.invited_by === "HF" + input.verificationData.student_enrolment
        })

        return guests
    }),

    removeGuest: publicProcedure.input(z.object({
        verificationData: verificationDataSchema,
        guestData: z.object({
            dni: z.string(),
        })
    })).mutation(async ({ ctx, input }) => {
        await appRouter.createCaller({ server: true }).verifyStudentDataWithParents({
            fatherDNI: input.verificationData.dni_father?.toString() || '',
            motherDNI: input.verificationData.dni_mother?.toString() || '',
            studentDNI: input.verificationData.student_dni,
            studentEnrolment: input.verificationData.student_enrolment,
        })


        await clearRows('Invitados', async (row) => {
            const [firstName, lastName, dni, invitedBy, event, date] = row

            const cuildata = cuildFromIdSafe(dni.replaceAll('.', '')).cuildata

            if (cuildata?.dni === parseInt(input.guestData.dni) && event === 'expo_2023' && invitedBy === "HF" + input.verificationData.student_enrolment) {
                return true
            }

            return false
        })

        await fetchAll()
    }),
});

// Export only the type of a router!
// This prevents us from importing server code on the client.
export type AppRouter = typeof appRouter;

// Export router input and output types
export type AppRouterInputs = inferRouterInputs<AppRouter>;
export type AppRouterOutputs = inferRouterOutputs<AppRouter>;