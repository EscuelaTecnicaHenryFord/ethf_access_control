"use client"

import { signIn, useSession } from "next-auth/react";
import { Button } from "./ui/button";
import { useState } from "react";
import { Loader2Icon } from "lucide-react"

export default function SignInButton() {
    const [loggingIn, setLoggingIn] = useState(false);

    async function handleSignIn() {
        setLoggingIn(true);
        await signIn('azure-ad');
        setLoggingIn(false);
    }

    return <Button onClick={() => handleSignIn()} variant="outline" disabled={loggingIn} className="min-w-[120px]">
        {loggingIn && <div className="animate-spin mr-2"><Loader2Icon/></div>}
            Sign In
        </Button>;
}