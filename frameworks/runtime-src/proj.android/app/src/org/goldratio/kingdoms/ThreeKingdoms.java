package org.goldratio.kingdoms;

import android.annotation.SuppressLint;
import android.os.Bundle;

import android.os.Handler;
import android.view.View;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import java.lang.reflect.Field;

public class ThreeKingdoms extends Cocos2dxActivity {
    private static ThreeKingdoms instance;
    private boolean isNeedResume = false;
    private LuaGLSurfaceView m_glSurfaceView;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    protected void onStart() {
        super.onStart();
        resumeGLSurfaceView();
    }

    private void resumeGLSurfaceView() {
        Class superClass = getClass().getSuperclass();
        try {
            assert superClass != null;
            Field field = superClass.getDeclaredField("mGLSurfaceView");
            field.setAccessible(true);
            Cocos2dxGLSurfaceView glSurfaceView = (Cocos2dxGLSurfaceView) field.get(this);
            if (glSurfaceView != null) {
                glSurfaceView.onResume();
            }
        } catch (IllegalAccessException | IllegalArgumentException | NoSuchFieldException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onPause() {
        super.onPause();
        this.isNeedResume = true;
    }

    @Override
    public Cocos2dxGLSurfaceView onCreateView() {
        instance = this;
        this.m_glSurfaceView = new LuaGLSurfaceView(this);
        hideSystemUI();
        this.m_glSurfaceView.setEGLConfigChooser(5, 6, 5, 0, 16, 8);
        setOnSystemUiVisibilityChangeListener();
        return this.m_glSurfaceView;
    }

    @SuppressLint({"NewApi"})
    private void setOnSystemUiVisibilityChangeListener() {
        View decorView = getWindow().getDecorView();
        decorView.setOnSystemUiVisibilityChangeListener(i2 -> new Handler().postDelayed(this::hideSystemUI, 2000L));
    }

    static {
        System.out.println("slslsllsls");
    }
//    static {
//        System.loadLibrary("fmodex");
//        System.loadLibrary("fmodevent");
//        System.loadLibrary("avutil-54");
//        System.loadLibrary("avcodec-56");
//        System.loadLibrary("avformat-56");
//        System.loadLibrary("cocos2dlua");
//    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        if (hasFocus) {
            hideSystemUI();
        }
    }

    public static void ifHideSystemUI() {
        new Handler().postDelayed(() -> instance.hideSystemUI(), 2000L);
    }

    @SuppressLint({"NewApi"})
    public void hideSystemUI() {
        this.m_glSurfaceView.setSystemUiVisibility(5894);
    }
}
