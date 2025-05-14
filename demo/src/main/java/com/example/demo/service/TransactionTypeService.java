/**
 * Service for managing transaction types.
 * Provides methods to create, read, update, and delete transaction types,
 * as well as add categories and subcategories to transaction types.
 */
package com.example.demo.service;

import com.example.demo.model.TransactionType;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.HashMap;

@Service
public class TransactionTypeService {

    private static final String USER_COLLECTION = "users";
    private static final String TRANSACTION_TYPE_COLLECTION = "transactiontypes";
    private static final Logger logger = LoggerFactory.getLogger(TransactionTypeService.class);

    public String createTransactionType(String userId, TransactionType transactionType)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        CollectionReference transactionTypesRef = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION);
        DocumentReference docRef = transactionTypesRef.document();
        transactionType.setId(docRef.getId());
        ApiFuture<WriteResult> collectionsApiFuture = docRef.set(transactionType);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public TransactionType getTransactionType(String userId, String transactionTypeId)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference documentReference = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION).document(transactionTypeId);
        ApiFuture<DocumentSnapshot> future = documentReference.get();
        DocumentSnapshot document = future.get();
        if (document.exists()) {
            return document.toObject(TransactionType.class);
        }
        return null;
    }

    public List<TransactionType> getAllTransactionTypes(String userId) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = dbFirestore.collection(USER_COLLECTION)
                .document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION)
                .get();

        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<TransactionType> transactionTypes = new ArrayList<>();

        if (documents != null && !documents.isEmpty()) {
            for (QueryDocumentSnapshot document : documents) {
                TransactionType transactionType = document.toObject(TransactionType.class);
                transactionTypes.add(transactionType);
                System.out.println("Retrieved transaction type: " + transactionType.getName()); // Add debug log
            }
        } else {
            System.out.println("No transaction types found for user: " + userId);
        }

        return transactionTypes;
    }

    public String updateTransactionType(String userId, TransactionType transactionType)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> collectionsApiFuture = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION).document(transactionType.getId()).set(transactionType);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public String deleteTransactionType(String userId, String id) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> writeResult = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION).document(id).delete();
        writeResult.get(); // Ensure the delete operation is completed
        return "Deleted TransactionType with ID " + id;
    }

    public TransactionType getTransactionTypeById(String userId, String transactionTypeId)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference documentReference = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION).document(transactionTypeId);
        ApiFuture<DocumentSnapshot> future = documentReference.get();
        DocumentSnapshot document = future.get();
        return document.toObject(TransactionType.class);
    }

    public String addCategory(String userId, String transactionTypeId, List<String> category)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference docRef = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION).document(transactionTypeId);

        try {
            ApiFuture<DocumentSnapshot> future = docRef.get();
            DocumentSnapshot document = future.get();

            if (document.exists()) {
                TransactionType transactionType = document.toObject(TransactionType.class);
                Map<String, List<String>> categories = transactionType.getCategories();
                if (categories == null) {
                    categories = new HashMap<>();
                }
                for (String cat : category) {
                    categories.put(cat, new ArrayList<>());
                }
                transactionType.setCategories(categories);

                ApiFuture<WriteResult> updateFuture = docRef.set(transactionType);
                return updateFuture.get().getUpdateTime().toString();
            } else {
                return "TransactionType does not exist";
            }
        } catch (Exception e) {
            logger.error("Error adding category to TransactionType with ID " + transactionTypeId, e);
            throw new RuntimeException("Error adding category to TransactionType", e);
        }
    }

    public String addSubcategory(String userId, String transactionTypeId, String category, String subcategory)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference docRef = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_TYPE_COLLECTION).document(transactionTypeId);

        try {
            ApiFuture<DocumentSnapshot> future = docRef.get();
            DocumentSnapshot document = future.get();

            if (document.exists()) {
                TransactionType transactionType = document.toObject(TransactionType.class);
                Map<String, List<String>> categories = transactionType.getCategories();
                if (categories == null) {
                    categories = new HashMap<>();
                }
                if (!categories.containsKey(category)) {
                    categories.put(category, new ArrayList<>());
                }
                if (!categories.get(category).contains(subcategory)) {
                    categories.get(category).add(subcategory);
                }
                transactionType.setCategories(categories);

                ApiFuture<WriteResult> updateFuture = docRef.set(transactionType);
                return updateFuture.get().getUpdateTime().toString();
            } else {
                return "TransactionType does not exist";
            }
        } catch (Exception e) {
            logger.error("Error adding subcategory to TransactionType with ID " + transactionTypeId, e);
            throw new RuntimeException("Error adding subcategory to TransactionType", e);
        }
    }
}