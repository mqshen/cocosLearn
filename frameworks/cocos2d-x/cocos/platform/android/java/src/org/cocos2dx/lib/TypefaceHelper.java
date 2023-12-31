package org.cocos2dx.lib;


import android.content.Context;
import android.graphics.Typeface;

import java.util.HashMap;

public class TypefaceHelper {
    // ===========================================================
    // Constants
    // ===========================================================

    // ===========================================================
    // Fields
    // ===========================================================

    private static final HashMap<String, Typeface> sTypefaceCache = new HashMap<String, Typeface>();

    // ===========================================================
    // Constructors
    // ===========================================================

    // ===========================================================
    // Getter & Setter
    // ===========================================================

    // ===========================================================
    // Methods for/from SuperClass/Interfaces
    // ===========================================================

    // ===========================================================
    // Methods
    // ===========================================================

    public static synchronized Typeface get(final Context context, final String assetName) {
        if (!TypefaceHelper.sTypefaceCache.containsKey(assetName)) {
            Typeface typeface = null;
            if (assetName.startsWith("/"))
            {
                typeface = Typeface.createFromFile(assetName);
            }
            else
            {
                typeface = Typeface.createFromAsset(context.getAssets(), assetName);
            }
            TypefaceHelper.sTypefaceCache.put(assetName, typeface);
        }

        return TypefaceHelper.sTypefaceCache.get(assetName);
    }

    // ===========================================================
    // Inner and Anonymous Classes
    // ===========================================================

}