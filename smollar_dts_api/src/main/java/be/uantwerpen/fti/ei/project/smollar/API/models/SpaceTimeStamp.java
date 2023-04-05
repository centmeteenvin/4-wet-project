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

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        SpaceTimeStamp that = (SpaceTimeStamp) o;

        if (timestamp.getSeconds() != that.timestamp.getSeconds()) return false;
        if (coordinate.getLatitude() != that.coordinate.getLatitude()) return false;
        return coordinate.getLongitude() == that.coordinate.getLongitude();
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

    @Override
    public String toString() {
        return "SpaceTimeStamp{" +
                "timestamp=" + timestamp +
                ", coordinate=" + coordinate +
                '}';
    }

}
