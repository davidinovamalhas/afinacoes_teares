# Afinações de Teares — app web (PC + Android)

Ficheiros: `index.html` (a app), `config.js` (as tuas chaves), `schema.sql` (base de dados),
`manifest.json` + `sw.js` + `icon-*.png` (instalação como app no Android/PC).

## 1. Supabase
1. Usa um projecto existente ou cria um novo em supabase.com.
2. **SQL Editor → New query** → colar todo o `schema.sql` → **Run**.
   (cria a tabela `teares_afinacoes`, e as regras de segurança).
3. **Authentication → Users → Add user** → e-mail + palavra-passe (marcar *Auto Confirm*).
   Desactivar registos públicos: Authentication → Sign In / Providers → Email → desligar "Allow new users to sign up".
4. **Project Settings → API**: copiar *Project URL* e a chave *anon public*.
5. Editar `config.js` e colar os dois valores (e o nome da empresa).

## 2. GitHub + GitHub Pages
```bash
cd malhas-teares-app
git init
git add .
git commit -m "Afinações de teares"
git branch -M main
git remote add origin https://github.com/O_TEU_UTILIZADOR/afinacoes-teares.git
git push -u origin main
```
(cria antes o repositório vazio em github.com/new)
Depois: **Settings → Pages → Branch: main / (root) → Save**. Em ~1 min fica em
`https://O_TEU_UTILIZADOR.github.io/afinacoes-teares/`.

A *anon key* pode ficar no repositório (é pública por desenho); a protecção está nas regras RLS + login.
Nunca colocar a `service_role` key.

## 3. Instalar
- **Android (Chrome):** abrir o link → menu ⋮ → *Instalar aplicação*.
- **PC (Chrome/Edge):** ícone de instalar na barra de endereço.

## 4. Passar os dados do Excel
Entrar na app → **Ferramentas → Importar do Excel** → escolher o `.xlsx`. Não duplica registos já importados.
