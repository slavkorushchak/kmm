package com.kmm.shared

/**
 * WASM-specific implementation that can detect browser environment
 */
actual fun getBackendUrl(): String {
    return try {
        // In WASM, we'll use a simple approach: if production URL is set (not placeholder), use it
        if (AppConstants.PRODUCTION_BACKEND_URL != "PLACEHOLDER_BACKEND_URL") {
            AppConstants.PRODUCTION_BACKEND_URL
        } else {
            "http://${AppConstants.DEFAULT_SERVER_HOST}:${AppConstants.DEFAULT_HTTP_PORT}"
        }
    } catch (e: Exception) {
        // Fallback to localhost
        "http://${AppConstants.DEFAULT_SERVER_HOST}:${AppConstants.DEFAULT_HTTP_PORT}"
    }
} 