package com.example.demo.service;

import com.example.demo.model.User;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

@Service
public class UserService {

    private static final String COLLECTION_NAME = "users";

    public String createUser(User user) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference docRef = dbFirestore.collection(COLLECTION_NAME).document(user.getId());
        ApiFuture<WriteResult> collectionsApiFuture = docRef.set(user);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public User getUser(String id) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference documentReference = dbFirestore.collection(COLLECTION_NAME).document(id);
        ApiFuture<DocumentSnapshot> future = documentReference.get();
        DocumentSnapshot document = future.get();
        if (document.exists()) {
            return document.toObject(User.class);
        }
        return null;
    }

    public List<User> getAllUsers() throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = dbFirestore.collection(COLLECTION_NAME).get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<User> users = new ArrayList<>();
        for (QueryDocumentSnapshot document : documents) {
            users.add(document.toObject(User.class));
        }
        return users;
    }

    public String updateUser(User user) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> collectionsApiFuture = dbFirestore.collection(COLLECTION_NAME).document(user.getId())
                .set(user);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public String deleteUser(String id) {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> writeResult = dbFirestore.collection(COLLECTION_NAME).document(id).delete();
        return "Đã xóa người dùng có ID " + id;
    }
}