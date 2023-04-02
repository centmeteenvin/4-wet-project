package be.uantwerpen.fti.ei.project.smollar.API;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.GeoPoint;
import firestore.Device;
import firestore.DeviceRepository;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
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

    @GetMapping("/devices/{deviceId}")
    public ResponseEntity getDevice(@PathVariable String deviceId) {
        Device device = deviceRepository.get(deviceId);
        if (device == null) {
            return new ResponseEntity<String>("Device not found", HttpStatusCode.valueOf(404));
        }
        return new ResponseEntity<Device>(device, HttpStatusCode.valueOf(200));
    }

    @PostMapping("/devices/{deviceId}")
    public ResponseEntity createDevice(@PathVariable String deviceId, @RequestBody String deviceName) {
        if (deviceRepository.get(deviceId) != null) {
            return new ResponseEntity<String>("Device already exists", HttpStatusCode.valueOf(409));
        }
        Device device = new Device(deviceId, deviceName, new ArrayList<>());
        boolean result = deviceRepository.save(device);
        if (!result)
            return new ResponseEntity<String>("Error in pushing resource to databse", HttpStatusCode.valueOf(500));
        return new ResponseEntity<Device>(device, HttpStatusCode.valueOf(201));
    }

    @PatchMapping("/devices/{deviceId}")
    public ResponseEntity updateLocations(@PathVariable String deviceId, @RequestBody Map<String, String> body) {
        Device device = deviceRepository.get(deviceId);
        ArrayList<Map<String, GeoPoint>> locations = device.getLocations();
        HashMap<String, GeoPoint> newLocationEntry = new HashMap<>(1);
        newLocationEntry.put(body.get("timeStamp"), new GeoPoint(Double.parseDouble(body.get("latitude")), Double.parseDouble(body.get("longitude"))));
        locations.add(newLocationEntry);
        if (deviceRepository.save(device)) return new ResponseEntity<Device>(device, HttpStatusCode.valueOf(200));
        return new ResponseEntity<String>("Error in pushing resource to database", HttpStatusCode.valueOf(500));
    }

    @DeleteMapping("/devices/{deviceId}")
    public ResponseEntity deleteDevice(@PathVariable String deviceId) {
        boolean result = deviceRepository.delete(deviceId);
        if (!result) {
            return new ResponseEntity<String>("Device not found", HttpStatusCode.valueOf(404));
        }
        return new ResponseEntity<Boolean>(true, HttpStatusCode.valueOf(200));
    }
}
