package com.example.zencillo_redeban

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import org.json.JSONObject

/** ZencilloRedebanPlugin */
class ZencilloRedebanPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    PluginRegistry.ActivityResultListener {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    companion object {
        private const val CHANNEL_NAME = "zencillo_redeban"

        private const val CHANNEL_REDEBAN = 1001
        private const val CHANNEL_REDEBAN_ANULACION = 10011

        private const val REDEBAN_PACKAGE =
            "rbm.pax.wimobile.com.rbmappcomercioswm"

        private const val REDEBAN_ACTIVITY =
            "rbm.pax.wimobile.com.rbmappcomercios.features.mainmenu.ui.MainMenuActivity"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "isInstalled" -> {
                result.success(isPackageInstalled(REDEBAN_PACKAGE))
            }

            "redeban" -> {
                if (!isPackageInstalled(REDEBAN_PACKAGE)) {
                    result.error(
                        "Solicitud cancelada!",
                        "La Aplicación no se encuentra instalada.",
                        null
                    )
                    return
                }

                pendingResult = result

                val amount = call.argument<String>("amount") ?: "0"
                val tax = call.argument<String>("tax") ?: "0"

                launchRedeban(
                    amount.toDouble().toInt(),
                    tax.toDouble().toInt()
                )
            }

            "redebanAnulacion" -> {
                if (!isPackageInstalled(REDEBAN_PACKAGE)) {
                    result.error(
                        "Solicitud cancelada!",
                        "La Aplicación no se encuentra instalada.",
                        null
                    )
                    return
                }

                pendingResult = result

                val numeroRecibo = call.argument<String>("numeroRecibo") ?: ""
                val claveSupervisor = call.argument<String>("claveSupervisor") ?: ""

                launchRedebanAnulacion(
                    numeroRecibo,
                    claveSupervisor
                )
            }

            else -> result.notImplemented()
        }
    }

    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ): Boolean {
        when (requestCode) {
            CHANNEL_REDEBAN -> {
                try {
                    val output = data?.getStringExtra("data_output") ?: ""
                    Log.e("OUTPUT", output)
                    pendingResult?.success(output)
                } catch (e: Exception) {
                    Log.e("ERROR", "Error al procesar el pago: ${e.message}", e)
                    pendingResult?.error("FAILED", "Error: ${e.message}", null)
                }
            }

            CHANNEL_REDEBAN_ANULACION -> {
                try {
                    val output = data?.getStringExtra("data_output") ?: ""
                    Log.e("OUTPUT_ANULACION_REDEBAN", output)
                    pendingResult?.success(output)
                } catch (e: Exception) {
                    Log.e("ERROR", "Error al procesar la anulación: ${e.message}", e)
                    pendingResult?.error("FAILED", "Error: ${e.message}", null)
                }
            }

            else -> return false
        }

        pendingResult = null
        return true
    }

    private fun launchRedeban(amount: Int, iva: Int) {
        val currentActivity = activity

        if (currentActivity == null) {
            pendingResult?.error("NO_ACTIVITY", "No hay Activity disponible.", null)
            return
        }

        val subTotal = amount - iva

        val adjustedIva = if (iva <= 0) 0 else iva
        val adjustedSubtotal = if (iva <= 0) 0 else subTotal

        val saleJson = JSONObject()
        saleJson.put("TipoTransaccion", "1")

        val paramsJson = JSONObject()
        paramsJson.put("Monto", amount)
        paramsJson.put("Iva", adjustedIva)
        paramsJson.put("Inc", 0)
        paramsJson.put("Monto_base_iva", adjustedSubtotal)
        paramsJson.put("Monto_base_inc", 0)
        paramsJson.put("Base_devolucion", adjustedSubtotal)

        saleJson.put("properties", paramsJson)

        val json = saleJson.toString()

        val component = ComponentName(
            REDEBAN_PACKAGE,
            REDEBAN_ACTIVITY
        )

        Log.d("ZencilloRedebanPlugin", "Formatted Amount: $json")

        val sendIntent = Intent(Intent.ACTION_SEND)
        sendIntent.component = component
        sendIntent.putExtra("data_input", json)
        sendIntent.putExtra("package", currentActivity.packageName)

        currentActivity.startActivityForResult(sendIntent, CHANNEL_REDEBAN)
    }

    private fun launchRedebanAnulacion(
        numeroRecibo: String,
        claveSupervisor: String
    ) {
        val currentActivity = activity

        if (currentActivity == null) {
            pendingResult?.error("NO_ACTIVITY", "No hay Activity disponible.", null)
            return
        }

        val jsonSale = JSONObject()
        jsonSale.put("TipoTransaccion", "2")

        val jsonProperties = JSONObject()
        jsonProperties.put("Numero_recibo", numeroRecibo)
        jsonProperties.put("Clave_supervisor", claveSupervisor)

        jsonSale.put("properties", jsonProperties)

        val json = jsonSale.toString()

        val component = ComponentName(
            REDEBAN_PACKAGE,
            REDEBAN_ACTIVITY
        )

        Log.d("ZencilloRedebanPlugin", "Redeban Anulacion JSON: $json")

        val sendIntent = Intent(Intent.ACTION_SEND)
        sendIntent.component = component
        sendIntent.putExtra("data_input", json)
        sendIntent.putExtra("package", currentActivity.packageName)

        currentActivity.startActivityForResult(
            sendIntent,
            CHANNEL_REDEBAN_ANULACION
        )
    }

    private fun isPackageInstalled(@NonNull packageName: String): Boolean {
        return try {
            context.packageManager.getApplicationInfo(packageName, 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }
    }
}