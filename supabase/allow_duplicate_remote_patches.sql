drop index if exists public.remote_content_files_target_path_idx;
drop index if exists public.remote_content_files_target_bundle_path_idx;

create index if not exists remote_content_files_target_bundle_path_idx
on public.remote_content_files (target_bundle, target_path)
where deleted_at is null;

drop function if exists public.admin_upsert_remote_content_file(text, text, text, text, text, bigint, text, text, text, uuid);
drop function if exists public.admin_upsert_remote_content_file(text, text, text, text, text, text, bigint, text, text, text, uuid);
drop function if exists public.admin_upsert_remote_content_file(text, text, text, text, text, text, text, bigint, text, text, text, uuid);
drop function if exists public.admin_upsert_remote_content_file(text, text, text, text, text, text, text, bigint, text, text, text, uuid, boolean);

create or replace function public.admin_upsert_remote_content_file(
    p_name text,
    p_slug text,
    p_category text,
    p_target_bundle text,
    p_target_path text,
    p_file_name text,
    p_mime_type text,
    p_byte_size bigint,
    p_sha256 text,
    p_storage_path text,
    p_description text default null,
    p_id uuid default null,
    p_force_new boolean default false
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
    v_name text := nullif(trim(coalesce(p_name, '')), '');
    v_slug text := public.remote_content_safe_slug(p_slug, p_name);
    v_category text := public.remote_content_safe_slug(coalesce(p_category, 'files'), 'files');
    v_target_bundle text := public.remote_content_safe_bundle(p_target_bundle);
    v_file_name text := nullif(trim(coalesce(p_file_name, '')), '');
    v_target_path text := public.remote_content_safe_path(p_target_path, p_category, p_file_name);
    v_mime_type text := nullif(trim(coalesce(p_mime_type, '')), '');
    v_storage_path text := trim(coalesce(p_storage_path, ''));
    v_sha text := lower(trim(coalesce(p_sha256, '')));
    v_file public.remote_content_files%rowtype;
    v_base_slug text;
    v_suffix integer := 2;
begin
    if not public.is_license_admin() then
        raise exception 'Not authorized';
    end if;

    if v_name is null or v_file_name is null then
        raise exception 'Name and file name are required';
    end if;

    if coalesce(p_byte_size, -1) < 0 then
        raise exception 'Invalid file size';
    end if;

    if v_sha !~ '^[a-f0-9]{64}$' then
        raise exception 'Invalid SHA-256';
    end if;

    if v_storage_path = ''
       or v_storage_path like '/%'
       or v_storage_path !~ '^content/'
       or v_storage_path ~ '(^|/)\.\.(/|$)' then
        raise exception 'Invalid storage path';
    end if;

    if p_id is not null then
        select *
        into v_file
        from public.remote_content_files
        where id = p_id
        limit 1
        for update;
    elsif not coalesce(p_force_new, false) then
        select *
        into v_file
        from public.remote_content_files
        where slug = v_slug
        order by updated_at desc
        limit 1
        for update;
    end if;

    if found then
        update public.remote_content_files
        set
            slug = v_slug,
            name = v_name,
            description = nullif(trim(coalesce(p_description, '')), ''),
            category = v_category,
            target_bundle = v_target_bundle,
            target_path = v_target_path,
            version = v_file.version + 1,
            storage_path = v_storage_path,
            file_name = v_file_name,
            mime_type = v_mime_type,
            byte_size = p_byte_size,
            sha256 = v_sha,
            is_active = true,
            deleted_at = null,
            updated_at = now()
        where id = v_file.id
        returning * into v_file;
    else
        v_base_slug := v_slug;
        while exists (
            select 1
            from public.remote_content_files
            where slug = v_slug
        ) loop
            v_slug := left(v_base_slug, greatest(1, 80 - length('-' || v_suffix::text)))
                || '-'
                || v_suffix::text;
            v_suffix := v_suffix + 1;
        end loop;

        insert into public.remote_content_files (
            slug,
            name,
            description,
            category,
            target_bundle,
            target_path,
            version,
            storage_path,
            file_name,
            mime_type,
            byte_size,
            sha256,
            is_active,
            created_by
        )
        values (
            v_slug,
            v_name,
            nullif(trim(coalesce(p_description, '')), ''),
            v_category,
            v_target_bundle,
            v_target_path,
            1,
            v_storage_path,
            v_file_name,
            v_mime_type,
            p_byte_size,
            v_sha,
            true,
            auth.uid()
        )
        returning * into v_file;
    end if;

    return jsonb_build_object(
        'success', true,
        'message', 'File saved. Publish changes when ready.',
        'file', to_jsonb(v_file)
    );
end;
$$;

revoke all on function public.admin_upsert_remote_content_file(text, text, text, text, text, text, text, bigint, text, text, text, uuid, boolean) from public;
grant execute on function public.admin_upsert_remote_content_file(text, text, text, text, text, text, text, bigint, text, text, text, uuid, boolean) to authenticated;
