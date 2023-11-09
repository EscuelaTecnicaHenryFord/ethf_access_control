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
import { client, studentDataSchema } from "@/lib/client"
import { TRPCClientError } from "@trpc/client"
import { useState } from "react"
import { Loader2 } from "lucide-react"
import { AppRouterOutputs } from "@/lib/server"



export function FormVerifyStudentData(props: { onStudentVerified: (student: AppRouterOutputs['verifyStudentData']) => unknown }) {
    const form = useForm<z.infer<typeof studentDataSchema>>({
        resolver: zodResolver(studentDataSchema),
        defaultValues: {
            studentDNI: "",
            studentEnrolment: "",
        },
    })

    const [loading, setLoading] = useState(false)

    async function onSubmit(values: z.infer<typeof studentDataSchema>) {
        try {
            setLoading(true)
            const result = await client.verifyStudentData.query(values)
            props.onStudentVerified(result)
        } catch (error) {
            console.error(error)
            if (error instanceof TRPCClientError) {
                const code = error.data?.code

                if (code === 'NOT_FOUND') {
                    form.setError('root', {
                        message: 'No se encontró un estudiante con los datos ingresados'
                    })
                }
            }
        } finally {
            setLoading(false)
        }
    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-5 md:grid grid-cols-2 pt-10">
                <div className="col-span-2">
                    <h2 className="font-medium text-lg">Invitaciones expo 2023</h2>
                    <p className="mt-2">
                        Este formulario está dirigido a los padres de alumnos actuales del colegio para que puedan registrar invitados.
                    </p>
                </div>
                <div className="col-span-2">
                    <h3 className="font-medium text-lg">Paso 1: verificar datos del estudiante</h3>
                </div>

                <FormField
                    control={form.control}
                    name="studentDNI"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>DNI del estudiante o ingresante</FormLabel>
                            <FormControl>
                                <Input placeholder="..." {...field} />
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
                                <Input placeholder="..." {...field} />
                            </FormControl>
                            <FormDescription>
                                Ingresantes a primer año 2024 utilizar el número de inscripcion de ingreso
                            </FormDescription>
                            {/* <FormDescription>
                                Matricula del estudiante
                            </FormDescription> */}
                            <FormMessage />
                        </FormItem>
                    )}
                />
                {form.formState.errors.root && (
                    <div className="col-span-2">
                        <p className="text-red-500 font-medium">{form.formState.errors.root.message}</p>
                    </div>
                )}
                <div className="col-span-2 flex flex-row-reverse">
                    {loading ? <Button type="submit" disabled> <Loader2 className="animate-spin" /> <span className="ml-2">Siguiente</span></Button> : <Button type="submit">Siguiente</Button>}
                </div>
            </form>
        </Form>
    )
}