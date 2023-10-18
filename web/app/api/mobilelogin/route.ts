import { getSession } from "@/lib/session";

export function GET(request: Request) {
    // Redirect to the mobile app
    // return Response.redirect("ethf-access-control://callback?token=123", 302)

    const user = getSession()

    if (!user) {
        return Response.redirect("/login/app", 302)
    }

    // Redirect to the mobile app
    return Response.redirect("ethf-access-control://callback?cookie=" + request.headers.get("cookie"), 302)
}