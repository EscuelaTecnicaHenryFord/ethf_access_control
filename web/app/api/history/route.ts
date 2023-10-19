import { getSession } from "@/lib/session";
import { appendTo, getRange } from "@/lib/spreadsheet";

export async function GET() {
    const session = await getSession()

    if (session.user === null) return new Response(null, { status: 401 })

    const historyData = (await getRange('Historial!A2:C')).values ?? []

    const history = historyData.map(([identity, timestamp, data]) => {
        return {
            identity,
            timestamp,
            data: tryParseJSON(data)
        }
    }).sort((a, b) => {
        return new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
    })

    return new Response(JSON.stringify({ history }, null, 2), {
        headers: { "content-type": "application/json" },
    });
}

function tryParseJSON(json: string) {
    try {
        return JSON.parse(json)
    } catch (e) {
        return null
    }
}

export async function POST(request: Request) {
    const session = await getSession()

    if (session.user === null) return new Response(null, { status: 401 })

    const { identity, data } = await request.json()
    
    const timestamp = new Date().toISOString()

    await appendTo('Historial!A2:C', [[identity, timestamp, JSON.stringify(data)]])

    return Response.json(true)
}