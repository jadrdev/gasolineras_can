# Configuración de Supabase para Desarrollo Local

## Configurar URL de Redirección para Localhost

Para que Supabase redirija a localhost durante el desarrollo (por ejemplo, después del registro), sigue estos pasos:

### 1. Acceder al Dashboard de Supabase

1. Ve a [https://app.supabase.com](https://app.supabase.com)
2. Inicia sesión con tu cuenta
3. Selecciona tu proyecto

### 2. Configurar URLs de Redirección

1. En el menú lateral, ve a **Authentication** → **URL Configuration**
2. En la sección **Redirect URLs**, añade las siguientes URLs:

   **Para desarrollo local:**
   ```
   http://localhost:3000/thank-you.html
   http://127.0.0.1:3000/thank-you.html
   ```

   **Para GitHub Pages (producción):**
   ```
   https://jadrdev.github.io/gasolineras_can/thank-you.html
   ```

3. Haz clic en **Save** para guardar los cambios

### 3. Configurar Email Templates (Opcional)

Si quieres personalizar el correo de confirmación:

1. Ve a **Authentication** → **Email Templates**
2. Selecciona **Confirm signup**
3. Modifica la URL de redirección en el template:
   ```
   {{ .ConfirmationURL }}
   ```

### 4. Actualizar el Código de Registro

En el archivo `auth_bloc.dart`, actualiza el método `register` para incluir la URL de redirección:

```dart
Future<void> register({
  required String email,
  required String password,
}) async {
  try {
    print('🔵 Intentando registrar usuario: $email');
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'http://localhost:3000/thank-you.html', // Para desarrollo
      // emailRedirectTo: 'https://jadrdev.github.io/gasolineras_can/thank-you.html', // Para producción
    );
    print('✅ Respuesta de registro: ${response.user?.id}');
    print('📧 Email confirmado: ${response.user?.emailConfirmedAt}');
    
    if (response.user != null) {
      print('✅ Usuario creado exitosamente');
    }
  } on AuthException catch (e) {
    print('❌ Error de autenticación: ${e.message}');
    print('❌ Código de error: ${e.statusCode}');
    add(AuthErrorEvent('Error: ${e.message}'));
  } catch (e) {
    print('❌ Error inesperado: $e');
    add(AuthErrorEvent("Error inesperado: $e"));
  }
}
```

### 5. Probar el Flujo de Registro

1. Inicia un servidor local en el directorio `docs`:
   ```bash
   cd docs
   python3 -m http.server 3000
   ```

2. Registra un nuevo usuario en la app

3. Revisa tu correo electrónico y haz clic en el enlace de confirmación

4. Deberías ser redirigido a `http://localhost:3000/thank-you.html`

### Notas Importantes

- **Desarrollo vs Producción**: Cambia la URL de redirección según el entorno
- **CORS**: Asegúrate de que las URLs estén permitidas en la configuración de CORS de Supabase
- **HTTPS**: En producción, siempre usa HTTPS para las URLs de redirección

### URLs de la Aplicación

- **Página de Gracias (Local)**: http://localhost:3000/thank-you.html
- **Página de Gracias (Producción)**: https://jadrdev.github.io/gasolineras_can/thank-you.html
- **Política de Privacidad**: https://jadrdev.github.io/gasolineras_can/privacy-policy.html
