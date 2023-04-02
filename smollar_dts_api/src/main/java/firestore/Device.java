package firestore;

import com.google.api.client.util.DateTime;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.GeoPoint;
import com.google.cloud.firestore.annotation.DocumentId;

import java.util.ArrayList;
import java.util.Map;
import java.util.UUID;

public class Device {
    @DocumentId
    private String deviceId;
    private String deviceName;
    private ArrayList<Map<String, GeoPoint>> locations;

    public Device(String deviceId, String deviceName, ArrayList<Map<String, GeoPoint>> locations) {
        this.deviceId = deviceId;
        this.deviceName = deviceName;
        this.locations = locations;
    }

    public Device(String deviceName, ArrayList<Map<String, GeoPoint>> locations) {
        this.deviceId = UUID.randomUUID().toString();
        this.deviceName = deviceName;
        this.locations = locations;
    }

    @Override
    public String toString() {
        return "Device{" +
                "deviceId='" + deviceId + '\'' +
                ", deviceName='" + deviceName + '\'' +
                ", locations=" + locations +
                '}';
    }

    public String getDeviceId() {
        return deviceId;
    }

    public void setDeviceId(String deviceId) {
        this.deviceId = deviceId;
    }

    public String getDeviceName() {
        return deviceName;
    }

    public void setDeviceName(String deviceName) {
        this.deviceName = deviceName;
    }

    public ArrayList<Map<String, GeoPoint>> getLocations() {
        return locations;
    }

    public void setLocations(ArrayList<Map<String, GeoPoint>> locations) {
        this.locations = locations;
    }
}
