package com.kmm.frontend

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import com.kmm.shared.DummyData
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.launch

// Simple UI state for the app
sealed class UiState {
    object Initial : UiState()
    object Loading : UiState()
    object Success : UiState()
    data class Error(val message: String) : UiState()
}

// Simple constants for the app
object AppConstants {
    const val DEFAULT_SERVER_HOST = "localhost"
    const val DEFAULT_HTTP_PORT = 8081
}

/**
 * Main App composable for the KMP REST Web App frontend
 * This provides the overall structure and theme for the application
 */
@Composable
fun App() {
    val dataService = remember { DataService() }
    val scope = rememberCoroutineScope()
    
    var data by remember { mutableStateOf<DummyData?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var error by remember { mutableStateOf<String?>(null) }
    var isHealthy by remember { mutableStateOf(false) }
    
    // Check backend health on startup
    LaunchedEffect(Unit) {
        dataService.checkHealth().collect { healthy ->
            isHealthy = healthy
        }
    }
    
    MaterialTheme {
        Column(
            modifier = Modifier.fillMaxSize().padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(
                text = "🚀 KMP REST Web App",
                style = MaterialTheme.typography.headlineMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )
            Spacer(modifier = Modifier.height(16.dp))
            Text(
                text = "Kotlin Multiplatform + REST API + WebAssembly Demo",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(24.dp))
            Text(
                text = "Backend: ${AppConstants.DEFAULT_SERVER_HOST}:${AppConstants.DEFAULT_HTTP_PORT}",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(modifier = Modifier.height(24.dp))
            Button(
                onClick = {
                    scope.launch {
                        isLoading = true
                        error = null
                        try {
                            dataService.fetchDummyData().collect { newData ->
                                data = newData
                            }
                        } catch (e: Exception) {
                            error = e.message
                        } finally {
                            isLoading = false
                        }
                    }
                },
                enabled = !isLoading && isHealthy
            ) {
                Text(if (isLoading) "Loading..." else "Fetch Data")
            }
            Spacer(modifier = Modifier.height(16.dp))
            if (isLoading) {
                CircularProgressIndicator()
            }
            error?.let { errorMessage ->
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = errorMessage,
                    color = MaterialTheme.colorScheme.error,
                    style = MaterialTheme.typography.bodyMedium
                )
            }
            data?.let { dummyData ->
                Spacer(modifier = Modifier.height(16.dp))
                Card(
                    modifier = Modifier.fillMaxWidth(0.8f),
                    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text("ID: ${dummyData.id}", style = MaterialTheme.typography.bodyLarge)
                        Text("Name: ${dummyData.name}", style = MaterialTheme.typography.bodyLarge)
                        Text("Description: ${dummyData.description}", style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }
        }
    }
}

@Composable
private fun AppHeader() {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = "🚀 KMP REST Web App",
            style = MaterialTheme.typography.headlineLarge,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.primary
        )
        
        Text(
            text = "Kotlin Multiplatform + REST API + WebAssembly Demo",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
        
        // Backend connection info
        Text(
            text = "Backend: ${AppConstants.DEFAULT_SERVER_HOST}:${AppConstants.DEFAULT_HTTP_PORT}",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun MainContent() {
    // State management for the app
    var uiState by remember { mutableStateOf<UiState>(UiState.Initial) }
    var fetchedData by remember { mutableStateOf<DummyData?>(null) }
    
    // Create DataService instance
    val dataService = remember { DataService() }
    val scope = rememberCoroutineScope()
    
    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(24.dp)
    ) {
        // Status card
        StatusCard()
        
        // Fetch Data button
        FetchDataButton(
            uiState = uiState,
            onFetchData = {
                uiState = UiState.Loading
                scope.launch {
                    try {
                        dataService.fetchDummyData().collect { result ->
                            fetchedData = result
                            uiState = UiState.Success
                        }
                    } catch (e: Exception) {
                        uiState = UiState.Error(e.message ?: "Unknown error")
                    }
                }
            }
        )
        
        // Data display area
        DataDisplaySection(
            uiState = uiState,
            data = fetchedData
        )
    }
}

@Composable
private fun StatusCard() {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "✅ Frontend Status: RUNNING",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = "Kotlin/Wasm Compose application loaded successfully!",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
        }
    }
}

@Composable
private fun FetchDataButton(
    uiState: UiState,
    onFetchData: () -> Unit
) {
    Button(
        onClick = onFetchData,
        enabled = uiState !is UiState.Loading,
        colors = ButtonDefaults.buttonColors(
            containerColor = MaterialTheme.colorScheme.primary
        )
    ) {
        when (uiState) {
            is UiState.Loading -> {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    CircularProgressIndicator(
                        modifier = Modifier.size(16.dp),
                        color = MaterialTheme.colorScheme.onPrimary,
                        strokeWidth = 2.dp
                    )
                    Text("Loading...")
                }
            }
            else -> Text("Fetch Data from Backend")
        }
    }
}

@Composable
private fun DataDisplaySection(
    uiState: UiState,
    data: DummyData?
) {
    when (uiState) {
        is UiState.Initial -> {
            Text(
                text = "Click the button to fetch data from the backend",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        
        is UiState.Loading -> {
            // Loading state is handled in the button
        }
        
        is UiState.Success -> {
            data?.let { dummyData ->
                DataCard(data = dummyData)
            }
        }
        
        is UiState.Error -> {
            ErrorCard(message = uiState.message)
        }
    }
}

@Composable
private fun DataCard(data: DummyData) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                text = "📊 Fetched Data",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Text(
                text = "ID: ${data.id}",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Text(
                text = "Name: ${data.name}",
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            
            Text(
                text = "Description: ${data.description}",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun ErrorCard(message: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.errorContainer
        ),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Text(
                text = "❌ Error",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onErrorContainer
            )
            
            Spacer(modifier = Modifier.height(8.dp))
            
            Text(
                text = message,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.Medium,
                color = MaterialTheme.colorScheme.onErrorContainer
            )
        }
    }
}

 