package be.uantwerpen.fti.ei.project.smollar.API;

import be.uantwerpen.fti.ei.project.smollar.API.models.SpaceTimeStamp;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.GeoPoint;
import be.uantwerpen.fti.ei.project.smollar.API.models.Device;
import be.uantwerpen.fti.ei.project.smollar.API.repositories.DeviceRepository;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

@SpringBootTest
class DeviceRepositoryTests {
	@Autowired
	private Firestore firestore;
	@Test
	void contextLoads() {
		DeviceRepository repository = new DeviceRepository(firestore);
		ArrayList<SpaceTimeStamp> locations = new ArrayList<>();

		locations.add(new SpaceTimeStamp(Timestamp.now(), new GeoPoint(54.0, 4.00)));
		Device device = new Device("Test Device", locations);
		boolean result = repository.save(device);
		Assertions.assertTrue(result);

		Device receivedDevice = repository.get(device.getDeviceId());
		Assertions.assertEquals(device, receivedDevice);

		result = repository.delete(device.getDeviceId());
		Assertions.assertTrue(result);

		result = repository.delete("foo");
		Assertions.assertFalse(result);

		device = repository.get(device.getDeviceId());
		Assertions.assertNull(device);
	}
}
