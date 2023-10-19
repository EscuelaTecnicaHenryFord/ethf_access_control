import { Identity, fetchAll, getGlobalData } from "@/lib/data";
import { getSession } from "@/lib/session";

export async function GET(request: Request) {
    const session = await getSession()

    if(session.user === null) return new Response(null, { status: 401 })

    const url = new URL(request.url)

    const id = url.pathname.split('/').pop()!.toLowerCase()

    const data = await getGlobalData()

    let identity = data.getIdentity(id)

    if(!identity) {
        const data = await fetchAll()

        identity = data.getIdentity(id)
    }

    return new Response(JSON.stringify(identity ?? null), {
        headers: { "content-type": "application/json" },
    });
}