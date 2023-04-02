package be.uantwerpen.fti.ei.project.smollar.API;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.GeoPoint;
import firestore.Device;
import firestore.DeviceRepository;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@RestController
public class Controller {

    private DeviceRepository deviceRepository;
    public Controller(Firestore firestore) {
        this.deviceRepository = new DeviceRepository(firestore);
    }

    @PatchMapping("/{deviceId}")
    public boolean updateLocations(@PathVariable String deviceId, @RequestBody Map<String, String> body) {
        Device device = deviceRepository.get(deviceId);
        ArrayList<Map<String, GeoPoint>> locations = device.getLocations();
        HashMap<String, GeoPoint> newLocationEntry = new HashMap<>(1);
        newLocationEntry.put(
                body.get("timeStamp"),
                new GeoPoint(
                        Double.parseDouble(body.get("latitude")),
                        Double.parseDouble(body.get("longitude"))
                )
        );
        locations.add(newLocationEntry);
        return deviceRepository.save(device);
    }
}
