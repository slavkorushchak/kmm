package com.kmm.shared

/**
 * JVM-specific implementation (for backend)
 */
actual fun getBackendUrl(): String {
    // Backend should always use localhost for internal communications
    return "http://${AppConstants.DEFAULT_SERVER_HOST}:${AppConstants.DEFAULT_HTTP_PORT}"
} 