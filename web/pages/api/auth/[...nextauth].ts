import NextAuth from "next-auth"
import AzureADProvider from "next-auth/providers/azure-ad"
export const authOptions = {
  // Configure one or more authentication providers
  secret: process.env.NEXTAUTH_SECRET!,
  providers: [
    AzureADProvider({
      clientId: process.env.CLIENT_ID!,
      clientSecret: process.env.CLIENT_SECRET!,
      tenantId: process.env.TENANT_ID!,
    }),
    // ...add more providers here
  ],
}

export default NextAuth(authOptions)