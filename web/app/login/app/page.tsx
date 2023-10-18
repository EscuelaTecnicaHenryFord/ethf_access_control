"use client"

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { signIn, useSession } from "next-auth/react"
import { useEffect } from "react"

export default function MobileLoginPage() {

    // useEffect(() => {
    //     signIn('azure-ad', {
    //         callbackUrl: '/api/mobile_login_callback'
    //     })
    // }, [])

    function handleSignIn() {
        signIn('azure-ad', {
            callbackUrl: '/api/mobilelogin'
        })
    }

    const session = useSession()

    useEffect(() => {
        if(session.status === 'unauthenticated') {
            handleSignIn()
        }
    }, [session])

    return <div className="fixed left-0 right-0 top-0 bottom-0 flex justify-center items-center p-10">
        <Card className="w-[340px] max-w-full">
            {session.status === 'authenticated' && <>
                <CardHeader onClick={() => window.location.href = '/api/mobilelogin'} role="button">
                    <CardTitle>{session.data?.user?.name}</CardTitle>
                    <CardDescription>{session.data?.user?.email}</CardDescription>
                </CardHeader>
                <CardContent onClick={handleSignIn} role="button">
                    <CardTitle>Usar otra cuenta</CardTitle>
                </CardContent>
            </>}
            {session.status !== 'authenticated' && 
                <CardHeader>
                    <CardTitle>Cargando información</CardTitle>
                </CardHeader>
            }
        </Card>
    </div>
}