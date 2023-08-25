package org.goldratio.kingdoms;

import android.content.Context;
import android.view.KeyEvent;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

public class LuaGLSurfaceView extends Cocos2dxGLSurfaceView {
    public LuaGLSurfaceView(Context context) {
        super(context);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return super.onKeyDown(keyCode, event);
    }
}
