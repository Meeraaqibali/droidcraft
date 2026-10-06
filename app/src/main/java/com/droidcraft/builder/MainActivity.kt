package com.droidcraft.builder

import android.annotation.SuppressLint
import android.app.AlertDialog
import android.os.Bundle
import android.webkit.JsPromptResult
import android.webkit.JsResult
import android.webkit.WebChromeClient
import android.webkit.WebSettings
import android.webkit.WebView
import android.widget.EditText
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    private lateinit var webView: WebView

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        webView = WebView(this)
        setContentView(webView)

        val s = webView.settings
        s.javaScriptEnabled = true
        s.domStorageEnabled = true
        s.allowFileAccess = true
        s.allowContentAccess = true
        s.databaseEnabled = true
        s.cacheMode = WebSettings.LOAD_DEFAULT
        s.useWideViewPort = true
        s.loadWithOverviewMode = true
        s.builtInZoomControls = false
        s.displayZoomControls = false
        s.mediaPlaybackRequiresUserGesture = false
        s.setSupportZoom(false)
        s.javaScriptCanOpenWindowsAutomatically = true

        webView.isLongClickable = false
        webView.setOnLongClickListener { true }

        webView.webChromeClient = object : WebChromeClient() {
            override fun onJsAlert(v: WebView?, u: String?, m: String?, r: JsResult?): Boolean {
                AlertDialog.Builder(this@MainActivity).setTitle("DroidCraft").setMessage(m)
                    .setPositiveButton("OK") { _, _ -> r?.confirm() }.setCancelable(false).show()
                return true
            }
            override fun onJsConfirm(v: WebView?, u: String?, m: String?, r: JsResult?): Boolean {
                AlertDialog.Builder(this@MainActivity).setTitle("DroidCraft").setMessage(m)
                    .setPositiveButton("OK") { _, _ -> r?.confirm() }
                    .setNegativeButton("Cancel") { _, _ -> r?.cancel() }.setCancelable(false).show()
                return true
            }
            override fun onJsPrompt(v: WebView?, u: String?, m: String?, d: String?, r: JsPromptResult?): Boolean {
                val input = EditText(this@MainActivity).apply { setText(d ?: ""); setSelection(text.length) }
                AlertDialog.Builder(this@MainActivity).setTitle("DroidCraft").setMessage(m).setView(input)
                    .setPositiveButton("OK") { _, _ -> r?.confirm(input.text.toString()) }
                    .setNegativeButton("Cancel") { _, _ -> r?.cancel() }.setCancelable(false).show()
                return true
            }
        }

        webView.loadUrl("file:///android_asset/index.html")
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        webView.evaluateJavascript(
            "(function(){ return window.handleBackButton ? window.handleBackButton() : false; })()"
        ) { result ->
            if (result != "true") { @Suppress("DEPRECATION") super.onBackPressed() }
        }
    }
}
