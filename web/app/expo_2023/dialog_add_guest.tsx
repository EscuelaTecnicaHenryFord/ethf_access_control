"use client"

import { Button } from "@/components/ui/button"
import {
    Dialog,
    DialogContent,
    DialogDescription,
    DialogFooter,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from "@/components/ui/dialog"
import { useForm } from "react-hook-form"

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
import { Label } from "@/components/ui/label"
import { addGuestSchema, client, verificationDataSchema } from "@/lib/client"
import { zodResolver } from "@hookform/resolvers/zod"
import z from "zod"
import { Checkbox } from "@/components/ui/checkbox"
import { AppRouterOutputs } from "@/lib/server"
import { useState } from "react"
import { Loader2 } from "lucide-react"
import { TRPCClientError } from "@trpc/client"

export default function AddGuestFormDialog(props: {
    onGuestAdded: (guest: AppRouterOutputs['addGuest']) => unknown,
    verificationData: z.infer<typeof verificationDataSchema>
}) {
    const form = useForm<z.infer<typeof addGuestSchema>>({
        resolver: zodResolver(addGuestSchema),
        defaultValues: {
            dni: "",
            first_name: "",
            last_name: "",
            is_under_age: false,
            requires_assistant: false,
        },
    })

    const [loading, setLoading] = useState(false)

    async function onSubmit(values: z.infer<typeof addGuestSchema>) {
        try {
            console.log(props.verificationData)
            setLoading(true)
            const result = await client.addGuest.mutate({
                verificationData: props.verificationData!,
                guestData: values,
            })
            document.getElementById("close")?.click()
            form.clearErrors()
            form.setValue("dni", "")
            form.setValue("first_name", "")
            form.setValue("last_name", "")
            form.setValue("is_under_age", false)
            form.setValue("requires_assistant", false)
            props.onGuestAdded(result)
        } catch (error) {
            if (error instanceof TRPCClientError) {
                console.error(error)
            }
        } finally {
            setLoading(false)
        }
    }

    return (

        <Dialog>
            <DialogTrigger asChild>
                <Button variant="outline" id="close">Agregar invitado</Button>
            </DialogTrigger>
            <DialogContent className="sm:max-w-[600px]">
                <Form {...form}>
                    <form onSubmit={form.handleSubmit(onSubmit)}>
                        <DialogHeader>
                            <DialogTitle>Agregar invitado</DialogTitle>
                            <DialogDescription>
                                Complete los datos del invitado
                            </DialogDescription>
                        </DialogHeader>
                        <div>
                            <FormField
                                control={form.control}
                                name="first_name"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">Nombre</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="last_name"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">Apellido</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="dni"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">DNI del invitado</FormLabel>
                                        <FormControl>
                                            <Input placeholder="99.999.999" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />
                            <FormField
                                control={form.control}
                                name="is_under_age"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <div className="ml-auto pt-3">
                                            <FormControl>
                                                <Checkbox
                                                    disabled={field.disabled}
                                                    name={field.name}
                                                    onBlur={field.onBlur}
                                                    ref={field.ref}
                                                    className="col-span-3"
                                                    checked={field.value}
                                                    onCheckedChange={field.onChange}
                                                />
                                            </FormControl>
                                        </div>
                                        <FormLabel className="col-span-3">Es menor de edad</FormLabel>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />



                            <FormField
                                control={form.control}
                                name="requires_assistant"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <div className="ml-auto pt-3">
                                            <FormControl>
                                                <Checkbox
                                                    disabled={field.disabled}
                                                    name={field.name}
                                                    onBlur={field.onBlur}
                                                    ref={field.ref}
                                                    className="col-span-3"
                                                    checked={field.value}
                                                    onCheckedChange={field.onChange}
                                                />
                                            </FormControl>
                                        </div>
                                        <FormLabel className="col-span-3">Requiere ingreso con vehiculo por severos problemas de movilidad</FormLabel>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />



                        </div>
                        <DialogFooter className="mt-4">
                            {loading ? <Button type="submit" disabled> <Loader2 className="animate-spin" /> <span className="ml-2">Guardar</span></Button> : <Button type="submit">Guardar</Button>}
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>

    )
}