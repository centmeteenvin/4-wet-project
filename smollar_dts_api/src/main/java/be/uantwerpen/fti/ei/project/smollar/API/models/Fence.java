package be.uantwerpen.fti.ei.project.smollar.API.models;

import com.google.cloud.firestore.GeoPoint;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.lang3.builder.EqualsExclude;

import java.util.Objects;

@Data public class Fence {
    @EqualsAndHashCode.Exclude
    private boolean inUse = false;
    private GeoPoint anchor = new GeoPoint(0,0);
    private double distance = 0;
}
