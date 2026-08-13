-- =============================================================
--  SIPATMIN 2026 · Gincana — migração de 13/08/2026
--  Rode este script UMA VEZ no SQL Editor do Supabase
--  (projeto feoxwjsziizfnswqqelt), ANTES de usar o app novo.
--
--  O que faz:
--   1) Novas colunas em sg_envios: descricao (agora é salva) e
--      notas das missões (nota_entrega + nota_complementar).
--   2) Renomeia os grupos nos cadastros e envios existentes:
--        Beneficiamento e seus parceiros  -> Guardiões da Planta
--        Mina e seus parceiros            -> Guardiões da Mina
--        GAF, PCP, RH & Facilities, ...   -> Gente que Protege
-- =============================================================

-- 1) Novas colunas
alter table sg_envios add column if not exists descricao text not null default '';
alter table sg_envios add column if not exists nota_entrega int;
alter table sg_envios add column if not exists nota_complementar int;
-- Missão 03: marca dos 3 melhores vídeos (+50 pts cada, lançado pelo admin)
alter table sg_envios add column if not exists melhor_video boolean not null default false;

-- 2) Renomear grupos nos perfis
update sg_perfis set grupo = 'Guardiões da Planta'
 where grupo = 'Beneficiamento e seus parceiros';
update sg_perfis set grupo = 'Guardiões da Mina'
 where grupo = 'Mina e seus parceiros';
update sg_perfis set grupo = 'Gente que Protege'
 where grupo = 'GAF, PCP, RH & Facilities, SSMA e Serviços Técnicos';

-- 3) Renomear grupos nos envios (hoje não há nenhum, mas fica garantido)
update sg_envios set grupo = 'Guardiões da Planta'
 where grupo = 'Beneficiamento e seus parceiros';
update sg_envios set grupo = 'Guardiões da Mina'
 where grupo = 'Mina e seus parceiros';
update sg_envios set grupo = 'Gente que Protege'
 where grupo = 'GAF, PCP, RH & Facilities, SSMA e Serviços Técnicos';

-- Conferência: deve listar apenas os 3 grupos novos
select grupo, count(*) from sg_perfis group by grupo;
