# 🔧 CORREÇÃO URGENTE: redirect_uri_mismatch

## 🚨 **Problema Atual:**
```
Error 400: redirect_uri_mismatch
project-717241670214's request is invalid
```

## 🎯 **Solução: Configurar URIs de Redirect no Google Cloud Console**

### **PASSO 1: Acesse o Google Cloud Console do Staging**
```
https://console.cloud.google.com/apis/credentials?project=717241670214
```

### **PASSO 2: Encontre o OAuth Client ID**
Procure por:
```
Client ID: 717241670214-2s9ul6fafuf247esrc71csm33h8jg6tk.apps.googleusercontent.com
```

### **PASSO 3: Edite a Configuração**
1. **Clique no Client ID** para editar
2. **Em "Authorized JavaScript origins"** adicione:
   ```
   https://padel03-staging.web.app
   https://padel03-staging.firebaseapp.com
   http://localhost:8989
   ```

3. **Em "Authorized redirect URIs"** adicione:
   ```
   https://padel03-staging.web.app/__/auth/handler
   https://padel03-staging.firebaseapp.com/__/auth/handler
   http://localhost:8989/__/auth/handler
   ```

### **PASSO 4: Salvar e Aguardar**
- **Clique "Save"**
- **Aguarde 5-10 minutos** para propagação

## 🔍 **Verificação Visual no Console:**

Você deve ver algo assim:

```
OAuth 2.0 Client ID
Name: Web client (auto created by Google Service)
Client ID: 717241670214-2s9ul6fafuf247esrc71csm33h8jg6tk.apps.googleusercontent.com

Authorized JavaScript origins:
✅ https://padel03-staging.web.app
✅ https://padel03-staging.firebaseapp.com
✅ http://localhost:8989

Authorized redirect URIs:
✅ https://padel03-staging.web.app/__/auth/handler
✅ https://padel03-staging.firebaseapp.com/__/auth/handler
✅ http://localhost:8989/__/auth/handler
```

## 🚀 **Teste Após Configuração:**

1. **Aguarde 5-10 minutos** após salvar
2. **Limpe cache** do navegador (Ctrl+Shift+Del)
3. **Acesse**: https://padel03-staging.web.app
4. **Teste Google Sign-In** novamente

## ⚡ **Se o problema persistir:**

Verifique se:
- [ ] OAuth Client ID está correto no código
- [ ] URIs de redirect estão exatamente como mostrado acima
- [ ] Aguardou tempo suficiente para propagação
- [ ] Cache do navegador foi limpo

---
🔗 **Link direto para configuração:**
https://console.cloud.google.com/apis/credentials/oauthclient/717241670214-2s9ul6fafuf247esrc71csm33h8jg6tk.apps.googleusercontent.com?project=717241670214