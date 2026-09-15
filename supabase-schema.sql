-- WingBait production data model
-- Run this in Supabase SQL Editor after creating a project.
-- IMPORTANT: public browser code must use only the anon/publishable key.
-- Never expose a service_role key in index.html, admin.html, or supabase-config.js.

create extension if not exists pgcrypto;

create table if not exists public.leads (
  id uuid primary key default gen_random_uuid(),
  source text not null default 'website_ai',
  name text,
  business text,
  type text,
  goal text,
  pages text,
  style text,
  timing text,
  contact text,
  email text,
  phone text,
  fit text,
  recommendation text,
  status text not null default 'New' check (status in ('New','Contacted','Negotiation','Won','Lost')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  lead_id uuid references public.leads(id) on delete set null,
  name text not null,
  business text,
  email text,
  phone text,
  country text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references public.clients(id) on delete cascade,
  name text not null,
  status text not null default 'Planned' check (status in ('Planned','Confirmed','In Progress','Review','Delivered','Closed')),
  agreed_amount numeric(12,2) not null default 0,
  currency text not null default 'INR' check (currency in ('INR','USD')),
  delivery_note text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  invoice_no text not null unique,
  client_id uuid references public.clients(id) on delete set null,
  project_id uuid references public.projects(id) on delete set null,
  client_name text,
  business text,
  client_email text,
  client_phone text,
  country text not null default 'INR' check (country in ('INR','USD')),
  status text not null default 'Pending' check (status in ('Pending','Partially Paid','Paid','Cancelled')),
  service text,
  build numeric(12,2) not null default 0,
  setup numeric(12,2) not null default 0,
  extra numeric(12,2) not null default 0,
  discount numeric(12,2) not null default 0,
  notes text,
  domain_cost numeric(12,2) not null default 0,
  hosting_cost numeric(12,2) not null default 0,
  tools_cost numeric(12,2) not null default 0,
  other_cost numeric(12,2) not null default 0,
  internal_notes text,
  invoice_date date not null default current_date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  invoice_id uuid not null references public.invoices(id) on delete cascade,
  amount numeric(12,2) not null check (amount >= 0),
  currency text not null check (currency in ('INR','USD')),
  method text not null check (method in ('UPI','PayPal','Bank Transfer','Other')),
  reference text,
  paid_at timestamptz not null default now(),
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists leads_status_idx on public.leads(status);
create index if not exists leads_created_idx on public.leads(created_at desc);
create index if not exists invoices_status_idx on public.invoices(status);
create index if not exists payments_invoice_idx on public.payments(invoice_id);

-- Admin membership is based on authenticated Supabase users.
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

alter table public.leads enable row level security;
alter table public.clients enable row level security;
alter table public.projects enable row level security;
alter table public.invoices enable row level security;
alter table public.payments enable row level security;
alter table public.admin_users enable row level security;

create or replace function public.is_wingbait_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.admin_users where user_id = auth.uid());
$$;

-- Public site: it may create a lead, but it cannot read/update/delete leads.
drop policy if exists "public can create leads" on public.leads;
create policy "public can create leads"
on public.leads for insert
to anon, authenticated
with check (source = 'website_ai');

-- Admin-only access to all business data.
drop policy if exists "admins can read leads" on public.leads;
create policy "admins can read leads" on public.leads for select to authenticated using (public.is_wingbait_admin());
drop policy if exists "admins can update leads" on public.leads;
create policy "admins can update leads" on public.leads for update to authenticated using (public.is_wingbait_admin()) with check (public.is_wingbait_admin());
drop policy if exists "admins can delete leads" on public.leads;
create policy "admins can delete leads" on public.leads for delete to authenticated using (public.is_wingbait_admin());

-- Admin CRUD for clients/projects/invoices/payments.
create policy "admins read clients" on public.clients for select to authenticated using (public.is_wingbait_admin());
create policy "admins write clients" on public.clients for all to authenticated using (public.is_wingbait_admin()) with check (public.is_wingbait_admin());
create policy "admins read projects" on public.projects for select to authenticated using (public.is_wingbait_admin());
create policy "admins write projects" on public.projects for all to authenticated using (public.is_wingbait_admin()) with check (public.is_wingbait_admin());
create policy "admins read invoices" on public.invoices for select to authenticated using (public.is_wingbait_admin());
create policy "admins write invoices" on public.invoices for all to authenticated using (public.is_wingbait_admin()) with check (public.is_wingbait_admin());
create policy "admins read payments" on public.payments for select to authenticated using (public.is_wingbait_admin());
create policy "admins write payments" on public.payments for all to authenticated using (public.is_wingbait_admin()) with check (public.is_wingbait_admin());
create policy "admins read admin users" on public.admin_users for select to authenticated using (public.is_wingbait_admin());

-- Keep updated_at current.
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

drop trigger if exists leads_touch_updated_at on public.leads;
create trigger leads_touch_updated_at before update on public.leads for each row execute function public.touch_updated_at();
drop trigger if exists clients_touch_updated_at on public.clients;
create trigger clients_touch_updated_at before update on public.clients for each row execute function public.touch_updated_at();
drop trigger if exists projects_touch_updated_at on public.projects;
create trigger projects_touch_updated_at before update on public.projects for each row execute function public.touch_updated_at();
drop trigger if exists invoices_touch_updated_at on public.invoices;
create trigger invoices_touch_updated_at before update on public.invoices for each row execute function public.touch_updated_at();

-- Client communication history (optional but recommended for production)
create table if not exists public.communication_logs (
  id uuid primary key default gen_random_uuid(),
  client_id uuid references public.clients(id) on delete set null,
  project_id uuid references public.projects(id) on delete set null,
  invoice_id uuid references public.invoices(id) on delete set null,
  type text not null,
  channel text not null default 'WhatsApp',
  message text not null,
  created_at timestamptz not null default now()
);
create index if not exists communication_logs_created_idx on public.communication_logs(created_at desc);
alter table public.communication_logs enable row level security;
drop policy if exists "admins read communication logs" on public.communication_logs;
create policy "admins read communication logs" on public.communication_logs for select to authenticated using (public.is_wingbait_admin());
drop policy if exists "admins write communication logs" on public.communication_logs;
create policy "admins write communication logs" on public.communication_logs for all to authenticated using (public.is_wingbait_admin()) with check (public.is_wingbait_admin());
