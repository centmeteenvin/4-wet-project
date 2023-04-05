package be.uantwerpen.fti.ei.project.smollar.API.models;

import com.google.cloud.Timestamp;
import com.google.cloud.firestore.GeoPoint;

public class SpaceTimeStamp {
    private Timestamp timestamp;
    private GeoPoint coordinate;

    public SpaceTimeStamp(Timestamp timestamp, GeoPoint coordinate) {
        this.timestamp = timestamp;
        this.coordinate = coordinate;
    }

    public GeoPoint getCoordinate() {
        return coordinate;
    }

    public void setCoordinate(GeoPoint coordinate) {
        this.coordinate = coordinate;
    }

    public Timestamp getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Timestamp timestamp) {
        this.timestamp = timestamp;
    }

}
