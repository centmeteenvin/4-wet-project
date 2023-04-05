package be.uantwerpen.fti.ei.project.smollar.API.configurations;

import be.uantwerpen.fti.ei.project.smollar.API.models.SpaceTimeStamp;
import be.uantwerpen.fti.ei.project.smollar.API.tools.SpaceTimeStampDeserializer;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.module.SimpleModule;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class AppConfiguration {

    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper objectMapper = new ObjectMapper();
        SimpleModule module = new SimpleModule();
        module.addDeserializer(SpaceTimeStamp.class, new SpaceTimeStampDeserializer());
        objectMapper.registerModule(module);
        return objectMapper;
    }
}
