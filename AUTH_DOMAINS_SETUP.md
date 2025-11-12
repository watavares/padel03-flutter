# 🔐 Configuração de Firebase Authentication - Staging

## ⚡ Ação Necessária: Adicionar Domínios Autorizados

### 🎯 **Problema:**
O Firebase Authentication precisa dos domínios do staging para funcionar corretamente.

### 🛠️ **Solução:**

#### **1. Acesse o Firebase Console**
```
https://console.firebase.google.com/project/padel03-staging/authentication/settings
```

#### **2. Vá para Authentication → Settings → Authorized domains**

#### **3. Adicione estes domínios:**
```
✅ padel03-staging.web.app
✅ padel03-staging.firebaseapp.com
✅ localhost (para desenvolvimento local)
```

#### **4. Clique "Add domain" para cada um**

### 🔄 **Para todos os ambientes:**

#### **Development (padel03-dev):**
```
padel03-dev.web.app
padel03-dev.firebaseapp.com
localhost
```

#### **Staging (padel03-staging):**
```
padel03-staging.web.app
padel03-staging.firebaseapp.com
localhost
```

#### **Production (padel03-prod):**
```
padel03-prod.web.app
padel03-prod.firebaseapp.com
www.padelarena.com (se domínio customizado)
padelarena.com (se domínio customizado)
localhost
```

### 🧪 **Testar após configuração:**

1. Acesse: https://padel03-staging.web.app
2. Tente fazer login
3. Verificar se não há erros de domínio autorizado

### 🚨 **Erros Comuns:**
- **"auth/unauthorized-domain"** → Domínio não está na lista
- **"auth/invalid-api-key"** → Configuração do projeto incorreta

### 📋 **Checklist de Verificação:**
- [ ] Domínio staging adicionado
- [ ] Login funciona no staging
- [ ] Mesma configuração aplicada aos outros ambientes
- [ ] Teste em todos os ambientes

### 🔗 **Links Úteis:**
- Console Staging: https://console.firebase.google.com/project/padel03-staging
- Console Dev: https://console.firebase.google.com/project/padel03-dev  
- Console Prod: https://console.firebase.google.com/project/padel03-prod

---
📝 **Nota:** Esta configuração é necessária uma única vez por projeto. Depois de configurar, o Authentication funcionará normalmente em todos os domínios autorizados.