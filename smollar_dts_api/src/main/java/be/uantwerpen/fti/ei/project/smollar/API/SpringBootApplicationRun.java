package be.uantwerpen.fti.ei.project.smollar.API;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan(basePackages = {"firestore"}, basePackageClasses = Controller.class)
public class SpringBootApplicationRun {

	public static void main(String[] args) {
		SpringApplication.run(SpringBootApplicationRun.class, args);
	}

}
