-- =============================================================
--  SIPATMIN 2026 · Gincana — setup do Supabase
--  Rode este script inteiro no SQL Editor do projeto NOVO.
-- =============================================================

-- Perfis dos usuários (a senha fica no Supabase Auth, nunca aqui)
create table if not exists sg_perfis (
  uid uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  login text unique not null,
  perfil text not null default 'lider' check (perfil in ('lider','admin')),
  grupo text not null,
  time_nome text not null,
  criado timestamptz default now()
);
alter table sg_perfis enable row level security;

-- Checagem de admin em função SECURITY DEFINER (evita recursão de RLS)
create or replace function sg_is_admin() returns boolean
language sql security definer stable
set search_path = public
as $$
  select exists (select 1 from sg_perfis where uid = auth.uid() and perfil = 'admin');
$$;

create policy "perfis: leitura para todos"
  on sg_perfis for select using (true);

create policy "perfis: cada um cria o proprio (sempre como lider)"
  on sg_perfis for insert with check (auth.uid() = uid and perfil = 'lider');

create policy "perfis: admin cadastra qualquer usuario"
  on sg_perfis for insert with check (sg_is_admin());

create policy "perfis: admin exclui usuario"
  on sg_perfis for delete using (sg_is_admin());

-- Envios de atividades
create table if not exists sg_envios (
  id bigint primary key,
  ts bigint not null,
  uid uuid not null references auth.users(id),
  grupo text not null,
  time_nome text not null,
  usuario text not null,
  categoria text not null,
  atividade text not null,
  quantidade int not null check (quantidade > 0),
  total int not null,
  data date,
  local text,
  responsavel text,
  evidencias jsonb not null default '[]', -- caminhos das fotos no bucket privado
  arquivos jsonb not null default '[]',   -- nomes de vídeos/documentos (conteúdo vai pelo SharePoint)
  sharepoint text default '',
  status text not null default 'aguardando' check (status in ('aguardando','aprovada','reprovada')),
  motivo text not null default ''
);
alter table sg_envios enable row level security;

create policy "envios: leitura para todos"
  on sg_envios for select using (true);

create policy "envios: logado insere em nome proprio, sempre aguardando"
  on sg_envios for insert with check (auth.uid() = uid and status = 'aguardando');

create policy "envios: so admin aprova/reprova"
  on sg_envios for update using (sg_is_admin());

-- Bucket PRIVADO de evidências (fotos comprimidas pelo app).
-- Qualquer líder logado envia; SÓ o administrador consegue ver
-- (o app gera URLs assinadas, e a assinatura exige esta permissão).
insert into storage.buckets (id, name, public)
values ('evidencias', 'evidencias', false)
on conflict (id) do nothing;

create policy "evidencias: upload por logado"
  on storage.objects for insert
  with check (bucket_id = 'evidencias' and auth.role() = 'authenticated');

create policy "evidencias: leitura so admin"
  on storage.objects for select
  using (bucket_id = 'evidencias' and public.sg_is_admin());

-- Privilégios básicos dos papéis do PostgREST (RLS sozinho não basta:
-- sem estes GRANTs o banco devolve "permission denied for table").
grant usage on schema public to anon, authenticated;
grant select on public.sg_perfis to anon, authenticated;
grant insert, delete on public.sg_perfis to authenticated;
grant select on public.sg_envios to anon, authenticated;
grant insert, update on public.sg_envios to authenticated;
grant execute on function public.sg_is_admin() to anon, authenticated;

-- =============================================================
--  DEPOIS de criar o seu usuário pelo app (botão "Criar cadastro"),
--  promova-o a administrador trocando o login abaixo:
--
--    update sg_perfis set perfil = 'admin' where login = 'iuri';
-- =============================================================
