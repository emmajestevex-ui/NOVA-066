create table if not exists public.license_admins (
    user_id uuid primary key references auth.users(id) on delete cascade,
    role text not null default 'founder',
    created_at timestamptz not null default now(),
    check (role in ('founder', 'admin'))
);

alter table public.license_admins enable row level security;

create or replace function public.is_license_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
    select
        lower(coalesce(auth.jwt() ->> 'email', '')) in (
            '2008yashirchavez@gmail.com',
            'emmajestevex@gmail.com',
            'grego23500@gmail.com'
        )
        or exists (
            select 1
            from public.license_admins
            where user_id = auth.uid()
        );
$$;

insert into public.license_admins (user_id, role)
select id, 'founder'
from auth.users
where lower(email) in (
    '2008yashirchavez@gmail.com',
    'emmajestevex@gmail.com',
    'grego23500@gmail.com'
)
on conflict (user_id) do update
set role = excluded.role;

grant execute on function public.is_license_admin() to authenticated;
