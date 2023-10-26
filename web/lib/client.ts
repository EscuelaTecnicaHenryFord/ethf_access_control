import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from "./server";

export const client = createTRPCProxyClient<AppRouter>({
    links: [
        httpBatchLink({
            url: 'http://localhost:3000/api/trpc',
            // You can pass any HTTP headers you wish here
            async headers() {
                return {};
            },
        }),
    ],
});