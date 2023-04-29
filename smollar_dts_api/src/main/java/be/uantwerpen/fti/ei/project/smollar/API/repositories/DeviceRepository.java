package be.uantwerpen.fti.ei.project.smollar.API.repositories;

import be.uantwerpen.fti.ei.project.smollar.API.models.Device;
import be.uantwerpen.fti.ei.project.smollar.API.models.Fence;
import be.uantwerpen.fti.ei.project.smollar.API.models.SpaceTimeStamp;
import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.commons.lang3.tuple.Pair;

import javax.print.Doc;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;

@Slf4j
public class DeviceRepository {
    private final CollectionReference collectionReference;
    private final String collectionName = "Devices";
    @Getter
    private final HashMap<String, Pair<Fence, Integer>> fenceMap = new HashMap<>();

    public DeviceRepository(Firestore firestore) {
        this.collectionReference = firestore.collection(collectionName);
    }

    public boolean save(Device device) {
        String documentId = device.getDeviceId();
        ApiFuture<WriteResult> resultApiFuture = collectionReference.document(documentId).set(device);
        Fence currentFence = get(device.getDeviceId()).getFence();
        if (!fenceMap.containsKey(device.getDeviceId())) {
            fenceMap.put(device.getDeviceId(), new ImmutablePair<>(currentFence, 0));
        } else if (!fenceMap.get(device.getDeviceId()).getKey().equals(currentFence)) {
            log.info("fence updated since last time");
            int id = fenceMap.get(documentId).getValue();
            fenceMap.put(documentId, new ImmutablePair<>(currentFence, (id + 1) %10));
        } else log.info("fence not updated since last time");
        try {
            log.info("{}--{} saved at{}", collectionName, documentId, resultApiFuture.get().getUpdateTime());
            return true;
        } catch (InterruptedException | ExecutionException e) {
            log.error("Error saving {}={} {}", collectionName, documentId, e.getMessage());
        }
        return false;
    }

    public Device get(String deviceId) {
        DocumentReference deviceReference = collectionReference.document(deviceId);
        ApiFuture<DocumentSnapshot> snapshotApiFuture = deviceReference.get();

        try {
            DocumentSnapshot documentSnapshot = snapshotApiFuture.get();
            if (documentSnapshot.exists()) {

                ArrayList<HashMap<String, Object>> receivedLocations = (ArrayList<HashMap<String, Object>>) documentSnapshot.get("locations");
                ArrayList<SpaceTimeStamp> spaceTimePointLocations = receivedLocations.stream().map(stringObjectHashMap -> {
                    return new SpaceTimeStamp((Timestamp) stringObjectHashMap.get("timestamp"), (GeoPoint) stringObjectHashMap.get("coordinate"));
                }).collect(Collectors.toCollection(ArrayList::new));
                Map<String, Object> fenceMap = (Map<String, Object>) documentSnapshot.get("fence");
                Fence fence = new Fence();
                fence.setDistance( ((Number) fenceMap.get("distance")).doubleValue());
                fence.setAnchor((GeoPoint) fenceMap.get("anchor"));
                fence.setInUse((boolean) fenceMap.get("inUse"));

                return new Device(
                        deviceId,
                        documentSnapshot.get("deviceName").toString(),
                        spaceTimePointLocations,
                        (Boolean) documentSnapshot.get("callBack"),
                        fence
                );
            }
        } catch (ExecutionException | InterruptedException e) {
            log.error("Exception occurred retrieving: {}={} {}", collectionName, deviceId, e.getMessage());
        }
        return null;
    }

    public boolean delete(String deviceId) {
        DocumentReference documentReference = collectionReference.document(deviceId);
        ApiFuture<DocumentSnapshot> resultApiFetch = documentReference.get();
        ApiFuture<WriteResult> resultApiFuture = documentReference.delete();
        try {
            if (resultApiFetch.get().exists()) {
                fenceMap.remove(deviceId);
                log.info("{}={} deleted at {}", collectionName, deviceId, resultApiFuture.get().getUpdateTime());
                return true;
            }
            log.warn("{}={} Does not exist", collectionName, deviceId);
        } catch (ExecutionException | InterruptedException e) {
            log.error("Exception occurred deleting: {}={} {}", collectionName, deviceId, e.getMessage());
        }
        return false;
    }

    public boolean create(Device device) {
        fenceMap.put(device.getDeviceId(), new MutablePair<>(device.getFence(), 0));
        ApiFuture<WriteResult> resultApiFuture = collectionReference.document(device.getDeviceId()).set(device);
        try {
            log.info("{}--{} CREATED at:", collectionName, device.getDeviceId(), resultApiFuture.get().getUpdateTime() );
            return true;
        } catch (ExecutionException | InterruptedException e) {
             log.error("Error saving device");
        }
        return false;
    }
}
