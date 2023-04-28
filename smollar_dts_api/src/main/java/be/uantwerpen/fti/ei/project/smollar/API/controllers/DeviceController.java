package be.uantwerpen.fti.ei.project.smollar.API.controllers;

import be.uantwerpen.fti.ei.project.smollar.API.models.Fence;
import be.uantwerpen.fti.ei.project.smollar.API.models.SpaceTimeStamp;
import com.google.cloud.firestore.Firestore;
import be.uantwerpen.fti.ei.project.smollar.API.models.Device;
import be.uantwerpen.fti.ei.project.smollar.API.repositories.DeviceRepository;
import com.google.cloud.firestore.GeoPoint;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.enums.ParameterIn;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import org.apache.commons.lang3.BooleanUtils;
import org.checkerframework.checker.units.qual.A;
import org.checkerframework.checker.units.qual.C;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;

@RestController
@RequestMapping("api/v1/devices")
public class DeviceController {

    private final DeviceRepository deviceRepository;

    public DeviceController(Firestore firestore) {
        this.deviceRepository = new DeviceRepository(firestore);
    }

    @GetMapping("/{deviceId}")
    @Operation(
            summary = "Get device",
            description = "Get device from the device Id",
            tags = {"Devices"},
            parameters = {
                    @Parameter(name = "deviceId", description = "The Id of the device, preferably a UUID string", in = ParameterIn.PATH)
            },
            responses = {
                    @ApiResponse(responseCode = "200",
                            description = "Successfully fetched the device",
                            content = @Content(
                                    schema = @Schema(implementation = Device.class)
                            )
                    ),
                    @ApiResponse(responseCode = "404", description = "The device with the given id does not exist")
            }
    )
    public ResponseEntity getDevice(@PathVariable String deviceId) {
        Device device = deviceRepository.get(deviceId);
        if (device == null) {
            return new ResponseEntity<String>("Device not found", HttpStatusCode.valueOf(404));
        }
        return new ResponseEntity<Device>(device, HttpStatusCode.valueOf(200));
    }

    @GetMapping("/{deviceId}/fence")
    @Operation(
            summary = "Get device's fence",
            description = "Get fence from the device Id",
            tags = {"Devices"},
            parameters = {
                    @Parameter(name = "deviceId", description = "The Id of the device, preferably a UUID string", in = ParameterIn.PATH)
            },
            responses = {
                    @ApiResponse(responseCode = "200",
                            description = "Successfully fetched the fence",
                            content = @Content(
                                    schema = @Schema(implementation = Device.class)
                            )
                    ),
                    @ApiResponse(responseCode = "404", description = "The device with the given id does not exist")
            }
    )
    public ResponseEntity getFene(@PathVariable String deviceId) {
        Device device = deviceRepository.get(deviceId);
        if (device == null) {
            return new ResponseEntity<String>("Device not found",  HttpStatusCode.valueOf(404));
        }
        return new ResponseEntity<Fence>(device.getFence(), HttpStatusCode.valueOf(200));
    }

    @PostMapping("/{deviceId}")
    @Operation(
            summary = "Create a device",
            description = "Create a device with the given deviceId and name",
            tags = {"Devices"},
            parameters = {
                    @Parameter(name = "deviceId", description = "The Id you want to give the new device, preferable a UUID string", in = ParameterIn.PATH)
            },
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "The Name You want to give your device",
                    required = true,
                    content = @Content(mediaType = "text" ,
                            schema = @Schema(implementation = String.class),
                            examples = @ExampleObject(value = "Device Name Here")
                    )
            ),
            responses = {
                    @ApiResponse(responseCode = "201",
                            description = "Device created and registered",
                            content = @Content(
                                    mediaType = "application/json",
                                    schema = @Schema(implementation = Device.class)
                            )
                    ),
                    @ApiResponse(
                            responseCode = "409",
                            description = "Device already exists",
                            content = @Content(mediaType = "text", schema = @Schema(name = "Error message", implementation = String.class))
                    ),
                    @ApiResponse(
                            responseCode = "500",
                            description = "Internal server error"
                    )
            }
    )
    public ResponseEntity createDevice(@PathVariable String deviceId, @RequestBody String deviceName) {
        if (deviceRepository.get(deviceId) != null) {
            return new ResponseEntity<String>("Device already exists", HttpStatusCode.valueOf(409));
        }
        Device device = new Device(deviceId, deviceName, new ArrayList<>(), false, new Fence());
        boolean result = deviceRepository.create(device);
        if (!result)
            return new ResponseEntity<String>("Error in pushing resource to databse", HttpStatusCode.valueOf(500));
        return new ResponseEntity<Device>(device, HttpStatusCode.valueOf(201));
    }

    @PutMapping("/{deviceId}")
    @Operation(
            summary = "Add SpaceTimePoints",
            description = "Append one or more SpaceTimePoints to the give device",
            tags = {"Devices"},
            parameters = {
                    @Parameter(
                            name = "deviceId",
                            description = "The id of the device you want to append the spacetimepoints to",
                            in = ParameterIn.PATH
                    )
            },
            requestBody = @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    description = "A list of the spacetimepoints that need to be added to the list",
                    content = @Content(
                            mediaType = "application/json",
                            schema = @Schema(implementation = SpaceTimeStamp.class, type = "array")
                    )
            ),
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Succesfully updated the location, we don't return the entire resource again because we need to really minimize traffic."
                    ),
                    @ApiResponse(
                            responseCode = "404",
                            description = "Device not found or doesn't exist"
                    ),
                    @ApiResponse(
                            responseCode = "500",
                            description = "Internal server error"
                    )
            }
    )
    public ResponseEntity updateLocations(@PathVariable String deviceId, @RequestBody ArrayList<SpaceTimeStamp> spaceTimeStamps) {
        Device device = deviceRepository.get(deviceId);
        if (device == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Device not found");
        }
        ArrayList<SpaceTimeStamp> locations = device.getLocations();
        locations.addAll(spaceTimeStamps);

        if (deviceRepository.save(device)) {
            int isCallBack = BooleanUtils.toInteger(device.isCallBack());
            int fenceInUse = BooleanUtils.toInteger(device.getFence().isInUse());
            int fenceId = deviceRepository.getFenceMap().get(deviceId).getValue();
            return new ResponseEntity<String>(isCallBack + "" + fenceInUse + "" + fenceId, HttpStatusCode.valueOf(200));
        }
        return new ResponseEntity<String>("Error in pushing resource to database", HttpStatusCode.valueOf(500));
    }

    @DeleteMapping("/{deviceId}")
    @Operation(
            summary = "Delete a device",
            description = "Delete a device by the given deviceId",
            tags = {"Devices"},
            parameters = {
                    @Parameter(name = "deviceId", description = "The id of the device you want to delete", in = ParameterIn.PATH)
            },
            responses = {
                    @ApiResponse(
                            responseCode = "200",
                            description = "Successfully deleted device"
                    ),
                    @ApiResponse(
                            responseCode = "404",
                            description = "Device not found"
                    )
            }
    )
    public ResponseEntity deleteDevice(@PathVariable String deviceId) {
        boolean result = deviceRepository.delete(deviceId);
        if (!result) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Device not found");
        }
        return ResponseEntity.ok().body("Successfully deleted device");
    }
}
