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
import { client, parentDataVerificationSchema, studentDataSchema } from "@/lib/client"
import { TRPCClientError } from "@trpc/client"
import { useState } from "react"
import { Loader2 } from "lucide-react"
import { AppRouterOutputs } from "@/lib/server"



export function FormVerifyParentsData(props: { studentData: AppRouterOutputs['verifyStudentData'] | undefined, onVerificationCompleted: (data: AppRouterOutputs['verifyStudentDataWithParents']) => unknown }) {
    const form = useForm<z.infer<typeof parentDataVerificationSchema>>({
        resolver: zodResolver(parentDataVerificationSchema),
        defaultValues: {
            fatherDNI: "",
            motherDNI: "",
        },
    })

    const [loading, setLoading] = useState(false)

    async function onSubmit(values: z.infer<typeof parentDataVerificationSchema>) {
        try {
            setLoading(true)
            const result = await client.verifyStudentDataWithParents.mutate({
                studentDNI: props.studentData!.student_dni,
                studentEnrolment: props.studentData!.student_enrolment!,
                ...values,
            })
            props.onVerificationCompleted(result)
            // props.onStudentVerified(result)
        } catch (error) {
            if (error instanceof TRPCClientError) {
                const code = error.data?.code

                if (code === 'NOT_FOUND') {
                    form.setError('root', {
                        message: 'No se encontró un estudiante con los datos ingresados'
                    })
                }
            }
            console.error(error)
        } finally {
            setLoading(false)
        }
    }

    return (
        <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="flex flex-col gap-5 md:grid grid-cols-2 pt-10">
                <div className="col-span-2">
                    <h2 className="font-medium text-lg">Invitaciones expo 2023</h2>
                    <p className="mt-2 text-lg">Verificar información de los padres de
                        <br className="sm:hidden"/>
                        <span className="bg-blue-500 text-white font-medium my-1 py-1 mx-[-2px] px-1 rounded-md">{props.studentData?.student_name}</span>
                    </p>
                </div>
                <div className="col-span-2">
                    <h3 className="font-medium text-lg">Paso 2: verificar datos de los padres</h3>
                    <p className="mt-2 text-blue-500 font-medium">Completar alguno de los siguientes</p>
                </div>

                {props.studentData?.father_name && <FormField
                    control={form.control}
                    name="fatherDNI"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>DNI de {props.studentData?.father_name}</FormLabel>
                            <FormControl>
                                <Input placeholder="99.999.999" {...field} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />}
                {props.studentData?.mother_name && <FormField
                    control={form.control}
                    name="motherDNI"
                    render={({ field }) => (
                        <FormItem>
                            <FormLabel>DNI de {props.studentData?.mother_name}</FormLabel>
                            <FormControl>
                                <Input placeholder="99.999.999" {...field} />
                            </FormControl>
                            <FormMessage />
                        </FormItem>
                    )}
                />}
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