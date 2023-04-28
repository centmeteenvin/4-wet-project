package be.uantwerpen.fti.ei.project.smollar.API.models;

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
    private ArrayList<SpaceTimeStamp> locations;
    private boolean callBack;
    private Fence fence;


    public Device() {
        this("", "", new ArrayList<>(), false, new Fence());
    }


    public Device(String deviceId, String deviceName, ArrayList<SpaceTimeStamp> locations, boolean callBack, Fence fence) {
        this.deviceId = deviceId;
        this.deviceName = deviceName;
        this.locations = locations;
        this.callBack = callBack;
        this.fence = fence;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        Device device = (Device) o;

        if (!deviceId.equals(device.deviceId)) return false;
        if (!deviceName.equals(device.deviceName)) return false;
        return locations.equals(device.locations);
    }

    @Override
    public int hashCode() {
        int result = deviceId.hashCode();
        result = 31 * result + deviceName.hashCode();
        result = 31 * result + locations.hashCode();
        return result;
    }

    public Device(String deviceName, ArrayList<SpaceTimeStamp> locations) {
        this.deviceId = UUID.randomUUID().toString();
        this.deviceName = deviceName;
        this.locations = locations;
        this.fence = new Fence();
    }

    @Override
    public String toString() {
        return "Device{" +
                "deviceId='" + deviceId + '\'' +
                ", deviceName='" + deviceName + '\'' +
                ", locations=" + locations + "'" +
                ",callBack=" + callBack +
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

    public ArrayList<SpaceTimeStamp> getLocations() {
        return locations;
    }

    public void setLocations(ArrayList<SpaceTimeStamp> locations) {
        this.locations = locations;
    }
    public Fence getFence() {
        return fence;
    }

    public void setFence(Fence fence) {
        this.fence = fence;
    }
    public boolean isCallBack() {
        return callBack;
    }

    public void setCallBack(boolean callBack) {
        this.callBack = callBack;
    }
}
