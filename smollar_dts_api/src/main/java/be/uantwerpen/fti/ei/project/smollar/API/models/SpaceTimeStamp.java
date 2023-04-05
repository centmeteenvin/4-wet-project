package be.uantwerpen.fti.ei.project.smollar.API.models;

import com.fasterxml.jackson.core.JacksonException;
import com.fasterxml.jackson.core.JsonParser;
import com.fasterxml.jackson.databind.DeserializationContext;
import com.fasterxml.jackson.databind.JsonDeserializer;
import com.fasterxml.jackson.databind.JsonNode;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.GeoPoint;

import java.io.IOException;

public class SpaceTimeStamp {
    private Timestamp timestamp;
    private GeoPoint coordinate;

    public SpaceTimeStamp(String RFC3339timeString, GeoPoint coordinate) {
        this.timestamp = Timestamp.parseTimestamp(RFC3339timeString);
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
