import { SessionProvider } from "next-auth/react";

export default function Providers({ children }: { children: React.ReactNode }) {
    <SessionProvider>
        {children}
    </SessionProvider>
}