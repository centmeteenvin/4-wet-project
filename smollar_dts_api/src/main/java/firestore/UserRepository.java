package firestore;

import com.google.cloud.firestore.Firestore;
import org.springframework.stereotype.Repository;

@Repository
public class UserRepository extends AbstractFirestoreRepository<User>{
     public UserRepository(Firestore firestore) {
        super(firestore, "User");
    }
}
