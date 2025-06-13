/*
 * Backend module build configuration
 * gRPC server with static file serving for frontend
 */

plugins {
    kotlin("jvm")
    application
}

dependencies {
    // Shared module dependency - use JVM variant specifically
    implementation(project(":shared", "jvmRuntimeElements"))
    
    // gRPC server dependencies
    implementation(libs.grpc.kotlin.stub)
    implementation(libs.grpc.protobuf)
    implementation(libs.grpc.netty)
    
    // Kotlinx libraries
    implementation(libs.kotlinx.coroutines.core)
    implementation(libs.kotlinx.serialization.json)
    implementation(libs.kotlinx.datetime)
    
    // Ktor for static file serving
    implementation(libs.ktor.client.core)
    implementation(libs.ktor.client.cio)
    
    // Additional dependencies for embedded server
    implementation("io.ktor:ktor-server-core:3.0.3")
    implementation("io.ktor:ktor-server-netty:3.0.3")
    implementation("io.ktor:ktor-server-cors:3.0.3")
    implementation("io.ktor:ktor-server-content-negotiation:3.0.3")
    implementation("io.ktor:ktor-serialization-kotlinx-json:3.0.3")
    
    // Logging
    implementation("ch.qos.logback:logback-classic:1.5.12")
    
    // Test dependencies
    testImplementation(libs.kotlin.test.junit)
    testImplementation(libs.junit)
    testImplementation(libs.kotlinx.coroutines.test)
}

// Set JVM target for compilation
kotlin {
    jvmToolchain(17)
}

// Configure application plugin
application {
    mainClass.set("com.kmm.backend.ServerKt")
}

// Task to copy frontend artifacts to backend resources (disabled for testing)
// val copyFrontendToBackend by tasks.registering(Copy::class) {
//     dependsOn(":frontend:wasmJsBrowserDistribution")
//     from(project(":frontend").layout.buildDirectory.dir("dist/wasmJs/productionExecutable"))
//     into(layout.buildDirectory.dir("resources/main/static"))
// }

// Ensure frontend is built and copied before running the backend (disabled for testing)
// tasks.named("processResources") {
//     dependsOn(copyFrontendToBackend)
// }

// Ensure shared module is built before backend compilation
tasks.named("compileKotlin") {
    dependsOn(":shared:jvmJar")
}

// Ensure shared JAR is available when running the backend
tasks.named("run") {
    dependsOn(":shared:jvmJar")
} 