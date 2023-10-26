"use client"

import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import * as z from "zod"

import { Button } from "@/components/ui/button"
import {
    Form,
    FormControl,
    FormDescription,
    FormField,
    FormItem,
    FormLabel,
    FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import { client } from "@/lib/client"


const dniErrorOptions = {
    message: "Ingrese un DNI válido",
}

const enrolmentErrorOptions = {
    message: "Ingrese una matrícula válida",
}

const formSchema = z.object({
    studentDNI: z.string().regex(/^\d{2}\.?\d{3}\.?\d{3}$/, dniErrorOptions),
    studentEnrolment: z.string().regex(/^(hf|HF|Hf|hF)?\d{4}$/, enrolmentErrorOptions),
})

export function FormVerifyStudentData() {
    const form = useForm<z.infer<typeof formSchema>>({
        resolver: zodResolver(formSchema),
        defaultValues: {
            studentDNI: "",
            studentEnrolment: "",
        },
    })
    async function onSubmit(values: z.infer<typeof formSchema>) {
        console.log(await client.greeting.query())
    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-5 md:grid grid-cols-2 pt-10">
                <div className="col-span-2">
                    <h2 className="font-medium text-lg">Invitaciones expo 2023</h2>
                    <p className="mt-2">Este formulario está dirigido a los padres de alumnos actuales del colegio para que puedan registrar invitados.</p>
                </div>
                <div className="col-span-2">
                    <h3 className="font-medium text-lg">Paso 1: verificar datos del estudiante</h3>
                </div>
                <FormField
                    control={form.control}
                    name="studentDNI"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>DNI estudiante</FormLabel>
                            <FormControl>
                                <Input placeholder="99.999.999" {...field} />
                            </FormControl>
                            {/* <FormDescription>
                                DNI del estudiante
                            </FormDescription> */}
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <FormField
                    control={form.control}
                    name="studentEnrolment"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>Matrícula el estudiante</FormLabel>
                            <FormControl>
                                <Input placeholder="HF9999" {...field} />
                            </FormControl>
                            {/* <FormDescription>
                                Matricula del estudiante
                            </FormDescription> */}
                            <FormMessage />
                        </FormItem>
                    )}
                />
                <div className="col-span-2 flex flex-row-reverse">
                    <Button type="submit">Siguiente</Button>
                </div>
            </form>
        </Form>
    )
}