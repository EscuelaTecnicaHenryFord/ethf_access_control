import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';
import type { AppRouter, AppRouterOutputs } from "./server";
import z from 'zod';

export const client = createTRPCProxyClient<AppRouter>({
    links: [
        httpBatchLink({
            url: 'http://localhost:3000/api/trpc',
            // You can pass any HTTP headers you wish here
            async headers() {
                return {};
            },
        }),
    ],
});

const dniErrorOptions = {
    message: "Ingrese un DNI válido",
}

const enrolmentErrorOptions = {
    message: "Ingrese una matrícula válida",
}

export const enrolmentRegex = /^(hf|HF|Hf|hF)?(\d{4})$/
export const dniRegex = /^\d{1,2}\.?\d{3}\.?\d{3}$/

export const studentDataSchema = z.object({
    studentDNI: z.string().regex(dniRegex, dniErrorOptions),
    studentEnrolment: z.string().regex(enrolmentRegex, enrolmentErrorOptions),
})

export const parentDataVerificationSchema = z.object({
    fatherDNI: z.string().regex(dniRegex, dniErrorOptions).or(z.literal('')),
    motherDNI: z.string().regex(dniRegex, dniErrorOptions).or(z.literal('')),
})

export const verificationDataSchema = z.object({
    student_dni: z.string().regex(dniRegex),
    student_enrolment: z.string().regex(enrolmentRegex),
    dni_father: z.number().nullable().optional(),
    dni_mother: z.number().nullable().optional(),
})

export const addGuestSchema = z.object({
    dni: z.string().regex(dniRegex),
    first_name: z.string().min(3).max(100),
    last_name: z.string().min(3).max(100),
    is_under_age: z.boolean(),
    requires_assistant: z.boolean(),
})