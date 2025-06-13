/*
 * Frontend module build configuration
 * Compose Multiplatform for Web with Kotlin/Wasm target
 */

plugins {
    alias(libs.plugins.kotlin.multiplatform)
    alias(libs.plugins.compose.multiplatform)
    alias(libs.plugins.compose.compiler)
}

@OptIn(org.jetbrains.kotlin.gradle.ExperimentalWasmDsl::class)
kotlin {
    wasmJs {
        browser {
            commonWebpackConfig {
                devServer = (devServer ?: org.jetbrains.kotlin.gradle.targets.js.webpack.KotlinWebpackConfig.DevServer()).apply {
                    // Set frontend development server to port 8080
                    port = 8080
                    static = (static ?: mutableListOf()).apply {
                        // Serve static resources from the resources directory
                        add(project.projectDir.resolve("src/wasmJsMain/resources").absolutePath)
                    }
                }
            }
        }
        binaries.executable()
    }
    
    sourceSets {
        wasmJsMain {
            dependencies {
                // Shared module dependency
                implementation(project(":shared"))
                
                // Compose Multiplatform for Web
                implementation(compose.runtime)
                implementation(compose.foundation)
                implementation(compose.material3)
                implementation(compose.ui)
                implementation(compose.components.resources)
                
                // Kotlinx libraries
                implementation(libs.kotlinx.coroutines.core)
                implementation(libs.kotlinx.serialization.json)
                
                // Ktor client for HTTP requests (REST)
                implementation(libs.ktor.client.core)
                implementation(libs.ktor.client.js)
                implementation(libs.ktor.client.content.negotiation)
                implementation(libs.ktor.serialization.kotlinx.json)
            }
        }
        
        wasmJsTest {
            dependencies {
                implementation(libs.kotlin.test)
            }
        }
    }
} 