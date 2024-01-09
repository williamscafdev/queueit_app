
package com.example.queueit_app;
//inspiration from the following
//https://www.youtube.com/watch?v=6UftAAKSuVs
//https://www.youtube.com/watch?v=vfh2KCFEuDo
//https://docs.flutter.dev/platform-integration/platform-channels

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.engine.*;
import androidx.annotation.NonNull;
import android.util.Log;
import com.queue_it.androidsdk.*;
import com.queue_it.androidsdk.Error;
import java.io.Console;

public class MainActivity extends FlutterActivity {
    private static MethodChannel flutterToNativeChannel;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        flutterToNativeChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "flutter.native/helper");
        flutterToNativeChannel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("openQueueItWaitingRoom")) {
                String customerId = call.argument("customerId");
                String eventOrAliasId = call.argument("eventOrAliasId");
                String layoutName = call.argument("layoutName");
                String language = call.argument("language");

                String response = activateTheWaitingRoom(customerId, eventOrAliasId, layoutName, language);
                result.success(response);
            } else {
                result.notImplemented();
            }
        });
    }

    private String activateTheWaitingRoom(String customerId, String eventOrAliasId, String layoutName, String language) {
        try {
            QueueITEngine queueITEngine = getQueueITEngine(customerId, eventOrAliasId, layoutName, language);
            runQueue(queueITEngine);
        } catch (QueueITException error) {
            Log.e("QueueItDebug", error.getMessage());
            return "Error activating the waiting room: " + error.getMessage();
        }
        return "Waiting room activated";
    }

    private void runQueue(QueueITEngine queueITEngine) throws QueueITException {
        Log.i("QueueItDebug", "Starting Run Queue");
        queueITEngine.run(this);
    }

    private QueueITEngine getQueueITEngine(String customerId, String eventOrAliasId, String layoutName, String language) {
        QueueItEngineOptions options = getQueueItEngineOptions();
        return new QueueITEngine(this, customerId, eventOrAliasId, layoutName, language, queueListener, options);
    }

    @NonNull
    private QueueItEngineOptions getQueueItEngineOptions() {
        QueueItEngineOptions options = new QueueItEngineOptions();
        options.setBackButtonDisabledFromWR(false);
        return options;
    }

    private QueueListener queueListener = new QueueListener() {
        @Override
        public void onSessionRestart(QueueITEngine queueITEngine) {
            Log.i("QueueItDebug", "Session restarted");
            // Handle session restart
        }

        @Override
        public void onQueuePassed(QueuePassedInfo queuePassedInfo) {
            String message = "onQueuePassed QueueIt Token: " + queuePassedInfo.getQueueItToken();
            Log.i("QueueItDebug", message);
            flutterToNativeChannel.invokeMethod("onQueuePassed", message);
        }

        @Override
        public void onQueueViewWillOpen() {
            Log.i("QueueItDebug", "Queue view will open");
            // Handle queue view will open event
        }

        @Override
        public void onUserExited() {
            Log.i("QueueItDebug", "User exited");
            // Handle user exit event
        }

        @Override
        public void onQueueDisabled(QueueDisabledInfo queueDisabledInfo) {
              String message = "onQueueDisabled QueueIt Token: " + queueDisabledInfo.getQueueItToken();
            Log.i("QueueItDebug",message);
            flutterToNativeChannel.invokeMethod("onQueueDisabled", message);
        }

        @Override
        public void onQueueItUnavailable() {
            Log.i("QueueItDebug", "QueueIt unavailable");
            // Handle Queue-It unavailable event
        }

        @Override
        public void onError(Error error, String errorMessage) {
            Log.e("QueueItDebug", "Error: " + errorMessage);
            // Handle error event
        }

        @Override
        public void onWebViewClosed() {
            Log.i("QueueItDebug", "WebView closed");
            // Handle web view closed event
        }
    };
}
