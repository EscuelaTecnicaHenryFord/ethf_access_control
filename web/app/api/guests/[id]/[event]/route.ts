import { Guest, Identity, fetchAll, getGlobalData } from "@/lib/data";
import { getSession } from "@/lib/session";

export async function GET(request: Request) {
    const session = await getSession()

    if (session.user === null) return new Response(null, { status: 401 })

    const url = new URL(request.url)

    const s = url.pathname.split('/')

    const event = s.pop()!.toLowerCase()
    const id = s.pop()!.toLowerCase()

    const data = await getGlobalData()

    const guest = data.getIdentity(id)

    let responseData: any = null

    if (guest && guest.type === 'guest') {
        const guestData = guest.ref.find(x => ((x as Guest).event_id === event)) as Guest | undefined

        if(!guestData) {
            return new Response(JSON.stringify(null), {
                headers: { "content-type": "application/json" },
            });
        }

        responseData = {
            ...guest,
            ...guestData,
            invited_by_identity: guest.invited_by ? (data.getIdentity(guest.invited_by) || null) : null,
        }
    }

    return new Response(JSON.stringify(responseData, null, 2), {
        headers: { "content-type": "application/json" },
    });
}