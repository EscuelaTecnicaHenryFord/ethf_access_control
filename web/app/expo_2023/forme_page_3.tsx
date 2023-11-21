"use client"

import * as z from "zod"

import { client, verificationDataSchema } from "@/lib/client"
import { useEffect, useRef, useState } from "react"
import { AppRouterOutputs } from "@/lib/server"
import AddGuestFormDialog from "./dialog_add_guest"
import { Button } from "@/components/ui/button"
import { ArrowUp, PlusCircleIcon, PlusIcon, RefreshCcw, XCircle } from "lucide-react"



export function ManageGuests(props: { studentData: AppRouterOutputs['verifyStudentData'] | undefined, verificationData: z.infer<typeof verificationDataSchema> | undefined }) {

    const [guests, setGuests] = useState<AppRouterOutputs['getGuests'] | undefined>(undefined)

    const isMountedRef = useRef(false)
    useEffect(() => {
        if (!isMountedRef.current) {
            getGuests()
        }
        isMountedRef.current = true
        return () => { }
    }, [])

    async function getGuests() {
        try {
            const result = await client.getGuests.query({
                verificationData: props.verificationData!
            })

            setGuests(result)
        } catch (error) {
            console.error(error)
        }
    }

    const hasGuests = (!guests || guests.length === 0) ? false : true

    return (
        <main className="flex flex-col gap-5 pt-10 relative">
            <div className="col-span-2">
                <h2 className="font-medium text-lg">Invitados de la familia de {props.studentData?.student_name}</h2>
                <p className="mt-2 text-sm">Pueden agregar o eliminar invitados para la Expo 2023</p>
            </div>

            <div className="absolute top-10 right-0">
                <Button onClick={() => getGuests()} variant='outline'><RefreshCcw /></Button>

            </div>


            {hasGuests && <>
                <h2 className="font-semibold">Invitados ya registrados</h2>
                <div className="grid gap-5 mt-[-12px]">
                    {guests?.map(guest => {

                        async function removeGuest() {
                            if (!confirm(`¿Está seguro que desea eliminar a ${guest.first_name} ${guest.surname}?`)) return

                            await client.removeGuest.mutate({
                                verificationData: props.verificationData!,
                                guestData: {
                                    dni: guest.dni_cuil
                                }
                            })

                            await getGuests()
                        }

                        return <div className="border rounded-xl px-6 py-3 relative">
                            <p className="font-medium text-lg">{guest.first_name} {guest.surname}</p>
                            <p className="text-sm">{guest.dni_cuil}</p>

                            <div className="absolute top-0 bottom-0 right-3 flex items-center">
                                <Button onClick={() => removeGuest()} variant='ghost'><XCircle /></Button>

                            </div>
                        </div>
                    })}
                </div>

                <div>
                    <p className="font-medium border-2 border-blue-500 p-3 rounded-lg text-blue-500 text-lg">
                        Tus invitados están registrados y 25 de noviembre podrán ingresar a la Expo 2023 presentando su DNI.
                    </p>
                </div>

                <hr />
            </>}

            {!hasGuests && <>
                <p className="font-medium">Todavía no se han registrado invitados.</p>
            </>}

            <AddGuestFormDialog verificationData={props.verificationData!} onGuestAdded={async () => {
                await getGuests()
            }}>
                <Button variant="outline" id="close"><PlusCircleIcon className="mr-2" size={16}/> Agregar {hasGuests ? 'otro' : 'un'} invitado</Button>
            </AddGuestFormDialog >

            {!hasGuests && <div className="flex justify-center">
                <ArrowUp size={40} className="animate-bounce" />
            </div>}
        </main>
    )
}