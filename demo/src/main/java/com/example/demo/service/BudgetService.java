package com.example.demo.service;

import com.example.demo.model.Budget;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import java.util.concurrent.ExecutionException;
import org.springframework.stereotype.Service;

@Service
public class BudgetService {
    private static final String USER_COLLECTION = "users";
    private static final String BUDGET_COLLECTION = "budgets";

    public String createBudget(String userId, Budget budget)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        CollectionReference budgetsRef = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(BUDGET_COLLECTION);
        DocumentReference docRef = budgetsRef.document(budget.getId());
        ApiFuture<WriteResult> collectionsApiFuture = docRef.set(budget);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public Budget getBudget(String userId, String budgetId)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference documentReference = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(BUDGET_COLLECTION).document(budgetId);
        ApiFuture<DocumentSnapshot> future = documentReference.get();
        DocumentSnapshot document = future.get();
        if (document.exists()) {
            return document.toObject(Budget.class);
        }
        return null;
    }
}
