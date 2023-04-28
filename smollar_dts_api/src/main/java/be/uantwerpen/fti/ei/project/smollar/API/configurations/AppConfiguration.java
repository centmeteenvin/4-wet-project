package be.uantwerpen.fti.ei.project.smollar.API.configurations;

import be.uantwerpen.fti.ei.project.smollar.API.models.SpaceTimeStamp;
import be.uantwerpen.fti.ei.project.smollar.API.tools.GeoPointDeserializer;
import be.uantwerpen.fti.ei.project.smollar.API.tools.SpaceTimeStampDeserializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.google.cloud.firestore.GeoPoint;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfiguration {

    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper objectMapper = new ObjectMapper();
        SimpleModule module = new SimpleModule();
        module.addDeserializer(SpaceTimeStamp.class, new SpaceTimeStampDeserializer());
        module.addDeserializer(GeoPoint.class, new GeoPointDeserializer());
        objectMapper.registerModule(module);
        return objectMapper;
    }
}
