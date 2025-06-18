package com.kmm.shared

/**
 * WASM-specific implementation that uses BuildConfig when available
 */
actual fun getBackendUrl(): String {
    return try {
        // Try to use BuildConfig (available in production builds)
        BuildConfig.getBackendUrl()
    } catch (e: Exception) {
        // Fallback to localhost for development
        "http://${AppConstants.DEFAULT_SERVER_HOST}:${AppConstants.DEFAULT_HTTP_PORT}"
    }
} 