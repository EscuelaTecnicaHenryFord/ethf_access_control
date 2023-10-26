import { google } from 'googleapis'
import { Awaitable } from 'next-auth'


async function _getAuth() {
    if (process.env.SERVICE_ACCOUNT) {
        const auth = await google.auth.getClient({
            credentials: JSON.parse(process.env.SERVICE_ACCOUNT),
            scopes: ['https://www.googleapis.com/auth/spreadsheets'],
        })
        return auth
    }

    const auth = await google.auth.getClient({
        scopes: ['https://www.googleapis.com/auth/spreadsheets'],
        keyFile: 'service-account.json',
    })
    return auth
}

let auth: Awaited<ReturnType<typeof _getAuth>> | null = null

export async function getAuth() {
    if (auth === null) {
        auth = await _getAuth()
    }
    return auth
}

export async function getSpreedsheet() {
    const auth = await getAuth()
    const sheets = google.sheets({
        version: 'v4', auth: auth
    });

    return sheets
}

export function getSheetId() {
    return process.env.SHEET_ID!
}

export async function getRange(range: string) {
    const sheets = await getSpreedsheet()
    const res = await sheets.spreadsheets.values.get({
        spreadsheetId: getSheetId(),
        range: range
    })
    return res.data
}

export async function appendTo(range: string, data: (string | number | Date)[][]) {
    const sheets = await getSpreedsheet()
    const res = await sheets.spreadsheets.values.append({
        spreadsheetId: getSheetId(),
        range: range,
        valueInputOption: 'RAW',
        requestBody: {
            values: data
        }
    })
    return res.data
}


export async function clearRows(sheetName: string, callback: (row: string[]) => Awaitable<boolean>) {
    const ranges: string[] = []

    await visitRowOfRange(sheetName, async (index, row) => {
        const shouldClear = await callback(row)
        if (shouldClear) {
            ranges.push(`${sheetName}!A${index+1}:Z`)
        }
    })

    const sheets = await getSpreedsheet()

    console.log(ranges)

    const res = await sheets.spreadsheets.values.batchClear({
        spreadsheetId: getSheetId(),
        requestBody: {
            ranges
        }
    })
    return res.data
}

export async function visitRowOfRange(sheetName: string, callback: (index: number, row: string[]) => Awaitable<void>) {
    const sheets = await getSpreedsheet()
    const res = await sheets.spreadsheets.values.get({
        spreadsheetId: getSheetId(),
        range: `${sheetName}!A1:Z`
    })
    const rows = res.data.values!
    for (const row of rows) {
        await callback(rows.indexOf(row), row)
    }
}