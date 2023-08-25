package org.cocos2dx.lib;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.pm.PackageManager;
import android.content.pm.ApplicationInfo;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.IBinder;
import android.os.Vibrator;
import android.preference.PreferenceManager;
import android.util.Log;
import com.android.vending.expansion.zipfile.APKExpansionSupport;
import com.android.vending.expansion.zipfile.ZipResourceFile;
import com.enhance.gameservice.IGameTuningService;

import java.io.IOException;
import java.util.LinkedHashSet;
import java.util.Set;

public class Cocos2dxEngine {
    private static final String TAG = Cocos2dxEngine.class.getSimpleName();
    private static Activity sActivity = null;
    private static boolean sInited = false;
    private static String sPackageName;
    private static AssetManager sAssetManager;
    private static Cocos2dxEngineListener cocos2dEngineListener;
    private static Set<PreferenceManager.OnActivityResultListener> onActivityResultListeners = new LinkedHashSet<>();
    private static Cocos2dxAccelerometer sAccelerometer = null;
    private static Vibrator sVibrateService = null;
    private static boolean sCompassEnabled;
    private static boolean sAccelerometerEnabled;
    private static boolean sActivityVisible;
    //Enhance API modification begin
    private static IGameTuningService mGameServiceBinder = null;
    private static final int BOOST_TIME = 7;


    // The OBB file
    private static ZipResourceFile sOBBFile = null;
    //Enhance API modification end

    public static void init(final Activity activity) {
        sActivity = activity;
        cocos2dEngineListener = (Cocos2dxEngineListener)activity;
        if (!sInited) {

            PackageManager pm = activity.getPackageManager();
            boolean isSupportLowLatency = pm.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY);
            Log.d(TAG, String.format("android version is %d, isSupportLowLatency: %s", Build.VERSION.SDK_INT, isSupportLowLatency ? "true" : "false") );

            final ApplicationInfo applicationInfo = activity.getApplicationInfo();

            sPackageName = applicationInfo.packageName;

            sAssetManager = activity.getAssets();
            nativeSetContext(activity, sAssetManager);

            Cocos2dMediaEngine.setContext(activity);

            BitmapHelper.setContext(activity);

            sVibrateService = (Vibrator)activity.getSystemService(Context.VIBRATOR_SERVICE);

            sInited = true;

            //Enhance API modification begin
            Intent serviceIntent = new Intent(IGameTuningService.class.getName());
            serviceIntent.setPackage("com.enhance.gameservice");
            boolean suc = activity.getApplicationContext().bindService(serviceIntent, connection, Context.BIND_AUTO_CREATE);
            //Enhance API modification end
        }
    }

    //Enhance API modification begin
    private static ServiceConnection connection = new ServiceConnection() {
        public void onServiceConnected(ComponentName name, IBinder service) {
            mGameServiceBinder = IGameTuningService.Stub.asInterface(service);
            fastLoading(BOOST_TIME);
        }

        public void onServiceDisconnected(ComponentName name) {
            sActivity.getApplicationContext().unbindService(connection);
        }
    };
    //Enhance API modification end

    public static Activity getActivity() {
        return sActivity;
    }

    public static int fastLoading(int sec) {
        try {
            if (mGameServiceBinder != null) {
                return mGameServiceBinder.boostUp(sec);
            }
            return -1;
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }



    public static void onResume() {
        sActivityVisible = true;
        if (Cocos2dxEngine.sAccelerometerEnabled) {
            Cocos2dxEngine.getAccelerometer().enableAccel();
        }
        if (Cocos2dxEngine.sCompassEnabled) {
            Cocos2dxEngine.getAccelerometer().enableCompass();
        }
    }


    public static void onPause() {
        sActivityVisible = false;
        if (Cocos2dxEngine.sAccelerometerEnabled) {
            Cocos2dxEngine.getAccelerometer().disable();
        }
    }

    private static native void nativeSetContext(final Object pContext, final Object pAssetManager);


    private static native void nativeRunOnGLThread(final Object runnable);


    public static void runOnGLThread(final Runnable r) {
        nativeRunOnGLThread(r);
    }

    // ===========================================================
    // Inner and Anonymous Classes
    // ===========================================================

    public static interface Cocos2dxEngineListener {
        void showDialog(final String pTitle, final String pMessage);
    }

    private static Cocos2dxAccelerometer getAccelerometer() {
        if (null == sAccelerometer)
            Cocos2dxEngine.sAccelerometer = new Cocos2dxAccelerometer(sActivity);

        return sAccelerometer;
    }

    public static Set<PreferenceManager.OnActivityResultListener> getOnActivityResultListeners() {
        return onActivityResultListeners;
    }


    public static String getPackageName() {
        return Cocos2dxEngine.sPackageName;
    }

    public static ZipResourceFile getObbFile() {
        if (null == sOBBFile) {
            int versionCode = 1;
            try {
                versionCode = Cocos2dxActivity.getContext().getPackageManager().getPackageInfo(Cocos2dxEngine.getPackageName(), 0).versionCode;
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }

            try {
                sOBBFile = APKExpansionSupport.getAPKExpansionZipFile(Cocos2dxActivity.getContext(), versionCode, 0);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        return sOBBFile;
    }
}
