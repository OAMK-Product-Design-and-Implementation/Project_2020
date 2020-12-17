package com.oamkprojects.security_control;

import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.IBinder;
import android.os.SystemClock;
import android.util.JsonWriter;
//import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.util.Random;
import java.util.TimerTask;

import io.flutter.Log;

public class ServerSyncService extends Service {

    private final String DEBUG_TAG = this.getClass().getSimpleName();

    private SharedPreferences prefs;

    private long updateInterval;
    private String updateIntervalKey = "flutter.updateinterval";

    private String serverAddress;
    private String serverAddressKey = "flutter.serveraddress";

    private String gopigokey = "flutter.gopigoexample";

    public SharedPreferences.OnSharedPreferenceChangeListener listener = new SharedPreferences.OnSharedPreferenceChangeListener() {
        @Override
        public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
            Log.d(DEBUG_TAG, "A shared pref was changed");

            if (key.equals(updateIntervalKey)) {
                updateInterval = sharedPreferences.getLong(key, 5);
                Log.d(DEBUG_TAG, "Changed server sync interval to: " + Long.toString(updateInterval));
            }
            else if(key.equals(serverAddressKey)){
                serverAddress = sharedPreferences.getString(key, "");
                Log.d(DEBUG_TAG, "Server addr. changed to: " + serverAddress);
            }
        }
    };

    @Override
    public void onCreate(){
        super.onCreate();
        if((Build.VERSION.SDK_INT) >= (Build.VERSION_CODES.O)){
            NotificationManager manager = getSystemService(NotificationManager.class);
            NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "intruderChannel")
                    .setContentText("Server sync. running")
                    .setContentTitle("Security Control");
            startForeground(101, builder.build());
        }

        prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE);

        updateInterval = prefs.getLong(updateIntervalKey, 5);
        serverAddress = prefs.getString(serverAddressKey, "");

        Log.d(DEBUG_TAG, "Got initial update interval from prefs:" + Long.toString(updateInterval));

        prefs.registerOnSharedPreferenceChangeListener(listener);
        //mockConnection().start();
        long lastTime = 0;
        Random random = new Random();
        String string = "";
        JsonWriter jsonWriter;
        int battery = 0;
        battery = random.nextInt();
//        string = "{" +
//                "\"GoPiGoExample\": [" +
//                "{" +
//                "\"id\": \"unique\"," +
//                "\"battery\": " + Integer.toString(battery) + "," +
//                "\"location\": 1" +
//                "}" +
//                "]" +
//                "}";
        string =
                "{" +
                "\"id\": \"unique\"," +
                "\"battery\": " + Integer.toString(battery) + "," +
                "\"location\": 1" +
                "}";
//        string = "";
        SharedPreferences.Editor editor = prefs.edit();
        editor.putString(gopigokey,string);
        editor.apply();
        Log.d(DEBUG_TAG,"Put something in gopigo pref.");
        Log.d(DEBUG_TAG, prefs.getString(gopigokey, "default"));

    }

    void mockConnection(){
        long lastTime = 0;
        Random random = new Random();
        String string = "";
        JsonWriter jsonWriter;
        int battery = 0;
        while(true){
            if(SystemClock.currentThreadTimeMillis() > lastTime + (updateInterval*1000)){
                battery = random.nextInt();
                string = "{\n" +
                        "    \"GoPiGoExample\": [\n" +
                        "        {\n" +
                        "            \"id\": \"unique\",\n" +
                        "            \"battery\":" + Integer.toString(battery) + "\",\n" +
                        "            \"location\": \"1\"\n" +
                        "        }\n" +
                        "    ]\n" +
                        "}";

                prefs.edit().putString(gopigokey,string).apply();
                Log.d(DEBUG_TAG,"Put something in gopigo pref.");
                lastTime = SystemClock.currentThreadTimeMillis();
            }
        }
    }



    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
