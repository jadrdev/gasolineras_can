# Solución de Problemas de Autenticación

## Error: "Error sending confirmation email" (Código 500)

### Problema
Supabase no puede enviar el email de confirmación durante el registro de usuarios.

### Causas Comunes
1. **Límites del plan gratuito**: Supabase limita el envío de emails en el plan gratuito
2. **Configuración de SMTP no configurada**: No hay proveedor de email configurado
3. **Dominio no verificado**: Si usas un dominio personalizado
4. **Problema temporal del servicio**: Problemas momentáneos de Supabase

### Soluciones

#### Solución 1: Deshabilitar confirmación por email (Desarrollo)

**Pasos en Supabase Dashboard:**
1. Ve a [https://app.supabase.com](https://app.supabase.com)
2. Selecciona tu proyecto
3. Ve a **Authentication** → **Providers**
4. Haz clic en **Email**
5. **Desactiva** la opción **"Enable email confirmations"**
6. Guarda los cambios

**Ventajas:**
- ✅ Registro inmediato sin esperar email
- ✅ Ideal para desarrollo y pruebas
- ✅ No requiere configuración adicional

**Desventajas:**
- ⚠️ Menos seguro para producción
- ⚠️ Usuarios no verifican su email

#### Solución 2: Configurar proveedor SMTP propio (Producción)

Para entornos de producción, configura tu propio servicio de email:

1. Ve a **Settings** → **Authentication**
2. En la sección **SMTP Settings**, configura:
   - **Sender email**: tu-email@tudominio.com
   - **Sender name**: Nombre de tu app
   - **Host**: smtp.tuproveedor.com
   - **Port**: 587 o 465
   - **Username**: tu usuario SMTP
   - **Password**: tu contraseña SMTP

**Proveedores recomendados:**
- SendGrid (gratuito hasta 100 emails/día)
- Mailgun (gratuito hasta 5,000 emails/mes)
- Amazon SES (muy económico)
- Resend (moderno y fácil de usar)

#### Solución 3: Registro sin confirmación + verificación posterior

Otra opción es permitir el registro sin confirmación pero solicitar verificación para ciertas funciones:

```dart
// En tu lógica de negocio
if (user.emailConfirmedAt == null) {
  // Mostrar banner o modal pidiendo confirmar email
  showVerificationReminder(context);
}
```

### Verificar el Estado Actual

Para saber si la confirmación por email está habilitada:

1. Dashboard → Authentication → Providers → Email
2. Busca **"Enable email confirmations"**
3. Si está activado ✅ = requiere confirmación
4. Si está desactivado ⬜ = no requiere confirmación

### Probar el Registro

Después de hacer cambios, prueba el registro:

```bash
# Hot reload de la app
# El código ya está actualizado para manejar mejor los errores
r
```

### Mensajes de Error Mejorados

El código ahora muestra mensajes más claros:

- ✅ **Registro exitoso**: "¡Registro exitoso! Si la confirmación por email está habilitada, revisa tu bandeja de entrada. En caso contrario, ya puedes iniciar sesión."
  
- ❌ **Error de email**: "No se pudo enviar el email de confirmación. Por favor, contacta al administrador o desactiva la confirmación por email en Supabase."

### Recursos Adicionales

- [Documentación de Supabase Auth](https://supabase.com/docs/guides/auth)
- [Configuración SMTP en Supabase](https://supabase.com/docs/guides/auth/auth-smtp)
- [Email Templates en Supabase](https://supabase.com/docs/guides/auth/auth-email-templates)

### Notas de Desarrollo vs Producción

| Aspecto | Desarrollo | Producción |
|---------|------------|------------|
| Confirmación email | ❌ Deshabilitada | ✅ Habilitada |
| Proveedor SMTP | Integrado de Supabase | SMTP propio |
| URL de redirección | localhost:3000 | dominio.com |
| Seguridad | Relajada | Estricta |

---

**Última actualización:** Abril 2026
