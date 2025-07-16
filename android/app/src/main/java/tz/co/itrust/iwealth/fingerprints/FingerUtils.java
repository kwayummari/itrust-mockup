package tz.co.itrust.iwealth.fingerprints;


import com.identy.TemplateSize;
import com.identy.enums.Finger;
import com.identy.enums.Hand;
import com.identy.enums.Template;

import java.util.ArrayList;
import java.util.HashMap;

public class FingerUtils {

    public HashMap<Template, HashMap<Finger, ArrayList<TemplateSize>>> requiredtemplates;

    public String getFileNamingConvention(Hand hand, Finger finger) {

        if (hand.equals(Hand.RIGHT)) {
            if (finger.equals(Finger.INDEX)) {
                return "02";
            } else if (finger.equals(Finger.MIDDLE)) {
                return "03";
            } else if (finger.equals(Finger.RING)) {
                return "04";
            } else if (finger.equals(Finger.LITTLE)) {
                return "05";
            } else if (finger.equals(Finger.THUMB)) {
                return "11";
            }


        } else if (hand.equals(Hand.LEFT)) {
            if (finger.equals(Finger.INDEX)) {
                return "07";
            } else if (finger.equals(Finger.MIDDLE)) {
                return "08";
            } else if (finger.equals(Finger.RING)) {
                return "09";
            } else if (finger.equals(Finger.LITTLE)) {
                return "10";
            } else if (finger.equals(Finger.THUMB)) {
                return "12";
            }
        }
        return "";
    }

    //Fill in required templates (try in initFingerCapture)
    public HashMap<Template, HashMap<Finger, ArrayList<TemplateSize>>> fillRequiredTemplates() {
        requiredtemplates = new HashMap<>();
        ArrayList<TemplateSize> wsqTemplateSizes = new ArrayList<>();
        wsqTemplateSizes.add(TemplateSize.DEFAULT);
        HashMap<Finger, ArrayList<TemplateSize>> wsqFingerToGetTemplatesFor = new HashMap<>();
        wsqFingerToGetTemplatesFor.put(Finger.INDEX, wsqTemplateSizes);
        wsqFingerToGetTemplatesFor.put(Finger.MIDDLE, wsqTemplateSizes);
        wsqFingerToGetTemplatesFor.put(Finger.RING, wsqTemplateSizes);
        wsqFingerToGetTemplatesFor.put(Finger.LITTLE, wsqTemplateSizes);
        requiredtemplates.put(Template.WSQ, wsqFingerToGetTemplatesFor);
        return requiredtemplates;

    }
}