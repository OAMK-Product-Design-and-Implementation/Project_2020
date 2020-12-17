package com.oamkprojects.security_control;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;

import io.flutter.app.FlutterApplication;

public class SecurityControl extends FlutterApplication {

    @Override
    public void onCreate(){
        super.onCreate();

//        if((Build.VERSION.SDK_INT) >= (Build.VERSION_CODES.O)){
//            NotificationChannel intruderChannel = new NotificationChannel("intruderChannel", "Intruder alerts", NotificationManager.IMPORTANCE_HIGH);
//            NotificationManager intruderChannelManager = getSystemService(NotificationManager.class);
//            intruderChannelManager.createNotificationChannel(intruderChannel);
//        }
    }
}
