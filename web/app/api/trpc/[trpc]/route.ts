import { appRouter } from '@/lib/server';
import { getSession } from '@/lib/session';
import { initTRPC } from '@trpc/server';
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';

// You can use any variable name you like.
// We use t to keep things simple.
const t = initTRPC.create();

const all = (request: Request) => {
  return fetchRequestHandler({
    endpoint: '/api/trpc',
    req: request,
    router: appRouter,
    createContext: () =>{
      return {
        server: true
      }
    },
  });
};

export {
  all as GET,
  all as POST,
}