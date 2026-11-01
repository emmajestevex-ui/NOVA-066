-- For a fresh install run supabase/licenses_setup.sql first. This file only
-- refreshes the client RPC functions after the secure key tables exist.

create or replace function public.activate_license(
    p_license_key text,
    p_device_id text
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
    v_license public.licenses%rowtype;
    v_key text;
    v_device text := trim(coalesce(p_device_id, ''));
begin
    v_key := public.normalize_license_key(p_license_key);

    if v_key = '' or v_device = '' then
        return json_build_object('success', false, 'message', 'Invalid key', 'capabilities', json_build_array(), 'expires_at', null);
    end if;

    if v_key ~ '^NOVA-[0-9]+$' then
        return json_build_object('success', false, 'message', 'Old numeric keys are disabled', 'capabilities', json_build_array(), 'expires_at', null);
    end if;

    select *
    into v_license
    from public.licenses
    where license_key = v_key
    for update;

    if not found then
        return json_build_object('success', false, 'message', 'Invalid key', 'capabilities', json_build_array(), 'expires_at', null);
    end if;

    if v_license.expires_at is not null and v_license.expires_at <= now() then
        update public.licenses
        set status = 'expired', is_active = false, updated_at = now()
        where id = v_license.id;

        return json_build_object('success', false, 'message', 'Key expired', 'capabilities', json_build_array(), 'expires_at', v_license.expires_at);
    end if;

    if v_license.status in ('paused', 'blocked', 'expired') or v_license.is_active = false then
        return json_build_object(
            'success', false,
            'message', public.license_status_message(v_license.status),
            'capabilities', json_build_array(),
            'expires_at', v_license.expires_at
        );
    end if;

    if v_license.status <> 'available'
        or v_license.used_at is not null
        or v_license.device_id is not null
        or v_license.activated_at is not null then
        return json_build_object(
            'success', false,
            'message', 'This key has already been used',
            'capabilities', json_build_array(),
            'expires_at', v_license.expires_at
        );
    end if;

    update public.licenses
    set
        device_id = v_device,
        activated_at = now(),
        used_at = now(),
        status = 'active',
        is_active = true,
        updated_at = now()
    where id = v_license.id
    returning * into v_license;

    return json_build_object(
        'success', true,
        'message', 'Key activated successfully',
        'capabilities', coalesce(v_license.capabilities, '[]'::jsonb),
        'expires_at', v_license.expires_at
    );
end;
$$;

create or replace function public.check_license(
    p_license_key text,
    p_device_id text
)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
    v_license public.licenses%rowtype;
    v_key text;
    v_device text := trim(coalesce(p_device_id, ''));
begin
    v_key := public.normalize_license_key(p_license_key);

    if v_key = '' or v_device = '' then
        return json_build_object('success', false, 'message', 'Invalid key', 'capabilities', json_build_array(), 'expires_at', null);
    end if;

    if v_key ~ '^NOVA-[0-9]+$' then
        return json_build_object('success', false, 'message', 'Old numeric keys are disabled', 'capabilities', json_build_array(), 'expires_at', null);
    end if;

    select *
    into v_license
    from public.licenses
    where license_key = v_key
    for update;

    if not found then
        return json_build_object('success', false, 'message', 'Invalid key', 'capabilities', json_build_array(), 'expires_at', null);
    end if;

    if v_license.expires_at is not null and v_license.expires_at <= now() then
        update public.licenses
        set status = 'expired', is_active = false, updated_at = now()
        where id = v_license.id;

        return json_build_object('success', false, 'message', 'Key expired', 'capabilities', json_build_array(), 'expires_at', v_license.expires_at);
    end if;

    if v_license.status in ('paused', 'blocked', 'expired') or v_license.is_active = false then
        return json_build_object(
            'success', false,
            'message', public.license_status_message(v_license.status),
            'capabilities', json_build_array(),
            'expires_at', v_license.expires_at
        );
    end if;

    if v_license.status <> 'active' or v_license.device_id is null then
        return json_build_object('success', false, 'message', 'Key is not active on this device', 'capabilities', json_build_array(), 'expires_at', v_license.expires_at);
    end if;

    if v_license.device_id <> v_device then
        return json_build_object('success', false, 'message', 'This key is already used on another device', 'capabilities', json_build_array(), 'expires_at', v_license.expires_at);
    end if;

    return json_build_object(
        'success', true,
        'message', 'Key verified',
        'capabilities', coalesce(v_license.capabilities, '[]'::jsonb),
        'expires_at', v_license.expires_at
    );
end;
$$;

revoke all on function public.activate_license(text, text) from public;
revoke all on function public.check_license(text, text) from public;
grant execute on function public.activate_license(text, text) to anon, authenticated;
grant execute on function public.check_license(text, text) to anon, authenticated;
