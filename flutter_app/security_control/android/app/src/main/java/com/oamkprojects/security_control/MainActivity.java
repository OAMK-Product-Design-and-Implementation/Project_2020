package com.oamkprojects.security_control;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.work.Constraints;
import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.NetworkType;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import java.util.List;
import java.util.concurrent.TimeUnit;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity  extends FlutterActivity {

//    private Intent serverSyncServiceIntent;
    private WorkManager workManager;
    private PeriodicWorkRequest serverSyncWorkRequest;
    public final String CHANNEL_ID = "securitycontrolintruderalerts";
    private static final String CHANNEL = "samples.flutter.dev/pushintruderalert";

    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);

        createNotificationChannel();

        startWorker();


    }

    private void startWorker(){
        // Require network for executing workRequest:
        Constraints constraints = new Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .build();

        serverSyncWorkRequest = new PeriodicWorkRequest.Builder(ServerSyncWorker.class,
                PeriodicWorkRequest.MIN_PERIODIC_INTERVAL_MILLIS,
                TimeUnit.MILLISECONDS)
                .setConstraints(constraints)
                .build();

        //serverSyncServiceIntent = new Intent(MainActivity.this, ServerSyncService.class);
        workManager = WorkManager.getInstance(this);
        workManager.enqueueUniquePeriodicWork("serverSyncWorker",
                ExistingPeriodicWorkPolicy.REPLACE, // TODO: replace with KEEP in final version
                serverSyncWorkRequest);
    }

    private void createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = getString(R.string.channel_name);
            String description = getString(R.string.channel_description);
            int importance = NotificationManager.IMPORTANCE_HIGH;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            NotificationManager notificationManager = getSystemService(NotificationManager.class);
            notificationManager.createNotificationChannel(channel);
        }



    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            // Note: this method is invoked on the main thread.
                            if (call.method.equals("pushIntruderAlert")) {
                                try {
                                    pushIntruderAlert((List<String>)call.arguments);
                                }
                                catch (Error err){
                                    result.error("1234",
                                            "Error while sending push notification",
                                            err.toString());
                                }
                                finally {
                                    result.success(true);
                                }
                            }
                            else{
                                result.notImplemented();
                            }
                        }
                );
    }

    public void pushIntruderAlert(List<String> content){
        String notificationContent = content.get(0);
        String notificationSubContent = content.get(1);
        Context applicationContext = getApplicationContext();

        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(applicationContext);

        NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(notificationContent)
                .setContentText(notificationSubContent)
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setOnlyAlertOnce(true);
        PendingIntent contentIntent = PendingIntent.getActivity(applicationContext, 0,
                new Intent(applicationContext, MainActivity.class), PendingIntent.FLAG_UPDATE_CURRENT);

        mBuilder.setContentIntent(contentIntent);

        notificationManager.notify(1234, mBuilder.build());
    }

}

