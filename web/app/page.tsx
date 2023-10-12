import SignInButton from "@/components/signin-button"
import { getGlobalData } from "@/lib/data"
import { getSession } from "@/lib/session"
import { getRange, getSheetId, getSpreedsheet } from "@/lib/spreadsheet"

export default async function Home() {
  const session = await getSession()

  const data = await getGlobalData()

  return (
    <main>
      {session?.user?.name}
      <SignInButton />
      <pre>
        {JSON.stringify(data, null, 2)}
      </pre>
    </main>
  )
}
