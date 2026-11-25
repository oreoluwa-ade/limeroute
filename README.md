# LimeRoute

Link management, intelligence and control.

## Stack
- Next.js App Router + TypeScript
- Tailwind CSS
- Supabase (project: `lime`)
- Cloudflare Workers for the redirect service (separate deployment)

## Local development
1. `npm install`
2. Copy `.env.example` to `.env.local` and fill in Supabase publishable credentials.
3. `npm run dev`

Do not put Supabase service-role keys in client-side environment variables.
