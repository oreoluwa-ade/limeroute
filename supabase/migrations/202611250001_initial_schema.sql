create extension if not exists pgcrypto;
create table public.links (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 slug text not null unique,
 destination_url text not null,
 title text,
 description text,
 status text not null default 'active' check (status in ('active','paused','archived')),
 expires_at timestamptz,
 scheduled_at timestamptz,
 click_limit bigint,
 clicks_count bigint not null default 0,
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
create table public.campaigns (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 description text,
 starts_at timestamptz,
 ends_at timestamptz,
 status text not null default 'active' check (status in ('active','paused','archived')),
 created_at timestamptz not null default now(),
 updated_at timestamptz not null default now()
);
alter table public.links add column campaign_id uuid references public.campaigns(id) on delete set null;
create table public.tags (id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade, name text not null, created_at timestamptz not null default now(), unique(user_id,name));
create table public.link_tags (link_id uuid not null references public.links(id) on delete cascade, tag_id uuid not null references public.tags(id) on delete cascade, primary key(link_id,tag_id));
create table public.click_events (id bigint generated always as identity primary key, link_id uuid not null references public.links(id) on delete cascade, occurred_at timestamptz not null default now(), country_code text, referrer text, referrer_type text, device_type text, browser text, operating_system text, is_bot boolean not null default false);
create index links_user_created_idx on public.links(user_id,created_at desc);
create index links_campaign_idx on public.links(campaign_id);
create index click_events_link_time_idx on public.click_events(link_id,occurred_at desc);
create index click_events_time_idx on public.click_events(occurred_at desc);
alter table public.links enable row level security;
alter table public.campaigns enable row level security;
alter table public.tags enable row level security;
alter table public.link_tags enable row level security;
alter table public.click_events enable row level security;
create policy "users manage own links" on public.links for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "users manage own campaigns" on public.campaigns for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "users manage own tags" on public.tags for all to authenticated using ((select auth.uid())=user_id) with check ((select auth.uid())=user_id);
create policy "users manage link tags through ownership" on public.link_tags for all to authenticated using (exists(select 1 from public.links l where l.id=link_id and l.user_id=(select auth.uid())) and exists(select 1 from public.tags t where t.id=tag_id and t.user_id=(select auth.uid()))) with check (exists(select 1 from public.links l where l.id=link_id and l.user_id=(select auth.uid())) and exists(select 1 from public.tags t where t.id=tag_id and t.user_id=(select auth.uid())));
create policy "owners read click events" on public.click_events for select to authenticated using (exists(select 1 from public.links l where l.id=link_id and l.user_id=(select auth.uid())));
grant select,insert,update,delete on public.links,public.campaigns,public.tags,public.link_tags to authenticated;
grant select on public.click_events to authenticated;