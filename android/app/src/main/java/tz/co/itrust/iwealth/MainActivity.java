package tz.co.itrust.iwealth;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Base64;
import android.util.Log;
import android.util.Pair;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;

import android.app.AlertDialog;

import com.identy.Attempt;
import com.identy.FingerOutput;
import com.identy.IdentyError;
import com.identy.IdentyResponse;
import com.identy.IdentyResponseListener;
import com.identy.IdentySdk;
import com.identy.InlineGuideOption;
import com.identy.TemplateSize;
import com.identy.WSQCompression;
import com.identy.enums.Finger;
import com.identy.enums.FingerDetectionMode;
import com.identy.enums.Hand;
import com.identy.enums.Template;
import com.identy.GuideNoGuideHelper;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.FlutterException;
import io.flutter.plugin.common.MethodChannel;
import tz.co.itrust.iwealth.fingerprints.FingerUtils;
import tz.co.itrust.iwealth.fingerprints.IdentySdkResponse;
import tz.co.itrust.iwealth.fingerprints.MissingFingerUtils;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "identy_finger";
    private static final String TAG = "MAIN ACTIVITY";

    static boolean showProgressDialog = true;

    String mode = "local";
    WSQCompression compression = WSQCompression.WSQ_10_1;
    int base64encoding = Base64.DEFAULT;
    boolean displayBoxes = true;
    String licenseFile = "3798-tz.co.itrust.iwealth-16-11-2024.lic";
    boolean isResponseReceived = false;

    private FingerDetectionMode[] detectionModes;
    private final boolean isDisclaimerAccepted = true;
    private HashMap<Template, HashMap<Finger, ArrayList<TemplateSize>>> requiredTemplates;
    private List<IdentySdkResponse> identySdkResponseList;

    FingerUtils fingerUtils = new FingerUtils();
    Map<String, String> resultMap = new HashMap<>();

    // UI Enhancement variables
    private String selectedHand = "commercial"; // Default to left hand
    private AlertDialog customProgressDialog;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("capture")) {
                                try {
                                    Map<String, Object> captureData;
                                    String handSide;
                                    List<String> missingFingers;

                                    if (call.arguments instanceof String) {
                                        // Handle old format for backward compatibility
                                        handSide = (String) call.arguments;
                                        missingFingers = new ArrayList<>();
                                        Log.d(TAG, "Using old format - Hand: " + handSide);
                                    } else {
                                        // Handle new format
                                        captureData = (Map<String, Object>) call.arguments;
                                        handSide = (String) captureData.get("hand");
                                        missingFingers = (List<String>) captureData.get("missingFingers");
                                        Log.d(TAG, "Using new format - Hand: " + handSide + ", Missing: "
                                                + missingFingers);
                                    }

                                    Log.e(TAG, "Channel method call from flutter: " + handSide);

                                    // Check for missing fingers before starting capture
                                    checkMissingFingersBeforeCapture(handSide, missingFingers, result);

                                } catch (FlutterException e) {
                                    result.error(e.code, e.getMessage(), e.details);
                                } catch (Exception e) {
                                    result.error("PARSE_ERROR", "Failed to parse capture data", e.getMessage());
                                }
                            } else {
                                result.notImplemented();
                            }
                        });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        GuideNoGuideHelper.markIntroSetting(this, true);
    }

    /**
     * Check for missing fingers and show UI before starting capture
     */
    private void checkMissingFingersBeforeCapture(String handSide, List<String> missingFingers,
            MethodChannel.Result result) {
        selectedHand = handSide;
        Log.d(TAG, "Received missing fingers: " + missingFingers.toString());
        startFingerCapture(handSide, missingFingers, result);
    }

    /**
     * Start the actual fingerprint capture process
     */
    private void startFingerCapture(String handSide, List<String> missingFingers, MethodChannel.Result result) {
        Log.e(TAG, "Starting finger capture for: " + handSide + " with missing: " + missingFingers);

        // Show enhanced progress dialog
        showEnhancedProgressDialog(handSide);

        iniFingerCapture(MainActivity.this, handSide, missingFingers, result);
    }

    /**
     * Show enhanced progress dialog with better UI
     */
    private void showEnhancedProgressDialog(String handSide) {
        runOnUiThread(() -> {
            AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this,
                    android.R.style.Theme_Material_Dialog);

            LinearLayout layout = new LinearLayout(MainActivity.this);
            layout.setOrientation(LinearLayout.VERTICAL);
            layout.setPadding(80, 60, 80, 60); 
            layout.setGravity(Gravity.CENTER);
            layout.setBackgroundColor(Color.WHITE);

            TextView handIcon = new TextView(MainActivity.this);
            handIcon.setText("👋");
            handIcon.setTextSize(48);
            handIcon.setGravity(Gravity.CENTER);

            LinearLayout.LayoutParams handIconParams = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT);
            handIconParams.setMargins(0, 0, 0, 20);
            handIcon.setLayoutParams(handIconParams);
            layout.addView(handIcon);

            android.widget.ProgressBar progressBar = new android.widget.ProgressBar(MainActivity.this);
            progressBar.setIndeterminate(true);
            LinearLayout.LayoutParams progressParams = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT);
            progressParams.setMargins(0, 0, 0, 20);
            progressBar.setLayoutParams(progressParams);
            layout.addView(progressBar);

            // Title
            TextView title = new TextView(MainActivity.this);
            title.setText("Scanning " + handSide.toUpperCase() + " Hand");
            title.setTextSize(20); // Increased font size
            title.setTextColor(Color.parseColor("#2196F3"));
            title.setGravity(Gravity.CENTER);

            LinearLayout.LayoutParams titleParams = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT);
            titleParams.setMargins(0, 0, 0, 20);
            title.setLayoutParams(titleParams);
            layout.addView(title);

            // Instructions
            TextView instructions = new TextView(MainActivity.this);
            instructions.setText("Place your " + handSide + " hand (4 fingers) in front of the camera.\n\n" +
                    "• Keep your hand steady\n" +
                    "• Ensure good lighting\n" +
                    "• Follow the on-screen guidance");
            instructions.setTextSize(16);
            instructions.setTextColor(Color.parseColor("#666666"));
            instructions.setGravity(Gravity.CENTER);
            instructions.setLineSpacing(4.0f, 1.2f);

            LinearLayout.LayoutParams instructionsParams = new LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.MATCH_PARENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT);
            instructions.setLayoutParams(instructionsParams);
            layout.addView(instructions);

            builder.setView(layout);
            builder.setCancelable(false);

            customProgressDialog = builder.create();

            if (customProgressDialog.getWindow() != null) {
                int screenWidth = getResources().getDisplayMetrics().widthPixels;
                int dialogWidth = (int) (screenWidth * 0.85);

                customProgressDialog.getWindow().setLayout(
                        dialogWidth,
                        LinearLayout.LayoutParams.WRAP_CONTENT);

                customProgressDialog.getWindow()
                        .setBackgroundDrawableResource(android.R.drawable.dialog_holo_light_frame);
            }

            customProgressDialog.show();
        });
    }

    /**
     * Dismiss the enhanced progress dialog
     */
    private void dismissEnhancedProgressDialog() {
        runOnUiThread(() -> {
            if (customProgressDialog != null && customProgressDialog.isShowing()) {
                customProgressDialog.dismiss();
            }
        });
    }

    private void iniFingerCapture(Context context, String handSide, List<String> missingFingers,
            MethodChannel.Result result) {
        updateIntent(context, handSide, missingFingers);

        try {
            fingerUtils.fillRequiredTemplates();
            Log.d(TAG, "Initializing sdk");

            InputStream stream = getAssets().open(licenseFile);
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] array = new byte[4];
            int i;

            while ((i = stream.read(array, 0, array.length)) != -1) {
                output.write(array, 0, i);
            }

            byte[] data = output.toByteArray();
            stream.close();

            IdentySdk.newInstance(MainActivity.this, data, d -> {
                try {
                    Log.d("TAG", "Setup of Camera");
                    d.setAllowTabletLandscape(true);
                    d.setBase64EncodingFlag(base64encoding)
                            .disableMoveNextDetectionDialog()
                            .disableTraining()
                            // .enableGuide(false)
                            .displayResult(false)
                            .setDisplayImages(false)
                            .setMode(mode)
                            .setInlineGuide(true, new InlineGuideOption(400, 5)) // Enhanced inline guide
                            .setDetectionMode(detectionModes)
                            .displayImages(false)
                            .setDisplayBoxes(displayBoxes)
                            .setWSQCompression(compression)
                            .setRequiredTemplates(fingerUtils.fillRequiredTemplates())
                            .capture();

                } catch (Exception e) {
                    Log.d(TAG, "Failed to initialize sdk");
                    Log.d(TAG, Objects.requireNonNull(e.getMessage()));
                    dismissEnhancedProgressDialog();
                    result.error("INIT_ERROR", "Failed to initialize fingerprint SDK", e.getMessage());
                }
            }, new IdentyResponseListener() {

                @Override
                public void onAttempt(Hand hand, int attemptCount, Map<Finger, Attempt> attempt) {
                    Log.d(TAG, "Attempt " + attemptCount + " for hand: " + hand.toString());

                    runOnUiThread(() -> {
                        if (customProgressDialog != null && customProgressDialog.isShowing()) {
                            showToast("Scanning attempt " + attemptCount + " for " + hand.toString() + " hand");
                        }
                    });
                }

                @Override
                public void onResponse(IdentyResponse response, HashSet<String> transactionIds) {
                    Log.d(TAG, "JSON RESPONSE CAPTURED: " + response.toJson(MainActivity.this));

                    dismissEnhancedProgressDialog();
                    identySdkResponseList = new ArrayList<>();

                    for (Map.Entry<Pair<Hand, Finger>, FingerOutput> o : response.getPrints().entrySet()) {
                        Pair<Hand, Finger> handFinger = o.getKey();
                        FingerOutput fingerOutput = o.getValue();

                        try {
                            Template template = Template.WSQ;
                            if (fingerOutput.getTemplates().containsKey(template)) {
                                TemplateSize templateSize = TemplateSize.DEFAULT;

                                if (Objects.requireNonNull(fingerOutput.getTemplates().get(template))
                                        .containsKey(templateSize)) {
                                    String base64Str = Objects.requireNonNull(fingerOutput.getTemplates().get(template))
                                            .get(templateSize);
                                    String fileCode = fingerUtils.getFileNamingConvention(handFinger.first,
                                            handFinger.second);
                                    String fingerCode = null;

                                    switch (fileCode) {
                                        case "12":
                                            fingerCode = "L1";
                                            break;
                                        case "11":
                                            fingerCode = "R1";
                                            break;
                                        case "07":
                                            fingerCode = "L2";
                                            break;
                                        case "08":
                                            fingerCode = "L3";
                                            break;
                                        case "09":
                                            fingerCode = "L4";
                                            break;
                                        case "10":
                                            fingerCode = "L5";
                                            break;
                                        case "02":
                                            fingerCode = "R2";
                                            break;
                                        case "03":
                                            fingerCode = "R3";
                                            break;
                                        case "04":
                                            fingerCode = "R4";
                                            break;
                                        case "05":
                                            fingerCode = "R5";
                                            break;
                                    }

                                    if (fingerCode != null) {
                                        IdentySdkResponse identySdkResponse = new IdentySdkResponse(base64Str,
                                                fingerCode);
                                        identySdkResponseList.add(identySdkResponse);
                                    }
                                }
                            }
                        } catch (Exception e) {
                            Log.d(TAG, "Error Getting Identity List... " + e.getMessage());
                        }
                    }

                    try {
                        if (identySdkResponseList != null && !identySdkResponseList.isEmpty()) {
                            isResponseReceived = true;

                            Map<String, String> allFingersMap = new HashMap<>();
                            for (IdentySdkResponse identySdkResponse : identySdkResponseList) {
                                allFingersMap.put(identySdkResponse.getFingerCode(), identySdkResponse.getB64Wq());
                            }

                            showSuccessDialog(allFingersMap.size(), selectedHand);

                            result.success(allFingersMap);
                        } else {
                            showErrorDialog("No fingerprints captured", "Please try again");
                            result.success(new HashMap<>()); // Send an empty map if no fingers were captured
                        }
                    } catch (Exception e) {
                        Log.d(TAG, "Error collecting finger data: " + e.getMessage());
                        showErrorDialog("Error collecting fingerprint data", e.getMessage());
                        result.error("error", "Failed to collect finger data", e.getMessage());
                    }
                }

                @Override
                public void onErrorResponse(IdentyError error, HashSet<String> transactionIds) {
                    dismissEnhancedProgressDialog();
                    Log.e(TAG, "Fingerprint capture error: " + error.getMessage());

                    showErrorDialog("Fingerprint Capture Failed", error.getMessage());
                    result.error("error", "Error during fingerprint capture", error.getMessage());
                }
            }, false, true);

        } catch (Exception e) {
            dismissEnhancedProgressDialog();
            Log.d(TAG, "Failed to initialize sdk: " + e.getMessage());
            result.error("INIT_ERROR", "Failed to initialize SDK", e.getMessage());
        }
    }

    private void updateIntent(Context context, String handSide, List<String> missingFingers) {
        ArrayList<FingerDetectionMode> modes = new ArrayList<>();

        Log.d(TAG, "=== DIRECT DATA DEBUG ===");
        Log.d(TAG, "Hand: " + handSide);
        Log.d(TAG, "Missing fingers: " + missingFingers.toString());

        if (handSide.equalsIgnoreCase("left")) {
            if (missingFingers.isEmpty()) {
                modes.add(FingerDetectionMode.L4F);
                Log.d(TAG, "Added L4F mode (all 4 fingers)");
            } else {
                if (!missingFingers.contains("index")) {
                    modes.add(FingerDetectionMode.LEFT_INDEX);
                    Log.d(TAG, "Added LEFT_INDEX");
                }
                if (!missingFingers.contains("middle")) {
                    modes.add(FingerDetectionMode.LEFT_MIDDLE);
                    Log.d(TAG, "Added LEFT_MIDDLE");
                }
                if (!missingFingers.contains("ring")) {
                    modes.add(FingerDetectionMode.LEFT_RING);
                    Log.d(TAG, "Added LEFT_RING");
                }
                if (!missingFingers.contains("little")) {
                    modes.add(FingerDetectionMode.LEFT_LITTLE);
                    Log.d(TAG, "Added LEFT_LITTLE");
                }
            }
        } else if (handSide.equalsIgnoreCase("right")) {
            if (missingFingers.isEmpty()) {
                modes.add(FingerDetectionMode.R4F);
                Log.d(TAG, "Added R4F mode (all 4 fingers)");
            } else {
                if (!missingFingers.contains("index")) {
                    modes.add(FingerDetectionMode.RIGHT_INDEX);
                    Log.d(TAG, "Added RIGHT_INDEX");
                }
                if (!missingFingers.contains("middle")) {
                    modes.add(FingerDetectionMode.RIGHT_MIDDLE);
                    Log.d(TAG, "Added RIGHT_MIDDLE");
                }
                if (!missingFingers.contains("ring")) {
                    modes.add(FingerDetectionMode.RIGHT_RING);
                    Log.d(TAG, "Added RIGHT_RING");
                }
                if (!missingFingers.contains("little")) {
                    modes.add(FingerDetectionMode.RIGHT_LITTLE);
                    Log.d(TAG, "Added RIGHT_LITTLE");
                }
            }
        }

        detectionModes = modes.toArray(new FingerDetectionMode[0]);
        Log.d(TAG, "Final detection modes: " + modes.toString());
        Log.d(TAG, "=== END DIRECT DATA DEBUG ===");
    }

    private void showSuccessDialog(int fingersCount, String hand) {
        runOnUiThread(() -> {
            AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this,
                    android.R.style.Theme_Material_Dialog);

            LinearLayout layout = new LinearLayout(MainActivity.this);
            layout.setOrientation(LinearLayout.VERTICAL);
            layout.setPadding(50, 30, 50, 30);
            layout.setGravity(Gravity.CENTER);
            layout.setBackgroundColor(Color.WHITE);

            // Success icon
            TextView successIcon = new TextView(MainActivity.this);
            successIcon.setText("✓");
            successIcon.setTextSize(48);
            successIcon.setTextColor(Color.parseColor("#4CAF50"));
            successIcon.setGravity(Gravity.CENTER);
            layout.addView(successIcon);

            TextView title = new TextView(MainActivity.this);
            title.setText("Capture Successful!");
            title.setTextSize(18);
            title.setTextColor(Color.parseColor("#4CAF50"));
            title.setGravity(Gravity.CENTER);
            title.setPadding(0, 10, 0, 10);
            layout.addView(title);

            TextView message = new TextView(MainActivity.this);
            message.setText("Successfully captured " + fingersCount + " fingerprint(s) from " + hand + " hand.");
            message.setTextSize(14);
            message.setTextColor(Color.parseColor("#666666"));
            message.setGravity(Gravity.CENTER);
            layout.addView(message);

            builder.setView(layout);
            builder.setPositiveButton("OK", (dialog, which) -> dialog.dismiss());
            builder.setCancelable(false);

            AlertDialog dialog = builder.create();
            dialog.show();
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.parseColor("#4CAF50"));
        });
    }

    /**
     * Show error dialog
     */
    private void showErrorDialog(String title, String message) {
        runOnUiThread(() -> {
            AlertDialog.Builder builder = new AlertDialog.Builder(MainActivity.this,
                    android.R.style.Theme_Material_Dialog);

            LinearLayout layout = new LinearLayout(MainActivity.this);
            layout.setOrientation(LinearLayout.VERTICAL);
            layout.setPadding(50, 30, 50, 30);
            layout.setGravity(Gravity.CENTER);
            layout.setBackgroundColor(Color.WHITE);

            // Error icon
            TextView errorIcon = new TextView(MainActivity.this);
            errorIcon.setText("✗");
            errorIcon.setTextSize(48);
            errorIcon.setTextColor(Color.parseColor("#F44336"));
            errorIcon.setGravity(Gravity.CENTER);
            layout.addView(errorIcon);

            TextView titleView = new TextView(MainActivity.this);
            titleView.setText(title);
            titleView.setTextSize(18);
            titleView.setTextColor(Color.parseColor("#F44336"));
            titleView.setGravity(Gravity.CENTER);
            titleView.setPadding(0, 10, 0, 10);
            layout.addView(titleView);

            TextView messageView = new TextView(MainActivity.this);
            messageView.setText(message);
            messageView.setTextSize(14);
            messageView.setTextColor(Color.parseColor("#666666"));
            messageView.setGravity(Gravity.CENTER);
            layout.addView(messageView);

            builder.setView(layout);
            builder.setPositiveButton("OK", (dialog, which) -> dialog.dismiss());
            builder.setCancelable(false);

            AlertDialog dialog = builder.create();
            dialog.show();
            dialog.getButton(AlertDialog.BUTTON_POSITIVE).setTextColor(Color.parseColor("#F44336"));
        });
    }

    /**
     * Show toast message
     */
    private void showToast(String message) {
        runOnUiThread(() -> {
            Toast toast = Toast.makeText(MainActivity.this, message, Toast.LENGTH_SHORT);
            toast.setGravity(Gravity.CENTER, 0, 0);
            toast.show();
        });
    }
}