package com.example.demo.service;

import com.example.demo.model.Wallet;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;
import org.springframework.stereotype.Service;

import java.util.concurrent.ExecutionException;

@Service
public class WalletService {
    private static final String WALLET_COLLECTION = "wallets";
    private static final String USER_COLLECTION = "users";

    public String createWallet(String userId, Wallet wallet) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        CollectionReference transactionsRef = dbFirestore.collection(USER_COLLECTION).document(userId)
                .collection(WALLET_COLLECTION);
        DocumentReference docRef = transactionsRef.document(wallet.getId());
        ApiFuture<WriteResult> collectionsApiFuture = docRef.set(wallet);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public Wallet getWallet(String walletId) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        DocumentReference documentReference = dbFirestore.collection(WALLET_COLLECTION).document(walletId);
        ApiFuture<DocumentSnapshot> future = documentReference.get();
        DocumentSnapshot document = future.get();
        if (document.exists()) {
            return document.toObject(Wallet.class);
        }
        return null;
    }

    public String updateWallet(Wallet wallet) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> collectionsApiFuture = dbFirestore.collection(WALLET_COLLECTION).document(wallet.getId())
                .set(wallet);
        return collectionsApiFuture.get().getUpdateTime().toString();
    }

    public String deleteWallet(String walletId) throws ExecutionException, InterruptedException {
        Firestore dbFirestore = FirestoreClient.getFirestore();
        ApiFuture<WriteResult> writeResult = dbFirestore.collection(WALLET_COLLECTION).document(walletId).delete();
        return "Document with ID " + walletId + " has been deleted";
    }
}