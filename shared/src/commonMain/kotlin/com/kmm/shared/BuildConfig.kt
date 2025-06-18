package com.kmm.shared

/**
 * Build-time configuration
 * This file is overwritten during production Docker builds with actual values
 * Default values are for local development
 */
object BuildConfig {
    const val BACKEND_URL = "http://localhost:8081"
    const val NODE_ENV = "development"
    const val BUILD_TIME = "development"
    const val VERSION = "1.0.0-dev"
    
    /**
     * Gets the appropriate backend URL for the current build
     */
    fun getBackendUrl(): String = BACKEND_URL
} 