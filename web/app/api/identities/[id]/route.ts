import { Guest, Identity, fetchAll, getGlobalData } from "@/lib/data";
import { getSession } from "@/lib/session";

export async function GET(request: Request) {
    const session = await getSession()

    if(session.user === null) return new Response(null, { status: 401 })

    const url = new URL(request.url)

    const id = url.pathname.split('/').pop()!.toLowerCase()
    const eventId = url.searchParams.get('event')?.toLowerCase()
    const forceCurrentEvent = url.searchParams.get('force_current_event')?.toLowerCase() === 'true'

    const data = await getGlobalData()

    let identity = data.getIdentity(id)

    if(!identity) {
        const data = await fetchAll()

        identity = data.getIdentity(id)
    }

    let responseData: Identity | null = identity ?? null

    if(eventId && identity && !identity.events?.find(event => event === eventId)) {
        responseData = null
    }

    const currentEvents = data.getCurrentEvents()
    if(forceCurrentEvent && identity && !identity.events?.find(event => currentEvents.find(currentEvent => currentEvent.id === event))) {
        responseData = null
    }

    if(eventId && responseData && responseData.type === 'guest') {
        responseData = {...responseData}
        responseData.ref = responseData.ref.filter(ref => {
            if((ref as Guest).event_id !== eventId) {
                return false
            }
            return true
        })
    }

    return new Response(JSON.stringify(responseData), {
        headers: { "content-type": "application/json" },
    });
}