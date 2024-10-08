import { parseISO, formatISO } from "date-fns"
import { tz } from "@date-fns/tz"

export function convertToUTCISO(localTimestamp: string): string {
    const timezone = 'Europe/Berlin' // Dakosy is exclusive to Germany
    const timestamp = parseISO(localTimestamp, { in: tz(timezone) })
    const formattedTimestamp = formatISO(timestamp, { in: tz('UTC') })

    return formattedTimestamp
}
