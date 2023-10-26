import { appRouter } from '@/lib/server';
import { getSession } from '@/lib/session';
import { initTRPC } from '@trpc/server';
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';

// You can use any variable name you like.
// We use t to keep things simple.
const t = initTRPC.create();

export const router = t.router;
export const middleware = t.middleware;
export const publicProcedure = t.procedure;

const all = (request: Request) => {
  return fetchRequestHandler({
    endpoint: '/api/trpc',
    req: request,
    router: appRouter,
    createContext: (opts) =>{
      const session = getSession()
      return {
        session,
      }
    },
  });
};

export {
  all as GET,
  all as POST,
}