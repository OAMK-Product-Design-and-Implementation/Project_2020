package com.oamkprojects.security_control;

import android.app.PendingIntent;
import android.app.admin.DnsEvent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.webkit.HttpAuthHandler;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationCompat;
import androidx.core.app.NotificationManagerCompat;
import androidx.work.Worker;
import androidx.work.WorkerParameters;
//import com.google.common.util.concurrent.Listenable

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;

import org.json.JSONArray;
import org.json.JSONException;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.Array;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Random;

import io.flutter.Log;

public class ServerSyncWorker extends Worker {
    private static final String CHANNEL_ID = "securitycontrolintruderalerts";
    private final String DEBUG_TAG = this.getClass().getSimpleName();

    private String updateIntervalKey = "flutter.updateinterval";
    private String serverAddressKey = "flutter.serveraddress";
    private String gopigokey = "flutter.gopigoexample";
//    private ArrayList msgList;

    public ServerSyncWorker(@NonNull Context context, @NonNull WorkerParameters workerParams) {
        super(context, workerParams);
    }

    @NonNull
    @Override
    public Result doWork() {
        Context applicationContext = getApplicationContext();
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(applicationContext);

        SharedPreferences prefs = applicationContext.getSharedPreferences("FlutterSharedPreferences",
                Context.MODE_PRIVATE);

        int battery;
        String serverAddress;
        serverAddress = prefs.getString(serverAddressKey, "195.148.21.106");
        Log.d(DEBUG_TAG, "Got server addr. from prefs:" + serverAddress);
        Random random = new Random();

        String url = "http://" + serverAddress + "/api/devices/get/activemessages";
        String getResponse;

        try {
            getResponse = downloadContent(url);
        } catch (IOException e) {
            Log.d(DEBUG_TAG, "Unable to retrieve data: " + e.toString());
            // Send notification?
            NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentTitle("Could not sync with server")
                    .setContentText("Make sure server address is correct")
                    .setPriority(NotificationCompat.PRIORITY_HIGH);

            PendingIntent contentIntent = PendingIntent.getActivity(applicationContext, 0,
                    new Intent(applicationContext, MainActivity.class), PendingIntent.FLAG_UPDATE_CURRENT);

            mBuilder.setContentIntent(contentIntent);

            notificationManager.notify(123, mBuilder.build());
            return Result.retry();
        }

        Log.d(DEBUG_TAG, "Response is: " + getResponse);
        ArrayList msgList = jsonToMessageList(getResponse.toString());
        boolean resultComplete = volleyComplete(msgList);
        if(resultComplete == true){
            return Result.success();
        }
        else{
            return Result.retry();
        }
    }

    private String downloadContent(String myurl) throws IOException {
        InputStream is = null;
        int length = 500;

        try {
            URL url = new URL(myurl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setReadTimeout(10000 /* milliseconds */);
            conn.setConnectTimeout(15000 /* milliseconds */);
            conn.setRequestMethod("GET");
            conn.setDoInput(true);
            conn.connect();
            int response = conn.getResponseCode();
            Log.d(DEBUG_TAG, "The response is: " + response);
            is = conn.getInputStream();

            // Convert the InputStream into a string
            String contentAsString = convertInputStreamToString(is, length);
            return contentAsString;
        } finally {
            if (is != null) {
                is.close();
            }
        }
    }

    public String convertInputStreamToString(InputStream stream, int length) throws IOException, UnsupportedEncodingException {
        Reader reader = null;
        reader = new InputStreamReader(stream, "UTF-8");
        char[] buffer = new char[length];
        reader.read(buffer);
        return new String(buffer);
    }

    ArrayList jsonToMessageList(String msg){
        JSONArray jsonArray = new JSONArray();
        ArrayList msgArray = new ArrayList();

        try {
            jsonArray = new JSONArray(msg);
        } catch (JSONException e) {
            e.printStackTrace();
        }
        if (jsonArray != null) {
            for (int i = 0; i < jsonArray.length(); i++) {
                try {
                    msgArray.add(jsonArray.getString(i));
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }
        return msgArray;
    }

    boolean volleyComplete(ArrayList msgList) {
        boolean sendNotification = false;
        boolean intruderAlert = false;

        Context applicationContext = getApplicationContext();
        NotificationManagerCompat notificationManager = NotificationManagerCompat.from(applicationContext);
        ArrayList oneMessageList = new ArrayList();
        ArrayList criticalActions = new ArrayList(); // Stores only errors
        ArrayList intruderAlerts = new ArrayList(); // Stores only intruders

        String notificationContent = "";
        String notificationSubContent = "";

        if (msgList != null) {
            //Log.d(DEBUG_TAG, msgList.get(0).getClass().toString());

            for(int i = 0; i < msgList.size(); i++){
                oneMessageList = jsonToMessageList(msgList.get(i).toString());

                // Info messages will not trigger notification:
                if(oneMessageList.get(1).equals("Error")){
                    sendNotification = true;
                    criticalActions.add(oneMessageList);
                }
                else if(oneMessageList.get(1).equals("Intruder")){
                    sendNotification = true;
                    intruderAlerts.add(oneMessageList);
                    intruderAlert = true;
                }
            }

            if(criticalActions.size() == 1){
                oneMessageList = (ArrayList) criticalActions.get(0);
                notificationContent = "Action required: " + oneMessageList.get(4).toString(); // deviceName
                notificationSubContent = oneMessageList.get(2).toString(); // Explanation
            }
            else if(criticalActions.size() > 1){
                notificationContent = Integer.toString(criticalActions.size()) + " actions required";
                notificationSubContent = "Tap to open Security Control";
            }

            if(intruderAlerts.size() > 0){
                notificationContent = "INTRUDER ALERT";
                if (intruderAlerts.size() == 1){
                    oneMessageList = (ArrayList) intruderAlerts.get(0);
                    notificationSubContent = oneMessageList.get(2).toString();
                }
                else {
                    notificationSubContent = Integer.toString(intruderAlerts.size()) + " intruder alerts";
                }
            }

            if(sendNotification == true){
                NotificationCompat.Builder mBuilder = new NotificationCompat.Builder(applicationContext, CHANNEL_ID)
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle(notificationContent)
                        .setContentText(notificationSubContent)
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setAutoCancel(true)
                        .setOnlyAlertOnce(false);
                PendingIntent contentIntent = PendingIntent.getActivity(applicationContext, 0,
                        new Intent(applicationContext, MainActivity.class), PendingIntent.FLAG_UPDATE_CURRENT);

                mBuilder.setContentIntent(contentIntent);

                notificationManager.notify(1234, mBuilder.build());
            }
        }
        return true;
    }
}