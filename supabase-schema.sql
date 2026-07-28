-- R.Rui 创作者工作台 Supabase 云同步表
-- 使用方法：
-- 1. 打开 Supabase 项目
-- 2. 进入 SQL Editor
-- 3. 粘贴并运行本文件全部内容
-- 4. 在 Authentication 里开启 Email 登录

create table if not exists public.workbench_states (
  user_id uuid primary key references auth.users(id) on delete cascade,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.workbench_states enable row level security;

drop policy if exists "用户只能查看自己的工作台数据" on public.workbench_states;
create policy "用户只能查看自己的工作台数据"
on public.workbench_states
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "用户只能新增自己的工作台数据" on public.workbench_states;
create policy "用户只能新增自己的工作台数据"
on public.workbench_states
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "用户只能更新自己的工作台数据" on public.workbench_states;
create policy "用户只能更新自己的工作台数据"
on public.workbench_states
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "用户只能删除自己的工作台数据" on public.workbench_states;
create policy "用户只能删除自己的工作台数据"
on public.workbench_states
for delete
to authenticated
using (auth.uid() = user_id);

create or replace function public.set_workbench_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_workbench_states_updated_at on public.workbench_states;
create trigger set_workbench_states_updated_at
before update on public.workbench_states
for each row
execute function public.set_workbench_updated_at();
