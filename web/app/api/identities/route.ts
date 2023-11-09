import { Guest, Identity, fetchAll, getGlobalData } from "@/lib/data";
import { getSession } from "@/lib/session";

export async function GET(request: Request) {
    const session = await getSession()

    if(session.user === null) return new Response(null, { status: 401 })

    const url = new URL(request.url)

    const id = url.pathname.split('/').pop()!.toLowerCase()
    const eventId = url.searchParams.get('event')?.toLowerCase()
    const forceCurrentEvent = url.searchParams.get('force_current_event')?.toLowerCase() === 'true'
    const guestsOnly = url.searchParams.get('guests_only')?.toLowerCase() === 'true'

    const data = await getGlobalData()

    let responseData: Identity[] | null = data.identities ?? null

    const currentEvents = data.getCurrentEvents()

    if(forceCurrentEvent && responseData) {
        responseData = responseData.filter(identity => {
            if(!identity.events?.find(event => currentEvents.find(currentEvent => currentEvent.id === event))) {
                return false
            }
            return true
        })
    }

    if(eventId && responseData) {
        responseData = responseData.filter(identity => {
            if(!identity.events?.find(event => event === eventId)) {
                return false
            }
            return true
        })
    }

    if(guestsOnly && responseData) {
        responseData = responseData.filter(identity => identity.type === 'guest')
    }

    return new Response(JSON.stringify(responseData), {
        headers: { "content-type": "application/json" },
    });
}