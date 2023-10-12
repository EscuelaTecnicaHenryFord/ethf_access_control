import { Identity, fetchAll, getGlobalData } from "@/lib/data";

export async function GET(request: Request) {
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