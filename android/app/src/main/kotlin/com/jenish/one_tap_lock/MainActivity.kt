package com.jenish.one_tap_lock

import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "one_tap_lock/setup")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isReady" -> result.success(LockService.isReady)
                    "openSettings" -> try {
                        startActivity(Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS))
                        result.success(null)
                    } catch (_: RuntimeException) {
                        result.error("settings_unavailable", "Open Settings > Accessibility manually.", null)
                    }
                    "closeSetup" -> { result.success(null); finishAndRemoveTask() }
                    else -> result.notImplemented()
                }
            }
    }
}
