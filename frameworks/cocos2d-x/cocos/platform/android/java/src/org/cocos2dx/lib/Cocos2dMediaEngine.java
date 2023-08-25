package org.cocos2dx.lib;


import android.app.Activity;
import android.content.Context;
import android.graphics.Point;
import android.media.MediaFormat;
import android.net.Uri;
import android.os.Handler;
import android.util.Log;

import androidx.media3.common.MediaItem;
import androidx.media3.common.PlaybackException;
import androidx.media3.common.Player;
import androidx.media3.common.VideoSize;
import androidx.media3.datasource.DataSource;
import androidx.media3.datasource.DefaultDataSource;
import androidx.media3.exoplayer.DefaultRenderersFactory;
import androidx.media3.exoplayer.ExoPlayer;
import androidx.media3.exoplayer.Renderer;
import androidx.media3.exoplayer.mediacodec.MediaCodecAdapter;
import androidx.media3.exoplayer.mediacodec.MediaCodecSelector;
import androidx.media3.exoplayer.source.MediaSource;
import androidx.media3.exoplayer.source.ProgressiveMediaSource;
import androidx.media3.exoplayer.video.VideoRendererEventListener;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.concurrent.atomic.AtomicInteger;

public class Cocos2dMediaEngine extends DefaultRenderersFactory implements Player.Listener, Cocos2dVideoRenderer.OutputHandler  {
    // The native media events, match with MEMediaEventType
    public static final int EVENT_PLAYING = 0;
    public static final int EVENT_PAUSED = 1;
    public static final int EVENT_STOPPED = 2;
    public static final int EVENT_ERROR = 3;

    /** Media has been closed and cannot be played again. */
    public static final int STATE_CLOSED = 0;

    /** Media is being prepared for playback. */
    public static final int STATE_PREPARING = 1;

    /** Media is currently playing. */
    public static final int STATE_PLAYING = 2;

    /** Playback has been paused, but can be resumed. */
    public static final int STATE_PAUSED = 3;

    /** Playback has been stopped, but can be restarted. */
    public static final int STATE_STOPPED = 4;

    /** Unrecoverable error occurred during playback. */
    public static final int STATE_ERROR = 5;

    // The desired video pixel format
    /**
     * COLOR_FormatYUV420SemiPlanar (yyyyyyyy uvuv)  (NV12)
     * COLOR_FormatYUV420Planar (yyyyyyyy uu vv)     (YUV420p)
     * COLOR_FormatYUV422SemiPlanar (Y0 U0 Y1 V0)    (YUY2)
     */

    public static final String TAG = "Cocos2dMediaEngine";

    public static Context sContext = null;

    private ExoPlayer mPlayer;
    private Cocos2dVideoRenderer mVideoRenderer;
    private boolean mAutoPlay = false;
    private boolean mLooping = false;
    private long mNativeObj = 0; // native object address for send event to C++, weak ref

    private boolean mPlaybackEnded = false;

    private AtomicInteger mState = new AtomicInteger(STATE_CLOSED);

    Point mOutputDim = new Point(); // The output dim match with buffer
    Point mVideoDim = new Point(); // The video dim (validate image dim)


    /** ------ native methods ------- */
    public static native void nativeHandleEvent(long nativeObj, int arg1);
    public static native void nativeHandleVideoSample(long nativeObj, ByteBuffer sampleData, int sampleLen, int outputX, int outputY, int videoX, int videoY);

    public static void setContext(Activity activity) {
        sContext = activity.getApplicationContext();
    }

    @SuppressWarnings("unused")
    public static Object createMediaEngine() {
        return new Cocos2dMediaEngine(sContext);
    }

    /**
     * @param context A {@link Context}.
     */
    public Cocos2dMediaEngine(Context context) {
        super(context);
        setAllowedVideoJoiningTimeMs(0);
    }

    @SuppressWarnings("unused")
    public void bindNativeObject(long nativeObj) {
        mNativeObj = nativeObj;
        if(nativeObj == 0) { // when unbind nativeObj, we should ensure close player
            close();
        }
    }

    @Override
    protected void buildVideoRenderers(
            Context context,
            @DefaultRenderersFactory.ExtensionRendererMode int extensionRendererMode,
            MediaCodecSelector mediaCodecSelector,
            boolean enableDecoderFallback,
            Handler eventHandler,
            VideoRendererEventListener eventListener,
            long allowedVideoJoiningTimeMs,
            ArrayList<Renderer> out) {
        out.add(
                new Cocos2dVideoRenderer(
                        context,
                        getCodecAdapterFactory(),
                        mediaCodecSelector,
                        allowedVideoJoiningTimeMs,
                        enableDecoderFallback,
                        eventHandler,
                        eventListener,
                        MAX_DROPPED_VIDEO_FRAME_COUNT_TO_NOTIFY));
    }

    public void setAutoPlay(boolean bAutoPlay)
    {
        mAutoPlay = bAutoPlay;
    }

    /**
     *
     * @param sourceUri:
     *                 url: http(s)://
     *                 disk: file://path/to/file
     *                 assets: file:///android_asset
     * @return
     */
    public boolean open(String sourceUri)
    {
        if (mState.get() == STATE_PREPARING)
            return false;
        mState.set(STATE_PREPARING);

        final Cocos2dMediaEngine mediaEngine = this;
        Cocos2dxEngine.getActivity().runOnUiThread(() -> {
            try {
                DataSource.Factory dataSourceFactory = new DefaultDataSource.Factory(sContext);
                MediaSource mediaSource =
                        new ProgressiveMediaSource.Factory(dataSourceFactory)
                                .createMediaSource(MediaItem.fromUri(Uri.parse(sourceUri)));

                mPlayer = new ExoPlayer.Builder(sContext, mediaEngine).build();
                mVideoRenderer = (Cocos2dVideoRenderer) mPlayer.getRenderer(0); // the first must be video renderer
                mVideoRenderer.setOutputHandler(mediaEngine);
                mPlayer.addListener(mediaEngine);
                mPlayer.setMediaSource(mediaSource);
                mPlayer.prepare();
                mPlayer.setRepeatMode(mLooping ? Player.REPEAT_MODE_ALL : Player.REPEAT_MODE_OFF);
                mPlayer.setPlayWhenReady(mAutoPlay);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        });

        return true;
    }

    public boolean close() {
        if(mPlayer != null) {
            final ExoPlayer player = mPlayer;
            mPlayer = null;
            final Cocos2dMediaEngine mediaEngine = this;
            Cocos2dxEngine.getActivity().runOnUiThread(() -> {
                mVideoRenderer.setOutputHandler(null);
                player.removeListener(mediaEngine);
                player.stop();
                player.release();
                mState.set(STATE_CLOSED);
            });
        }
        return true;
    }

    public boolean setLoop(boolean bLooping) {
        if (mLooping != bLooping) {
            mLooping = bLooping;
            if (mPlayer == null) return false;
            Cocos2dxEngine.getActivity().runOnUiThread(() -> {
                if (mPlayer != null)
                    mPlayer.setRepeatMode(mLooping ? Player.REPEAT_MODE_ALL : Player.REPEAT_MODE_OFF);
            });
        }
        return true;
    }

    @SuppressWarnings("unused")
    public boolean setRate(double fRate) {
        if(mPlayer == null) return false;
        Cocos2dxEngine.getActivity().runOnUiThread(() -> {
            if (mPlayer != null)
                mPlayer.setPlaybackSpeed((float)fRate);
        });
        return true;
    }
    public boolean setCurrentTime(double fSeekTimeInSec)
    {
        if(mPlayer == null) return false;

        Cocos2dxEngine.getActivity().runOnUiThread(() -> {
            if (mPlayer != null)
                mPlayer.seekTo((long)(fSeekTimeInSec * 1000));
        });
        return true;
    }
    public boolean play() {
        if (mPlayer == null) return false;
        Cocos2dxEngine.getActivity().runOnUiThread(() -> {
            if (mPlayer != null) {
                if (!mPlaybackEnded && mState.compareAndSet(STATE_STOPPED, STATE_PREPARING)) // TO-CHECK: can't reply after playback stopped
                {
                    /**
                     * The player is used in a way that may benefit from foreground mode.
                     * For this to be true, the same player instance must be used to play multiple pieces of content,
                     * and there must be gaps between the playbacks (i.e. Player.stop() is called to halt one playback,
                     * and prepare(com.google.android.exoplayer2.source.MediaSource) is called some time later to start a new one).
                     */
                    mPlayer.prepare();
                    mPlayer.seekTo(0);
                }
                mPlayer.play();
            }
        });
        return true;
    }
    public boolean pause() {
        if(mPlayer == null) return false;
        Cocos2dxEngine.getActivity().runOnUiThread(() -> {
            if (mPlayer != null)
                mPlayer.pause();
        });
        return true;
    }
    public boolean stop() {
        if(mPlayer == null) return false;
        Cocos2dxEngine.getActivity().runOnUiThread(() -> {
            if (mPlayer != null)
                mPlayer.stop();
        });
        return true;
    }

    /**
     * Get playback State match with native MEMediaState
     */
    public int getState() {
        return mState.get();
    }

    /** update video informations */
    private MediaFormat updateVideoInfo() {
        MediaFormat format = mVideoRenderer.getOutputMediaFormat();
        mOutputDim.x = format.getInteger(MediaFormat.KEY_WIDTH);
        if (format.containsKey(MediaFormat.KEY_CROP_LEFT)
                && format.containsKey(MediaFormat.KEY_CROP_RIGHT)) {
            mVideoDim.x = format.getInteger(MediaFormat.KEY_CROP_RIGHT) + 1
                    - format.getInteger(MediaFormat.KEY_CROP_LEFT);
        }
        else
            mVideoDim.x = mOutputDim.x;

        mOutputDim.y = format.getInteger(MediaFormat.KEY_HEIGHT);
        if (format.containsKey(MediaFormat.KEY_CROP_TOP)
                && format.containsKey(MediaFormat.KEY_CROP_BOTTOM)) {
            mVideoDim.y = format.getInteger(MediaFormat.KEY_CROP_BOTTOM) + 1
                    - format.getInteger(MediaFormat.KEY_CROP_TOP);
        }
        else
            mVideoDim.y = mOutputDim.y;

        return format;
    }

    /** handler or listener methods */

    @Override
    public void handleVideoSample(MediaCodecAdapter codec, int index, long presentationTimeUs) {
//        MediaFormat format = updateVideoInfo();

//        String mimeType = format.getString(MediaFormat.KEY_MIME); // "video/raw" (NV12)
//        Integer colorFormat = format.getInteger(MediaFormat.KEY_COLOR_FORMAT);
//        boolean NV12 = colorFormat == Cocos2dVideoRenderer.DESIRED_PIXEL_FORMAT;

        if(presentationTimeUs == 0) {
            updateVideoInfo();
        }

        if (mState.get() != STATE_PLAYING) {
            mPlaybackEnded = false;
            mState.set(STATE_PLAYING);
            nativeEvent(EVENT_PLAYING);
        }

        ByteBuffer tmpBuffer = codec.getOutputBuffer(index);
        nativeHandleVideoSample(mNativeObj, tmpBuffer, tmpBuffer.remaining(), mOutputDim.x, mOutputDim.y, mVideoDim.x, mVideoDim.y);
    }

    @Override
    public void onIsPlayingChanged(boolean isPlaying) {
        Log.d(TAG, "[Individual]onIsPlayingChanged: " + isPlaying);
        if(mPlayer == null) return;
        if (!isPlaying) {
            int playbackState = mPlayer.getPlaybackState();
            if (playbackState == Player.STATE_READY || playbackState == Player.STATE_BUFFERING) {
                mState.set(STATE_PAUSED);
                nativeEvent(EVENT_PAUSED);
            }
            else if(playbackState == Player.STATE_IDLE && mState.get() != STATE_STOPPED) {
                mState.set(STATE_STOPPED);
                nativeEvent(EVENT_STOPPED);
            }
        }
    }

    /**
     *
     * @param playbackState
     *     int STATE_IDLE = 1;
     *     int STATE_BUFFERING = 2;
     *     int STATE_READY = 3;
     *     int STATE_ENDED = 4;
     */
    @Override
    public void onPlaybackStateChanged(int playbackState) {
        Log.d(TAG, "[Individual]onPlaybackStateChanged: " + playbackState);
        if(mPlayer == null) return;
        switch (playbackState) {
            case Player.STATE_READY:
                Log.d(TAG, "[Individual]onPlaybackStateChanged: decoder: " + mVideoRenderer.getCodecName());
                break;
            case Player.STATE_ENDED:
                mPlaybackEnded = true;
            case Player.STATE_IDLE:
                mState.set(STATE_STOPPED);
                nativeEvent(EVENT_STOPPED);
                break;
            default: ;
        }
    }

    @Override
    public void onPlayerError(PlaybackException error) {
        Log.e(TAG, "onPlayerError: " + error.getMessage());
        if(mPlayer == null) return;
        mState .set(STATE_ERROR);
        nativeEvent(EVENT_ERROR);
    }

    public boolean isPlaybackEnded() {
        return mPlaybackEnded;
    }

    @Override
    public void onVideoSizeChanged(VideoSize videoSize) {
        Log.d(TAG, String.format("[Individual]onVideoSizeChanged: (%d,%d)", videoSize.width, videoSize.height));
        if(mPlayer != null)
            updateVideoInfo();
    }

    @Override
    public void onIsLoadingChanged(boolean isLoading) {
        Log.d(TAG, "[Individual]onIsLoadingChanged: " + isLoading);
    }

    public void nativeEvent(int event) {
        if(mNativeObj != 0 && mPlayer != null) {
            nativeHandleEvent(mNativeObj, event);
        }
    }
}


