-- =====================================================================
--  AFINAÇÕES DE TEARES CIRCULARES  –  schema Supabase
--  Colar no  SQL Editor  do Supabase e executar (é seguro voltar a correr).
-- =====================================================================

-- 1) Registos de afinação (um por linha do Excel) -----------------------
create table if not exists public.teares_afinacoes (
  id          uuid primary key default gen_random_uuid(),
  tipo        text   not null,           -- felpa | jersey | pique | rib | dupla | interlock | italiana
  tear        int    not null,           -- Nº do tear
  data        date   not null,
  cliente     text   not null,
  dados       jsonb  not null default '{}'::jsonb,   -- campos específicos de cada tipo de malha
  observacoes text,
  criado_por  uuid default auth.uid(),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
create index if not exists teares_afinacoes_tipo_idx    on public.teares_afinacoes (tipo);
create index if not exists teares_afinacoes_tear_idx    on public.teares_afinacoes (tear);
create index if not exists teares_afinacoes_data_idx    on public.teares_afinacoes (data desc);
create index if not exists teares_afinacoes_cliente_idx on public.teares_afinacoes (cliente);

-- 2) Anexos (imagens / PDF da malha) -----------------------------------
create table if not exists public.teares_anexos (
  id           uuid primary key default gen_random_uuid(),
  afinacao_id  uuid not null references public.teares_afinacoes(id) on delete cascade,
  path         text not null,            -- caminho no Storage
  nome         text,
  mime         text,
  legenda      text,
  created_at   timestamptz not null default now()
);
create index if not exists teares_anexos_afinacao_idx on public.teares_anexos (afinacao_id);

-- 3) updated_at automático ----------------------------------------------
create or replace function public.teares_set_updated_at() returns trigger
language plpgsql as $$ begin new.updated_at = now(); return new; end $$;
drop trigger if exists teares_afinacoes_upd on public.teares_afinacoes;
create trigger teares_afinacoes_upd before update on public.teares_afinacoes
  for each row execute function public.teares_set_updated_at();

-- 4) Segurança (RLS) – só utilizadores com sessão iniciada ---------------
alter table public.teares_afinacoes enable row level security;
alter table public.teares_anexos    enable row level security;

drop policy if exists "teares_afinacoes_auth_all" on public.teares_afinacoes;
create policy "teares_afinacoes_auth_all" on public.teares_afinacoes
  for all to authenticated using (true) with check (true);

drop policy if exists "teares_anexos_auth_all" on public.teares_anexos;
create policy "teares_anexos_auth_all" on public.teares_anexos
  for all to authenticated using (true) with check (true);

-- 5) Storage: bucket PRIVADO para os anexos ------------------------------
insert into storage.buckets (id, name, public)
values ('teares-anexos', 'teares-anexos', false)
on conflict (id) do nothing;

drop policy if exists "teares_anexos_storage_all" on storage.objects;
create policy "teares_anexos_storage_all" on storage.objects
  for all to authenticated
  using (bucket_id = 'teares-anexos') with check (bucket_id = 'teares-anexos');

-- NOTA: se este projecto Supabase tem outras apps com utilizadores próprios,
-- qualquer utilizador autenticado do projecto vê estes dados. Para restringir,
-- substituir "using (true)" por uma condição (ex.: lista de e-mails ou tabela de perfis).
