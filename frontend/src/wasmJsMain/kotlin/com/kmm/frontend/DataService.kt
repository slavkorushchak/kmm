package com.kmm.frontend

import com.kmm.shared.AppConstants
import com.kmm.shared.DummyData
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.engine.js.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.serialization.json.Json

/**
 * Service for fetching data from the backend
 */
class DataService {
    private val client = HttpClient(Js) {
        install(ContentNegotiation) {
            json(Json {
                prettyPrint = true
                isLenient = true
            })
        }
    }
    
    private val baseUrl = "http://${AppConstants.DEFAULT_SERVER_HOST}:${AppConstants.DEFAULT_HTTP_PORT}"
    
    /**
     * Fetches dummy data from the backend
     * @return Flow of DummyData
     */
    fun fetchDummyData(): Flow<DummyData> = flow {
        try {
            val response = client.get("$baseUrl${AppConstants.DUMMY_DATA_ENDPOINT}")
            val data = response.body<DummyData>()
            emit(data)
        } catch (e: Exception) {
            throw DataServiceException("Failed to fetch dummy data: ${e.message}", e)
        }
    }
    
    /**
     * Checks if the backend is healthy
     * @return Flow of Boolean indicating health status
     */
    fun checkHealth(): Flow<Boolean> = flow {
        try {
            val response = client.get("$baseUrl${AppConstants.HEALTH_ENDPOINT}")
            val status = response.body<String>()
            emit(status == "OK")
        } catch (e: Exception) {
            emit(false)
        }
    }
}

/**
 * Exception thrown by DataService
 */
class DataServiceException(message: String, cause: Throwable? = null) : Exception(message, cause) 