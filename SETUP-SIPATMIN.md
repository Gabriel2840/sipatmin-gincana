# SIPATMIN 2026 · Gincana — do localStorage para placar único (Supabase)

O visual e o funcionamento são os mesmos do arquivo que já circulou. A diferença:
**todos veem o mesmo placar**, as senhas ficam protegidas no Supabase Auth e as
fotos de evidência sobem comprimidas para um bucket **privado — só o admin logado
consegue vê-las** (líderes veem "🔒 N foto(s)"). Vídeos/documentos continuam indo
pelo link do SharePoint.

## Passo a passo (~15 min)

1. **Criar o projeto** em https://supabase.com → New project (separado dos outros apps).

2. **Rodar o SQL**: SQL Editor → cole o conteúdo de `supabase-setup-sipatmin.sql` → Run.
   Cria as tabelas `sg_perfis` e `sg_envios`, o bucket privado `evidencias` e as
   políticas de segurança (RLS).

3. **Desligar a confirmação de e-mail** (os logins usam e-mails internos fictícios
   `login@sipatmin.aura`): Authentication → Sign In / Providers → Email →
   desmarque **Confirm email** → Save.

4. **Colar as chaves no app**: Project Settings → Data API →
   copie **Project URL** e **anon public key** e cole no topo do `<script>` do
   `index.html` (constantes `SUPABASE_URL` e `SUPABASE_ANON_KEY`).
   A chave anon é pública por design — a proteção vem do login + RLS.
   NUNCA use a chave `service_role` no app.

5. **Publicar** o `index.html` no MESMO link que o pessoal já acessa
   (GitHub Pages etc.), para ninguém precisar trocar de endereço.

6. **Criar o seu acesso e virar admin**: no app, clique **Criar cadastro** e crie
   seu login normalmente. Depois, no SQL Editor:

   ```sql
   update sg_perfis set perfil = 'admin' where login = 'SEU_LOGIN_AQUI';
   ```

   Deslogue e logue de novo. As abas **Aprovações** e **Usuários** aparecem.

## Como fica o dia a dia

- Líderes criam o próprio cadastro (botão da tela inicial) — sempre entram como líder.
- Admin também cadastra usuários pela aba **Usuários** (inclusive outros admins) e exclui acessos.
- Envios de atividade aparecem para o admin aprovar/reprovar de qualquer aparelho; o
  Painel TV atualiza sozinho a cada 30 s.
- Fotos: sobem comprimidas (máx. 1600 px, JPEG) para o bucket privado. Limite do
  plano gratuito: 1 GB (~3–4 mil fotos). Vídeos/PDFs: link do SharePoint.

## Atenção (dados que já existem)

Os cadastros e envios feitos na versão antiga ficaram presos no navegador de cada
pessoa (localStorage) — não migram sozinhos. Todo mundo precisa **criar o cadastro
de novo** no ar novo. Se houver envios importantes na máquina "oficial", me chame
que eu faço um botão de importação.
