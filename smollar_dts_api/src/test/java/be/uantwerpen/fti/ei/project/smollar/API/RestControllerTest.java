package be.uantwerpen.fti.ei.project.smollar.API;

import be.uantwerpen.fti.ei.project.smollar.API.models.Device;
import be.uantwerpen.fti.ei.project.smollar.API.models.SpaceTimeStamp;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.cloud.Timestamp;
import com.google.cloud.firestore.GeoPoint;
import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.ArrayList;
import java.util.HashMap;

import static org.hamcrest.Matchers.equalTo;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
public class RestControllerTest {
    @Autowired
    private MockMvc mvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    public void RestTest() throws Exception {
        Device device = new Device("Test Device", new ArrayList<>());
        Timestamp now = Timestamp.now();
        SpaceTimeStamp spaceTimeStamp = new  SpaceTimeStamp(now,new GeoPoint(54, 4));

        mvc.perform(post("/api/v1/devices/" + device.getDeviceId()).
                        content(device.getDeviceName())).
                andExpect(status().isCreated());

        mvc.perform(
                        get("/api/v1/devices/" + device.getDeviceId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.deviceId").value(device.getDeviceId()))
                .andExpect(jsonPath("$.deviceName").value(device.getDeviceName()));

        ObjectMapper mapper = new ObjectMapper();
        mvc.perform(put("/api/v1/devices/" + device.getDeviceId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("[\n" + mapper.writeValueAsString(spaceTimeStamp) + "\n]"))
                .andExpect(status().isOk()
                );

        MvcResult result = mvc.perform(get("/api/v1/devices/" + device.getDeviceId()))
                .andExpect(status().isOk())
                .andReturn();

        String responseContent = result.getResponse().getContentAsString();
        Device receivedDevice = objectMapper.readValue(responseContent, Device.class);
        System.out.println(receivedDevice);

        mvc.perform(delete("/api/v1/devices/" + device.getDeviceId())).andExpect(status().is2xxSuccessful());
    }
}
