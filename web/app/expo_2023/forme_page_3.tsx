"use client"

import * as z from "zod"

import { client, verificationDataSchema } from "@/lib/client"
import { useEffect, useRef, useState } from "react"
import { AppRouterOutputs } from "@/lib/server"
import AddGuestFormDialog from "./dialog_add_guest"
import { Button } from "@/components/ui/button"
import { RefreshCcw, XCircle } from "lucide-react"



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
        const result = await client.getGuests.query({
            verificationData: props.verificationData!
        })

        setGuests(result)
    }

    return (
        <main className="flex flex-col gap-5 pt-10 relative">
            <div className="col-span-2">
                <h2 className="font-medium text-lg">Invitados de la familia de {props.studentData?.student_name}</h2>
                <p className="mt-2">Pueden agregar o eliminar invitados para la Expo 2023</p>
            </div>

            <div className="absolute top-10 right-0">
                <Button onClick={() => getGuests()} variant='outline'><RefreshCcw /></Button>

            </div>


            <div className="grid gap-5">
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

            <AddGuestFormDialog verificationData={props.verificationData!} onGuestAdded={async () => {
                await getGuests()
            }} />
        </main>
    )
}