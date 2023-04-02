package firestore;

import com.google.api.core.ApiFuture;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.*;
import lombok.extern.slf4j.Slf4j;

import java.util.ArrayList;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@Slf4j
public class DeviceRepository {
    private final CollectionReference collectionReference;
    private final String collectionName = "Devices";

    public DeviceRepository(Firestore firestore) {
        this.collectionReference = firestore.collection(collectionName);
    }

    public boolean save(Device device) {
        String documentId = device.getDeviceId();
        ApiFuture<WriteResult> resultApiFuture = collectionReference.document(documentId).set(device);
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
                return new Device(
                        deviceId,
                        documentSnapshot.get("deviceName").toString(),
                        (ArrayList<Map<String, GeoPoint>>) documentSnapshot.get("locations")
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
                log.info("{}={} deleted at {}", collectionName, deviceId, resultApiFuture.get().getUpdateTime());
                return true;
            }
            log.warn("{}={} Does not exist", collectionName, deviceId);
        } catch (ExecutionException | InterruptedException e) {
            log.error("Exception occurred deleting: {}={} {}", collectionName, deviceId, e.getMessage());
        }
        return false;
    }
}
