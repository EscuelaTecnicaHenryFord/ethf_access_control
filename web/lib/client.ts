import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';
import type { AppRouter, AppRouterOutputs } from "./server";
import z from 'zod';

export const client = createTRPCProxyClient<AppRouter>({
    links: [
        httpBatchLink({
            url: '/api/trpc',
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

export const enrolmentRegex = /^(hf|HF|Hf|hF)?(\d{4}|([iI]\d{3}))$/
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
    requires_vehicle_access: z.boolean(),
    vehicle_brand_model: z.string().optional(),
    vehicle_licence_plate: z.string().optional(),
    driver_name: z.string().optional(),
    driver_id: z.string().optional(),
    driver_license_number: z.string().optional(),
    vehicle_insurance: z.string().optional(),
})