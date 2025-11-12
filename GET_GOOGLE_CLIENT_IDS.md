# 🔑 Encontrar Google OAuth Client IDs

## 🎯 **Problema Resolvido:**
O código agora detecta o ambiente e usa o Client ID correto, mas precisamos dos IDs para staging e production.

## 📋 **Como encontrar os Client IDs:**

### **1. Staging (717241670214):**
```
https://console.cloud.google.com/apis/credentials?project=717241670214
```

### **2. Production (595593582051):**
```
https://console.cloud.google.com/apis/credentials?project=595593582051
```

### **3. Development (703867063585) - Já temos:**
```
703867063585-gb6532om5hk31uij4nr9jdscric9da89.apps.googleusercontent.com
```

## 🛠️ **Passos para obter os Client IDs:**

### **Para cada projeto (Staging e Prod):**

1. **Acesse o Google Cloud Console** do projeto
2. **Vá para:** APIs & Services → Credentials
3. **Procure por:** "OAuth 2.0 Client IDs"
4. **Encontre o Client ID para Web application**
5. **Copie o Client ID** (formato: XXXXX-XXXXX.apps.googleusercontent.com)

### **Se não existir OAuth Client ID:**

1. **Clique em "Create Credentials" → OAuth client ID**
2. **Application type:** Web application
3. **Name:** "PadelArena Web Client" (ou similar)
4. **Authorized JavaScript origins:**
   ```
   # Para Staging:
   https://padel03-staging.web.app
   https://padel03-staging.firebaseapp.com
   
   # Para Production:
   https://padel03-prod.web.app
   https://padel03-prod.firebaseapp.com
   ```
5. **Authorized redirect URIs:**
   ```
   # Para Staging:
   https://padel03-staging.web.app/__/auth/handler
   https://padel03-staging.firebaseapp.com/__/auth/handler
   
   # Para Production:
   https://padel03-prod.web.app/__/auth/handler
   https://padel03-prod.firebaseapp.com/__/auth/handler
   ```

## 📝 **Atualizar o código:**

Depois de obter os Client IDs, substitua no arquivo:
`lib/services/auth_service.dart`

```dart
static String _getGoogleClientId() {
  switch (AppConfig.environment) {
    case Environment.dev:
      return '703867063585-gb6532om5hk31uij4nr9jdscric9da89.apps.googleusercontent.com';
    case Environment.staging:
      return 'SEU_STAGING_CLIENT_ID_AQUI.apps.googleusercontent.com';
    case Environment.prod:
      return 'SEU_PROD_CLIENT_ID_AQUI.apps.googleusercontent.com';
  }
}
```

## 🚀 **Teste após configuração:**

1. **Rebuild e deploy:** `./deploy.sh stg`
2. **Teste login:** https://padel03-staging.web.app
3. **Verificar se não há mais erro 400**

---
📋 **Next Steps:**
1. Encontrar os Client IDs para staging e prod
2. Atualizar o código com os IDs corretos
3. Fazer deploy
4. Testar login em todos os ambientes