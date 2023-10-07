import SignInButton from "@/components/signin-button"
import { getSession } from "@/lib/session"
import { getRange, getSheetId, getSpreedsheet } from "@/lib/spreadsheet"

export default async function Home() {
  const session = await getSession()

  const data = await getRange('Invitados!B1:D')

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
