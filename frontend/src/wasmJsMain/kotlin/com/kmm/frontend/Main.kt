package com.kmm.frontend

import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.window.CanvasBasedWindow

/**
 * Main entry point for the KMP REST Web App frontend
 * This function initializes the Compose for Web application
 */
@OptIn(ExperimentalComposeUiApi::class)
fun main() {
    CanvasBasedWindow(
        title = "KMP REST Web App",
        canvasElementId = "ComposeTarget"
    ) {
        App()
    }
} 