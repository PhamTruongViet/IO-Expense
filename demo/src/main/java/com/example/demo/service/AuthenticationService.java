package com.example.demo.service;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.UserRecord;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.model.TransactionType;
import com.example.demo.model.User;
import com.example.demo.util.DefaultTransactionTypes;
import java.util.concurrent.ExecutionException;
import java.util.Map;
import java.util.List;

@Service
public class AuthenticationService {

    @Autowired
    private UserService userService;

    @Autowired
    private TransactionTypeService transactionTypeService;

    public String registerUser(String name, String email, String password)
            throws FirebaseAuthException, InterruptedException, ExecutionException {
        UserRecord.CreateRequest request = new UserRecord.CreateRequest()
                .setEmail(email)
                .setPassword(password);
        UserRecord userRecord = FirebaseAuth.getInstance().createUser(request);

        String userId = userRecord.getUid();

        // Tạo đối tượng User và lưu vào Firestore
        User newUser = new User();
        newUser.setName(name);
        newUser.setEmail(email);
        newUser.setPassword(password);
        newUser.setId(userId);
        userService.createUser(newUser);

        // Tạo các loại giao dịch mặc định
        createDefaultTransactionTypes(userId);

        return userId;
    }

    public String loginUser(String email, String password) throws FirebaseAuthException {
        UserRecord userRecord = FirebaseAuth.getInstance().getUserByEmail(email);
        return userRecord.getUid();
    }

    private void createDefaultTransactionTypes(String userId) throws ExecutionException, InterruptedException {
        Map<String, Map<String, List<String>>> defaultTypes = DefaultTransactionTypes.getDefaultTypes();

        for (Map.Entry<String, Map<String, List<String>>> entry : defaultTypes.entrySet()) {
            TransactionType transactionType = new TransactionType();
            transactionType.setName(entry.getKey());
            transactionType.setCategories(entry.getValue());
            transactionTypeService.createTransactionType(userId, transactionType);
        }
    }
}