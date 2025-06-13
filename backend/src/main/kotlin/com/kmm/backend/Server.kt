package com.kmm.backend

import com.kmm.shared.AppConstants
import com.kmm.shared.DummyDataFactory
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.http.content.*
import io.ktor.http.*
import io.ktor.server.plugins.cors.routing.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import kotlinx.coroutines.runBlocking

/**
 * Main application entry point for the backend server
 */
fun main(args: Array<String>) {
    // Parse command line arguments for ports
    val httpPort = args.getOrNull(0)?.toIntOrNull() ?: AppConstants.DEFAULT_HTTP_PORT
    
    println("Starting KMP REST Web App Backend...")
    println("Configuration:")
    println("  HTTP API Port: $httpPort")
    println("  Frontend: Served by dedicated development server (port ${AppConstants.DEFAULT_FRONTEND_PORT})")
    
    // Start the server
    embeddedServer(Netty, port = httpPort) {
        module()
    }.start(wait = true)
}

/**
 * Application module configuration
 */
fun Application.module() {
    // Configure content negotiation for JSON serialization
    install(ContentNegotiation) {
        json(Json {
            prettyPrint = true
            isLenient = true
        })
    }
    
    // Configure CORS
    install(CORS) {
        allowMethod(HttpMethod.Options)
        allowMethod(HttpMethod.Get)
        allowMethod(HttpMethod.Post)
        allowHeader(HttpHeaders.Authorization)
        allowHeader(HttpHeaders.ContentType)
        allowHeader("X-Requested-With")
        allowCredentials = true
        anyHost()
    }
    
    // Configure routing
    routing {
        // Health check endpoint
        get(AppConstants.HEALTH_ENDPOINT) {
            call.respondText("OK")
        }
        
        // API info endpoint
        get("${AppConstants.API_BASE_PATH}/info") {
            call.respond(mapOf(
                "name" to "KMP REST Web App Backend",
                "version" to "1.0.0",
                "endpoints" to listOf(
                    AppConstants.DUMMY_DATA_ENDPOINT,
                    AppConstants.HEALTH_ENDPOINT
                )
            ))
        }
        
        // Dummy data endpoint
        get(AppConstants.DUMMY_DATA_ENDPOINT) {
            val dummyData = DummyDataFactory.createSampleData()
            call.respond(dummyData)
        }
    }
} 