package be.uantwerpen.fti.ei.project.smollar.API;

import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.GeoPoint;
import firestore.Device;
import firestore.DeviceRepository;
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
		ArrayList<Map<String, GeoPoint>> locations = new ArrayList<>();
		locations.add(new HashMap<>());
		locations.get(0).put(LocalDateTime.now().toString(), new GeoPoint(54, 4));
		Device device = new Device("Test Device", locations);
		System.out.println(device);
		boolean result = repository.save(device);
		Assertions.assertTrue(result);
		Device receivedDevice = repository.get(device.getDeviceId());
		Assertions.assertEquals(device.toString(), receivedDevice.toString());
		result = repository.delete(device.getDeviceId());
		Assertions.assertTrue(result);
		result = repository.delete("foo");
		Assertions.assertFalse(result);
		device = repository.get(device.getDeviceId());
		Assertions.assertNull(device);
	}
}