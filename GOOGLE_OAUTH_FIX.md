# 🔧 Resolver Erro: redirect_uri_mismatch

## 🚨 **Problema Identificado:**
```
Error 400: redirect_uri_mismatch
project-703867063585's request is invalid
```

### **📋 Análise:**
- `703867063585` = `padel03-dev` (Development)
- `717241670214` = `padel03-staging` (Staging)
- O erro indica que o Google OAuth está usando configs do DEV no ambiente STAGING

## 🛠️ **Solução: Configurar Google Cloud Console**

### **1. Acesse Google Cloud Console para STAGING**
```
https://console.cloud.google.com/apis/credentials?project=717241670214
```

### **2. Configure OAuth 2.0 Client IDs**

#### **Para Web Application:**
- **Authorized JavaScript origins:**
  ```
  https://padel03-staging.web.app
  https://padel03-staging.firebaseapp.com
  http://localhost:8989 (para testes locais)
  ```

- **Authorized redirect URIs:**
  ```
  https://padel03-staging.web.app/__/auth/handler
  https://padel03-staging.firebaseapp.com/__/auth/handler
  http://localhost:8989/__/auth/handler
  ```

### **3. Repetir para TODOS os projetos:**

#### **Development (703867063585):**
```
https://console.cloud.google.com/apis/credentials?project=703867063585

Origins:
- https://padel03-dev.web.app
- https://padel03-dev.firebaseapp.com
- http://localhost:8989

Redirect URIs:
- https://padel03-dev.web.app/__/auth/handler
- https://padel03-dev.firebaseapp.com/__/auth/handler
- http://localhost:8989/__/auth/handler
```

#### **Production (595593582051):**
```
https://console.cloud.google.com/apis/credentials?project=595593582051

Origins:
- https://padel03-prod.web.app
- https://padel03-prod.firebaseapp.com
- http://localhost:8989

Redirect URIs:
- https://padel03-prod.web.app/__/auth/handler
- https://padel03-prod.firebaseapp.com/__/auth/handler
- http://localhost:8989/__/auth/handler
```

## 🔍 **Verificação Adicional:**

### **1. Firebase Authentication Settings**
Cada projeto deve ter seus domínios autorizados:

#### **Staging:**
```
https://console.firebase.google.com/project/padel03-staging/authentication/settings

Authorized domains:
- padel03-staging.web.app
- padel03-staging.firebaseapp.com
- localhost
```

### **2. Verificar Provider Configuration**
```
Firebase Console → Authentication → Sign-in method → Google

Verificar se cada projeto tem:
- Google Sign-in habilitado
- Web SDK configuration correto
- Support email configurado
```

## 🚀 **Teste Após Configuração:**

1. **Limpar cache do navegador** (Ctrl+Shift+Del)
2. **Acessar**: https://padel03-staging.web.app
3. **Tentar login com Google**
4. **Verificar se não há mais erro 400**

## 📋 **Checklist Completo:**

### **Para cada ambiente (Dev/Staging/Prod):**
- [ ] Google Cloud Console OAuth configurado
- [ ] Firebase Authentication domains autorizados
- [ ] Google Sign-in provider habilitado
- [ ] Web SDK configuration atualizado
- [ ] Teste de login funcionando

### **URLs de Configuração Rápida:**
- **Dev**: https://console.cloud.google.com/apis/credentials?project=703867063585
- **Staging**: https://console.cloud.google.com/apis/credentials?project=717241670214
- **Prod**: https://console.cloud.google.com/apis/credentials?project=595593582051

---
⚠️ **Importante:** Pode levar alguns minutos para as mudanças no Google Cloud Console fazerem efeito.