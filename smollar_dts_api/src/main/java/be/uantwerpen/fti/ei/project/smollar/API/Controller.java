package be.uantwerpen.fti.ei.project.smollar.API;

import com.google.cloud.firestore.Firestore;
import firestore.User;
import firestore.UserRepository;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class Controller {
    private UserRepository repository;
    public Controller(Firestore getFireStore) {
        System.out.println(getFireStore);
        this.repository = new UserRepository(getFireStore);
        User testUser = new User();
        repository.save(testUser);
    }

    @GetMapping("/")
    ResponseEntity hello(){
        return new ResponseEntity<String>("Hello World", HttpStatusCode.valueOf(200));
    }

    @GetMapping("/test")
    ResponseEntity test() {
        return  new ResponseEntity<String>(repository.retrieveAll().toString(), HttpStatusCode.valueOf(200));
    }
}
