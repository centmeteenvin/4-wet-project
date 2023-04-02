package firestore;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.FirestoreOptions;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.io.FileInputStream;
import java.io.IOException;

@Configuration
public class FirestoreConfiguration {
    @Bean
    public Firestore getFireStore() throws IOException {
        FileInputStream serviceAccount = new FileInputStream("src/main/java/firestore/smollar-dts-firebase-adminsdk-kmojf-0f791f9d72.json");
        GoogleCredentials credentials = GoogleCredentials.fromStream(serviceAccount);
        FirestoreOptions options = FirestoreOptions.newBuilder().setCredentials(credentials).build();
        return options.getService();
    }
}
