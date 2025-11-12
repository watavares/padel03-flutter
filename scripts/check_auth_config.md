# Diagnóstico de Configuração de Autenticação

## Status Atual
- ✅ Ambiente: Staging (padel03-staging)
- ✅ URL: https://padel03-staging.web.app
- ✅ Google OAuth Client ID: 717241670214-2s9ul6fafuf247esrc71csm33h8jg6tk.apps.googleusercontent.com
- ❌ People API: Precisa ser habilitada

## Problemas Identificados

### 1. People API não habilitada
**Erro:** `People API has not been used in project 717241670214 before or it is disabled`

**Solução:**
1. Abrir: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=717241670214
2. Clicar em "ENABLE"
3. Aguardar ativação (pode levar alguns minutos)

### 2. Popup fechado prematuramente
**Erro:** `popup_closed`

**Causa:** Usuário fecha o popup ou timeout

**Melhorias implementadas:**
- ✅ Logs detalhados de debug
- ✅ Verificação de cancelamento pelo usuário
- ✅ Tratamento de erros mais robusto

## Configuração OAuth Necessária

### Domínios Autorizados
No Google Console (https://console.cloud.google.com/apis/credentials), certifique-se de que estão configurados:

**JavaScript origins:**
- https://padel03-staging.web.app
- http://localhost (para desenvolvimento)

**Redirect URIs:**
- https://padel03-staging.web.app/__/auth/handler

## Teste Manual
1. Habilitar People API
2. Fazer deploy das mudanças
3. Testar Google Sign-In
4. Verificar console logs

## Próximos Passos
1. [ ] Habilitar People API no projeto 717241670214
2. [ ] Verificar domínios autorizados no OAuth
3. [ ] Testar autenticação
4. [ ] Aplicar mesma configuração para produção