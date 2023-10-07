import { authOptions } from "@/pages/api/auth/[...nextauth]";
import { getServerSession } from "next-auth";

export async function getSession() {
    const session = await getServerSession(authOptions)

    return {
        ...session,
        role: 'student', // 'staff'
        isAdmin: false, // true        
    }
}