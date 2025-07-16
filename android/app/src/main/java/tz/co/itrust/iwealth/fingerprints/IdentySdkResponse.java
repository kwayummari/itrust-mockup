package tz.co.itrust.iwealth.fingerprints;


public class IdentySdkResponse {

    private String b64Wq;
    private String fingerCode;

    public IdentySdkResponse(String base64WSQ, String finger_code) {
        this.b64Wq = base64WSQ;
        this.fingerCode = finger_code;
    }

    public String getB64Wq() {
        return b64Wq;
    }

    public void setB64Wq(String b64Wq) {
        this.b64Wq = b64Wq;
    }

    public String getFingerCode() {
        return fingerCode;
    }

    public void setFingerCode(String fingerCode) {
        this.fingerCode = fingerCode;
    }
}