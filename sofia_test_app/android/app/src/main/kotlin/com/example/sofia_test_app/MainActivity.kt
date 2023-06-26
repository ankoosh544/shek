package com.example.sofia_test_app





 
import android.app.Activity
import android.app.role.RoleManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

 
class MainActivity : FlutterFragmentActivity() {
   
    private val EVENTS = "com.audio_channel"
    var methodChannelResult: MethodChannel.Result? = null
    //val audioService = AudioService() 
 
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        print("======================MainActivity========================================")
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENTS
        ).setMethodCallHandler { call, result ->
            methodChannelResult = result;
            if (call.method == "beep") {
                //val audio = audioService.beep() 
                print("***********************MainActivity*********************************************")
                result.success("***********************MainActivity*********************************************")
            }else {
                result.notImplemented()
            }
        }
    }
 
}
 