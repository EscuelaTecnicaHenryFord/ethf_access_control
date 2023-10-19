import { Event, getGlobalData } from "@/lib/data";
import { getSession } from "@/lib/session";

export async function GET(request: Request) {
    const session = await getSession()

    if (session.user === null) return new Response(null, { status: 401 })

    const data = await getGlobalData()

    return new Response(JSON.stringify({
        events: data.events,
        current: data.getCurrentEvents().map(event => event.id),
    }), {
        headers: { "content-type": "application/json" },
    });
}