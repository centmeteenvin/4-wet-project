package be.uantwerpen.fti.ei.project.smollar.API;

import be.uantwerpen.fti.ei.project.smollar.API.models.Device;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.ArrayList;
import java.util.HashMap;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.MOCK)
@AutoConfigureMockMvc
public class RestControllerTest {
    @Autowired
    private MockMvc mvc;

    @Test
    public void RestTest() throws Exception {
        Device device = new Device("Test Device", new ArrayList<>());
        HashMap<String, HashMap<String, Double>> locationMap = new HashMap<>(1) {{
            put("2023-04-02T20:59:01+00:00", new HashMap<>(1) {{
                put("latitude", 54.00);
                put("longitude", 0.00);
            }});
        }};

        mvc.perform(post("/devices/" + device.getDeviceId()).
                        content(device.getDeviceName())).
                andExpect(status().isCreated());

        mvc.perform(
                        get("/devices/" + device.getDeviceId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.deviceId").value(device.getDeviceId()))
                .andExpect(jsonPath("$.deviceName").value(device.getDeviceName()));

        mvc.perform(patch("/devices/" + device.getDeviceId())
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\n" +
                                "    \"timeStamp\":\"2023-04-02T20:59:01+00:00\",\n" +
                                "    \"latitude\":\"54.00\",\n" +
                                "    \"longitude\":\"0.00\"\n" +
                                "}"))
                .andExpect(status().isOk()
                );

        mvc.perform(get("/devices/" + device.getDeviceId()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.locations").value(locationMap)
        );

        mvc.perform(delete("/devices/" + device.getDeviceId())).andExpect(status().is2xxSuccessful());
    }
}
