import Providers from '@/components/providers'
import './globals.css'
import type { Metadata, ResolvingMetadata } from 'next'
import { Inter } from 'next/font/google'
import { getSetting } from '@/lib/settings'

const inter = Inter({ subsets: ['latin'] })

type Props = {
  params: {}
  searchParams: {}
}

export async function generateMetadata({ params, searchParams }: Props, parent: ResolvingMetadata): Promise<Metadata> {
  const title = await getSetting('web_title')

  return {
    title,
    // openGraph: {
    //   images: ['/some-specific-page-image.jpg', ...previousImages],
    // },
  }
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="es">
      <body className={inter.className}>
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  )
}
