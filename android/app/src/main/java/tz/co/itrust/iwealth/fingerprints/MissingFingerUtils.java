package tz.co.itrust.iwealth.fingerprints;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;
import android.util.Log;

import com.identy.enums.FingerDetectionMode;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class MissingFingerUtils {
    
    private static final String LEFT_KEY = "missing_fingers_left";
    private static final String RIGHT_KEY = "missing_fingers_right";
    private static final String TAG = "MissingFingerUtils";

    /**
     * Save the set of missing fingers to SharedPreferences
     */
    public static void saveStringSet(Set<String> missingFingers, Context context) {
        // This method is deprecated, but keeping for backward compatibility
        try {
            SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
            SharedPreferences.Editor editor = sharedPreferences.edit();

            if (missingFingers == null || missingFingers.isEmpty()) {
                editor.remove(LEFT_KEY);
                editor.remove(RIGHT_KEY);
                Log.d(TAG, "Cleared missing fingers preference");
            }

            editor.apply();
        } catch (Exception e) {
            Log.e(TAG, "Error saving missing fingers: " + e.getMessage());
        }
    }

    /**
     * Retrieve the set of missing fingers from SharedPreferences
     */
    public static Set<String> retrieveStringSet(Context context) {
        // Return combined set from both hands for backward compatibility
        Set<String> combined = new HashSet<>();
        try {
            SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
            Set<String> leftFingers = sharedPreferences.getStringSet(LEFT_KEY, new HashSet<>());
            Set<String> rightFingers = sharedPreferences.getStringSet(RIGHT_KEY, new HashSet<>());
            combined.addAll(leftFingers);
            combined.addAll(rightFingers);
            Log.d(TAG, "Retrieved combined missing fingers: " + combined.toString());
        } catch (Exception e) {
            Log.e(TAG, "Error retrieving missing fingers: " + e.getMessage());
        }
        return combined;
    }

    /**
     * Get list of missing fingers for left hand
     */
    public static List<FingerDetectionMode> getLeftMissingFingers(Context context) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        Set<String> flutterFingers = sharedPreferences.getStringSet(LEFT_KEY, new HashSet<>());
        List<FingerDetectionMode> modes = new ArrayList<>();

        for (String flutterFinger : flutterFingers) {
            FingerDetectionMode mode = convertFlutterFinger(flutterFinger, true);
            if (mode != null) {
                modes.add(mode);
            }
        }

        Log.d(TAG, "Left hand missing fingers: " + modes.toString());
        return modes;
    }
    
    private static FingerDetectionMode convertFlutterFinger(String flutterFinger, boolean isLeftHand) {
        switch (flutterFinger.toLowerCase()) {
            case "index":
                return isLeftHand ? FingerDetectionMode.LEFT_INDEX : FingerDetectionMode.RIGHT_INDEX;
            case "middle":
                return isLeftHand ? FingerDetectionMode.LEFT_MIDDLE : FingerDetectionMode.RIGHT_MIDDLE;
            case "ring":
                return isLeftHand ? FingerDetectionMode.LEFT_RING : FingerDetectionMode.RIGHT_RING;
            case "little":
                return isLeftHand ? FingerDetectionMode.LEFT_LITTLE : FingerDetectionMode.RIGHT_LITTLE;
            default:
                return null;
        }
    }

    /**
     * Get list of missing fingers for right hand
     */
    public static List<FingerDetectionMode> getRightMissingFingers(Context context) {
        SharedPreferences sharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
        Set<String> flutterFingers = sharedPreferences.getStringSet(RIGHT_KEY, new HashSet<>());
        List<FingerDetectionMode> modes = new ArrayList<>();

        for (String flutterFinger : flutterFingers) {
            FingerDetectionMode mode = convertFlutterFinger(flutterFinger, false);
            if (mode != null) {
                modes.add(mode);
            }
        }

        Log.d(TAG, "Right hand missing fingers: " + modes.toString());
        return modes;
    }

    /**
     * Get available (non-missing) fingers for left hand
     */
    public static List<FingerDetectionMode> getLeftAvailableFingers(Context context) {
        List<FingerDetectionMode> missingFingers = getLeftMissingFingers(context);
        List<FingerDetectionMode> availableFingers = new ArrayList<>();
        
        if (!missingFingers.contains(FingerDetectionMode.LEFT_INDEX)) {
            availableFingers.add(FingerDetectionMode.LEFT_INDEX);
        }
        if (!missingFingers.contains(FingerDetectionMode.LEFT_MIDDLE)) {
            availableFingers.add(FingerDetectionMode.LEFT_MIDDLE);
        }
        if (!missingFingers.contains(FingerDetectionMode.LEFT_RING)) {
            availableFingers.add(FingerDetectionMode.LEFT_RING);
        }
        if (!missingFingers.contains(FingerDetectionMode.LEFT_LITTLE)) {
            availableFingers.add(FingerDetectionMode.LEFT_LITTLE);
        }
        
        Log.d(TAG, "Left hand available fingers: " + availableFingers.toString());
        return availableFingers;
    }

    /**
     * Get available (non-missing) fingers for right hand
     */
    public static List<FingerDetectionMode> getRightAvailableFingers(Context context) {
        List<FingerDetectionMode> missingFingers = getRightMissingFingers(context);
        List<FingerDetectionMode> availableFingers = new ArrayList<>();
        
        if (!missingFingers.contains(FingerDetectionMode.RIGHT_INDEX)) {
            availableFingers.add(FingerDetectionMode.RIGHT_INDEX);
        }
        if (!missingFingers.contains(FingerDetectionMode.RIGHT_MIDDLE)) {
            availableFingers.add(FingerDetectionMode.RIGHT_MIDDLE);
        }
        if (!missingFingers.contains(FingerDetectionMode.RIGHT_RING)) {
            availableFingers.add(FingerDetectionMode.RIGHT_RING);
        }
        if (!missingFingers.contains(FingerDetectionMode.RIGHT_LITTLE)) {
            availableFingers.add(FingerDetectionMode.RIGHT_LITTLE);
        }
        
        Log.d(TAG, "Right hand available fingers: " + availableFingers.toString());
        return availableFingers;
    }

    /**
     * Check if user has any missing fingers configured
     */
    public static boolean hasMissingFingers(Context context) {
        Set<String> missingFingers = retrieveStringSet(context);
        return !missingFingers.isEmpty();
    }

    /**
     * Get total count of missing fingers
     */
    public static int getMissingFingersCount(Context context) {
        Set<String> missingFingers = retrieveStringSet(context);
        return missingFingers.size();
    }

    /**
     * Get total count of available fingers for a specific hand
     */
    public static int getAvailableFingersCount(Context context, String hand) {
        if (hand.equalsIgnoreCase("left")) {
            return getLeftAvailableFingers(context).size();
        } else if (hand.equalsIgnoreCase("right")) {
            return getRightAvailableFingers(context).size();
        }
        return 0;
    }

    /**
     * Clear all missing finger preferences
     */
    public static void clearMissingFingers(Context context) {
        saveStringSet(new HashSet<>(), context);
        Log.d(TAG, "Cleared all missing finger preferences");
    }

    /**
     * Check if a specific finger is marked as missing
     */
    public static boolean isFingerMissing(Context context, FingerDetectionMode finger) {
        Set<String> missingFingers = retrieveStringSet(context);
        return missingFingers.contains(finger.toString());
    }

    /**
     * Add a finger to the missing fingers list
     */
    public static void addMissingFinger(Context context, FingerDetectionMode finger) {
        Set<String> missingFingers = retrieveStringSet(context);
        missingFingers.add(finger.toString());
        saveStringSet(missingFingers, context);
    }

    /**
     * Remove a finger from the missing fingers list
     */
    public static void removeMissingFinger(Context context, FingerDetectionMode finger) {
        Set<String> missingFingers = retrieveStringSet(context);
        missingFingers.remove(finger.toString());
        saveStringSet(missingFingers, context);
    }

    /**
     * Get human-readable finger name
     */
    public static String getFingerDisplayName(FingerDetectionMode finger) {
        switch (finger) {
            case LEFT_INDEX:
                return "Left Index";
            case LEFT_MIDDLE:
                return "Left Middle";
            case LEFT_RING:
                return "Left Ring";
            case LEFT_LITTLE:
                return "Left Little";
            case RIGHT_INDEX:
                return "Right Index";
            case RIGHT_MIDDLE:
                return "Right Middle";
            case RIGHT_RING:
                return "Right Ring";
            case RIGHT_LITTLE:
                return "Right Little";
            default:
                return finger.toString();
        }
    }

    /**
     * Validate that at least one finger is available for capture
     */
    public static boolean hasEnoughFingersForCapture(Context context, String hand) {
        int availableCount = getAvailableFingersCount(context, hand);
        boolean hasEnough = availableCount > 0;
        
        Log.d(TAG, "Hand: " + hand + ", Available fingers: " + availableCount + ", Has enough: " + hasEnough);
        return hasEnough;
    }
}