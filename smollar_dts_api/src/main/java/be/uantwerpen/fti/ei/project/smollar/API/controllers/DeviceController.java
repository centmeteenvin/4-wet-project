package be.uantwerpen.fti.ei.project.smollar.API.controllers;

import be.uantwerpen.fti.ei.project.smollar.API.models.SpaceTimeStamp;
import com.google.cloud.firestore.Firestore;
import be.uantwerpen.fti.ei.project.smollar.API.models.Device;
import be.uantwerpen.fti.ei.project.smollar.API.repositories.DeviceRepository;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
public class DeviceController {

    private DeviceRepository deviceRepository;

    public DeviceController(Firestore firestore) {
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
    public ResponseEntity updateLocations(@PathVariable String deviceId, @RequestBody ArrayList<SpaceTimeStamp> spaceTimeStamps) {
        Device device = deviceRepository.get(deviceId);
        ArrayList<SpaceTimeStamp> locations = device.getLocations();
        locations.addAll(spaceTimeStamps);

        if (deviceRepository.save(device)) {
            return new ResponseEntity<Device>(device, HttpStatusCode.valueOf(200));
        }
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
