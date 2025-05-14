package com.example.demo.service;

import com.example.demo.model.Transaction;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.HashMap;
import java.util.Map;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;

@Service
public class TransactionService {

    private static final String USER_COLLECTION = "users";
    private static final String TRANSACTION_COLLECTION = "transactions";

    public String createTransaction(String userId, Transaction transaction)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        CollectionReference transactionsRef = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_COLLECTION);
        DocumentReference docRef = transactionsRef.document(transaction.getId());
        ApiFuture<WriteResult> collectionsApiFuture = docRef.set(transaction);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public Transaction getTransaction(String userId, String transactionId)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference documentReference = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_COLLECTION).document(transactionId);
        ApiFuture<DocumentSnapshot> future = documentReference.get();
        DocumentSnapshot document = future.get();
        if (document.exists()) {
            return document.toObject(Transaction.class);
        }
        return null;
    }

    public List<Transaction> getAllTransactions(String userId) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_COLLECTION).get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();
        List<Transaction> transactions = new ArrayList<>();
        for (QueryDocumentSnapshot document : documents) {
            transactions.add(document.toObject(Transaction.class));
        }
        return transactions;
    }

    public String updateTransaction(String userId, Transaction transaction)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> collectionsApiFuture = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_COLLECTION).document(transaction.getId()).set(transaction);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public String deleteTransaction(String userId, String transactionId) {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> writeResult = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_COLLECTION).document(transactionId).delete();
        return "Đã xóa Transaction có ID " + transactionId;
    }

    public Map<String, BigDecimal> getCategoryStatistics(String userId, LocalDate startDate, LocalDate endDate)
            throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<QuerySnapshot> future = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(TRANSACTION_COLLECTION)
                .whereGreaterThanOrEqualTo("date", startDate.atStartOfDay(ZoneId.systemDefault()).toInstant())
                .whereLessThanOrEqualTo("date", endDate.plusDays(1).atStartOfDay(ZoneId.systemDefault()).toInstant())
                .get();
        List<QueryDocumentSnapshot> documents = future.get().getDocuments();

        Map<String, BigDecimal> categoryStatistics = new HashMap<>();

        for (QueryDocumentSnapshot document : documents) {
            Transaction transaction = document.toObject(Transaction.class);
            String category = transaction.getCategory();
            BigDecimal amount = transaction.getAmount();

            categoryStatistics.merge(category, amount, BigDecimal::add);
        }

        return categoryStatistics;
    }

}