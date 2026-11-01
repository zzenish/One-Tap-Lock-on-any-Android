package com.jenish.one_tap_lock

import android.accessibilityservice.AccessibilityService
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

// Android owns this service. No timers, screen reading, or work on connection.
class LockService : AccessibilityService() {
    companion object {
        private var connected: LockService? = null
        val isReady: Boolean get() = connected != null
        fun lock(): Boolean = try {
            connected?.performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN) ?: false
        } catch (_: RuntimeException) { false }
    }
    override fun onServiceConnected() { connected = this }
    override fun onUnbind(intent: Intent?): Boolean {
        if (connected === this) connected = null
        return super.onUnbind(intent)
    }
    override fun onDestroy() {
        if (connected === this) connected = null
        super.onDestroy()
    }
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}
}
