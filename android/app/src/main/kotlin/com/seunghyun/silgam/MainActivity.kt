package com.seunghyun.silgam

import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelId = "com.seunghyun.silgam/audio"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelId).setMethodCallHandler { call, result ->
            when (call.method) {
                "controlMediaVolume" -> {
                    volumeControlStream = AudioManager.STREAM_MUSIC
                }
                "controlDefaultVolume" -> {
                    volumeControlStream = AudioManager.USE_DEFAULT_STREAM_TYPE
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
