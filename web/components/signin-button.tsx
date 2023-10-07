"use client"

import { signIn } from "next-auth/react";

export default function SignInButton(props: React.ComponentProps<'a'>) {
    return <a {...props} href="javascript:void(0)" onClick={e => signIn('azure-ad')}>
        {props.children}
    </a>
}