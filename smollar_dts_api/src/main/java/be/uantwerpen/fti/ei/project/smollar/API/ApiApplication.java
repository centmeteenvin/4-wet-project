package be.uantwerpen.fti.ei.project.smollar.API;

import be.uantwerpen.fti.ei.project.smollar.API.controllers.DeviceController;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
public class ApiApplication {

	public static void main(String[] args) {
		ApplicationContext context = SpringApplication.run(ApiApplication.class, args);
	}

}
