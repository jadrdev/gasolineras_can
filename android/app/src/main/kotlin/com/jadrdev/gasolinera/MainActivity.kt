package com.jadrdev.gasolinera

import android.content.ComponentName
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Icono alternativo de la app (regalo de «Invítame a un café»): cada icono
    // es un activity-alias del manifiesto y solo uno está activo.
    private val alias = mapOf(
        "original" to "IconoOriginal",
        "noche" to "IconoNoche",
        "naranja" to "IconoNaranja",
        "cafe" to "IconoCafe",
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "gasocan/icono")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "actual" -> result.success(iconoActual())
                    "cambiar" -> {
                        cambiarIcono(call.arguments as String? ?: "original")
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun componente(nombre: String) =
        ComponentName(packageName, "com.jadrdev.gasolinera.$nombre")

    private fun iconoActual(): String? {
        for ((icono, nombre) in alias) {
            val estado = packageManager.getComponentEnabledSetting(componente(nombre))
            val activo = estado == PackageManager.COMPONENT_ENABLED_STATE_ENABLED ||
                (estado == PackageManager.COMPONENT_ENABLED_STATE_DEFAULT && icono == "original")
            if (activo) return if (icono == "original") null else icono
        }
        return null
    }

    private fun cambiarIcono(icono: String) {
        val elegido = alias[icono] ?: return
        // Primero se activa el nuevo y luego se apagan los demás, para que
        // nunca se quede la app sin icono en el lanzador.
        packageManager.setComponentEnabledSetting(
            componente(elegido),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
        for (nombre in alias.values) {
            if (nombre == elegido) continue
            packageManager.setComponentEnabledSetting(
                componente(nombre),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }
    }
}
