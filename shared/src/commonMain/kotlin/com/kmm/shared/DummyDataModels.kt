package com.kmm.shared

import kotlinx.serialization.Serializable

/**
 * Shared data models and utilities for the KMP REST Web App
 * This file contains platform-agnostic code only
 */

/**
 * Data class representing dummy data for easier manipulation
 */
@Serializable
data class DummyData(
    val id: String,
    val name: String,
    val description: String
) {
    /**
     * Validates that the dummy data contains valid non-empty values
     */
    fun isValid(): Boolean {
        return id.isNotBlank() && name.isNotBlank() && description.isNotBlank()
    }
}

/**
 * Utility object for creating dummy data instances
 */
object DummyDataFactory {
    
    /**
     * Creates a sample dummy data instance
     */
    fun createSampleData(): DummyData = DummyData(
        id = "sample-001",
        name = "Sample Data",
        description = "This is a sample data instance created for demonstration purposes."
    )
    
    /**
     * Creates dummy data with custom values
     */
    fun createDummyData(id: String, name: String, description: String): DummyData = 
        DummyData(id, name, description)
}

/**
 * Constants used across the application
 */
object AppConstants {
    const val DEFAULT_SERVER_HOST = "localhost"
    const val DEFAULT_HTTP_PORT = 8081  // Backend API port
    const val DEFAULT_FRONTEND_PORT = 8080  // Frontend development server port
    const val DEFAULT_REQUEST_TIMEOUT_MS = 5000L
    
    // API endpoints
    const val API_BASE_PATH = "/api"
    const val DUMMY_DATA_ENDPOINT = "$API_BASE_PATH/dummy-data"
    const val HEALTH_ENDPOINT = "$API_BASE_PATH/health"
} 