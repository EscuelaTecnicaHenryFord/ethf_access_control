import { getRange } from "./spreadsheet"

type Settings = Record<string, any>

export async function readSettings(): Promise<Settings> {
    try {
        const data = await getRange('Configuración!A2:B')
        const settings: Settings = {}

        for(let i = 0; i < data.values!.length; i++) {
            const row = data.values![i]
            settings[row[0]] = row[1]
        }

        if (settings) {
            lastSettings = settings
            lastSettingsUpdate = new Date()
            return settings
        }
    } catch (error) {
        console.error(error)
    }

    return lastSettings
}

export let lastSettings: Settings = {}
export let lastSettingsUpdate: Date | null = null

export async function getSetting(key: string): Promise<any> {
    if (lastSettingsUpdate === null || (new Date().getTime() - lastSettingsUpdate.getTime()) > 1000 * 60 * 5) {
        await readSettings()
    }

    if (lastSettings[key] !== undefined) {
        return lastSettings[key]
    }

    const settings = await readSettings()
    return settings[key]
}