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
    verificationData: z.infer<typeof verificationDataSchema>,
    children: React.ReactNode
}) {
    const form = useForm<z.infer<typeof addGuestSchema>>({
        resolver: zodResolver(addGuestSchema),
        defaultValues: {
            dni: "",
            first_name: "",
            last_name: "",
            is_under_age: false,
            requires_vehicle_access: false,
        },
    })

    const [loading, setLoading] = useState(false)

    async function onSubmit(values: z.infer<typeof addGuestSchema>) {
        try {
            setLoading(true)
            
            if(!values.requires_vehicle_access) {
                values['vehicle_brand_model'] = ''
                values['vehicle_licence_plate'] = ''
                values['driver_name'] = ''
                values['driver_id'] = ''
                values['driver_license_number'] = ''
                values['vehicle_insurance'] = '' 
            }
            
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
            form.setValue("requires_vehicle_access", false)
            form.setValue("vehicle_brand_model", "")
            form.setValue("vehicle_licence_plate", "")
            form.setValue("driver_name", "")
            form.setValue("driver_id", "")
            form.setValue("driver_license_number", "")
            form.setValue("vehicle_insurance", "")

            props.onGuestAdded(result)
        } catch (error) {
            if (error instanceof TRPCClientError) {
                console.error(error)
                alert(error.message)
            }
        } finally {
            setLoading(false)
        }
    }

    return (

        <Dialog>
            <DialogTrigger asChild>
                {props.children}
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

                            {form.getValues('is_under_age') && <div className="pl-[20%]">
                                <p className="my-2 text-sm font-medium text-red-500">
                                    Todo menor que ingrese a la escuela debera circular en todo momento
                                    acompañado y cuidado por el adulto responsable con quien ingresa.
                                </p>
                            </div>}

                            <FormField
                                control={form.control}
                                name="requires_vehicle_access"
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
                        {form.getValues('requires_vehicle_access') && <>

                            <FormField
                                control={form.control}
                                name="vehicle_brand_model"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">Modelo y marca del vehiculo</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="vehicle_licence_plate"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">Patente del vehiculo</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />


                            <FormField
                                control={form.control}
                                name="driver_name"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">Nombre del conductor</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="driver_id"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">DNI del conductor</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="driver_license_number"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">Número de registro de conducir</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />

                            <FormField
                                control={form.control}
                                name="vehicle_insurance"
                                render={({ field }) => (
                                    <FormItem className="grid grid-cols-4 items-center gap-4">
                                        <FormLabel className="text-right">Número de póliza de seguro</FormLabel>
                                        <FormControl>
                                            <Input placeholder="" {...field} className="col-span-3" />
                                        </FormControl>
                                        <FormMessage className="col-span-4" />
                                    </FormItem>
                                )}
                            />
                        </>}
                        <DialogFooter className="mt-4">
                            {loading ? <Button type="submit" disabled> <Loader2 className="animate-spin" /> <span className="ml-2">Guardar</span></Button> : <Button type="submit">Guardar</Button>}
                        </DialogFooter>
                    </form>
                </Form>
            </DialogContent>
        </Dialog>

    )
}