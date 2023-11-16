import { fetchAll } from "@/lib/data"
import { getSession } from "@/lib/session"
import { appendTo } from "@/lib/spreadsheet"

type Data = {
    first_name: string
    last_name: string
    dni: string
    invited_by: string
}

export async function POST(request: Request) {
    const session = await getSession()

    if (session.user === null) return new Response(null, { status: 401 })

    const url = new URL(request.url)

    try {
        const data: Data = await request.json()

        const { dni, first_name, last_name, invited_by } = data

        await appendTo('Invitados!A2:Z', [[
            first_name,
            last_name,
            dni,
            invited_by,
            'expo_2023',
            new Date(),
        ]])

        await fetchAll()
    } catch (error) {
        console.log(error)
    }

    return new Response(JSON.stringify(true), {})
}