package com.jenish.one_tap_lock

import android.app.Activity
import android.app.KeyguardManager
import android.content.Intent
import android.os.Bundle

// A separate, disposable task means a successful tap never starts Flutter.
class LauncherActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Recreation is not another explicit icon tap.
        if (savedInstanceState == null) handleTap() else finish()
    }
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleTap()
    }
    private fun handleTap() {
        val locked = getSystemService(KeyguardManager::class.java).isKeyguardLocked
        if (!locked && !LockService.lock()) {
            startActivity(Intent(this, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
            })
        }
        finish()
    }
}
