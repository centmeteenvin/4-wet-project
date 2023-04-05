package be.uantwerpen.fti.ei.project.smollar.API.configurations;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.FirestoreOptions;
import com.google.firebase.FirebaseOptions;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

@Slf4j
@Configuration
public class FireStoreConfiguration {
    /**
     * Singleton that returns the firestore instance.
     * Make sure that the service credentials are stored in src/main/resources/firebase-api-secret.json.
     * @return reference to the firestore instance.
     */
    @Bean
    public Firestore firestore() {
        FileInputStream serviceAccount;
        {
            try {
                serviceAccount = new FileInputStream("src/main/resources/firebase-api-secret.json");
                GoogleCredentials credentials = GoogleCredentials.fromStream(serviceAccount);
                FirestoreOptions options = FirestoreOptions.newBuilder().setCredentials(credentials).build();
                log.info("Firestore successfully loaded");
                return options.getService();

            } catch (IOException e) {
                log.error("The API service account file is not present");
                throw new RuntimeException();
            }
        }
    }

}
