package com.example.demo.controller;

import com.example.demo.model.User;
import com.example.demo.model.TransactionType;
import com.example.demo.model.Transaction;
import com.example.demo.model.Wallet;
import com.example.demo.model.Budget;
import com.example.demo.service.UserService;
import com.example.demo.service.TransactionTypeService;
import com.example.demo.service.TransactionService;
import com.example.demo.service.WalletService;
import com.example.demo.service.BudgetService;
import com.example.demo.service.ImageService;
import com.example.demo.service.AuthenticationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.io.File;
import java.io.IOException;
import java.util.concurrent.ExecutionException;

import org.springframework.http.HttpStatus;

@RestController
@RequestMapping("/api")
public class UserController {

    @Autowired
    private UserService userService;

    @Autowired
    private WalletService walletService;

    @Autowired
    private ImageService imageService;

    @Autowired
    private TransactionTypeService transactionTypeService;

    @Autowired
    private TransactionService transactionService;

    @Autowired
    private BudgetService budgetService;

    @PostMapping("/users")
    public String createUser(@RequestBody User user)
            throws ExecutionException, InterruptedException {
        return userService.createUser(user);
    }

    @GetMapping("/users/{userId}")
    public User getUser(@PathVariable("userId") String userId)
            throws ExecutionException, InterruptedException {
        return userService.getUser(userId);
    }

    @GetMapping("/users")
    public List<User> getAllUsers()
            throws ExecutionException, InterruptedException {
        return userService.getAllUsers();
    }

    @PostMapping("/users/{userId}/wallets")
    public String createWallet(@PathVariable("userId") String userId, @RequestBody Wallet wallet)
            throws ExecutionException, InterruptedException {
        return walletService.createWallet(userId, wallet);
    }

    @PostMapping("/users/{userId}/transactiontypes")
    public String createTransactionType(@PathVariable("userId") String userId,
            @RequestBody TransactionType transactionType)
            throws ExecutionException, InterruptedException {
        return transactionTypeService.createTransactionType(userId, transactionType);
    }

    @PostMapping("/users/{userId}/transactions/{transactionId}/photo")
    public String uploadPhoto(@PathVariable("userId") String userId,
            @PathVariable("transactionId") String transactionId, @RequestParam("photo") MultipartFile photo)
            throws ExecutionException, InterruptedException, IOException {
        System.out.println("Uploading photo");
        return imageService.uploadFile(userId, transactionId, photo);
    }

    // @DeleteMapping("/users/{userId}/transactions/{transactionId}/photo")
    // public String deletePhoto(@PathVariable("userId") String userId,
    // @PathVariable("transactionId") String transactionId, @RequestBody String
    // fileName)
    // throws ExecutionException, InterruptedException {
    // return imageService.deleteFile(userId, transactionId, fileName);
    // }

    @PostMapping("/users/{userId}/transactions")
    public String createTransaction(@PathVariable("userId") String userId, @RequestBody Transaction transaction)
            throws ExecutionException, InterruptedException {
        return transactionService.createTransaction(userId, transaction);
    }

    @GetMapping("/users/{userId}/transactions/{transactionId}")
    public Transaction getTransaction(@PathVariable("userId") String userId,
            @PathVariable("transactionId") String transactionId)
            throws ExecutionException, InterruptedException {
        return transactionService.getTransaction(userId, transactionId);
    }

    @GetMapping("/users/{userId}/transactions")
    public List<Transaction> getAllTransactions(@PathVariable("userId") String userId)
            throws ExecutionException, InterruptedException {
        return transactionService.getAllTransactions(userId);
    }

    @PutMapping("/users/{userId}/transactions/{transactionId}")
    public String updateTransaction(@PathVariable("userId") String userId,
            @PathVariable("transactionId") String transactionId,
            @RequestBody Transaction transaction)
            throws ExecutionException, InterruptedException {
        transaction.setId(transactionId);
        return transactionService.updateTransaction(userId, transaction);
    }

    @DeleteMapping("/users/{userId}/transactions/{transactionId}")
    public String deleteTransaction(@PathVariable("userId") String userId,
            @PathVariable("transactionId") String transactionId) {
        return transactionService.deleteTransaction(userId, transactionId);
    }

    @PostMapping("/users/{userId}/budgets")
    public String createBudget(@PathVariable("userId") String userId, @RequestBody Budget budget)
            throws ExecutionException, InterruptedException {
        return budgetService.createBudget(userId, budget);
    }

    @GetMapping("/users/{userId}/transactiontypes/{transactionTypeId}")
    public TransactionType getTransactionType(@PathVariable("userId") String userId,
            @PathVariable("transactionTypeId") String transactionTypeId)
            throws ExecutionException, InterruptedException {
        return transactionTypeService.getTransactionType(userId, transactionTypeId);
    }

    @GetMapping("/users/{userId}/transactiontypes")
    public List<TransactionType> getAllTransactionTypes(@PathVariable("userId") String userId)
            throws ExecutionException, InterruptedException {
        try {
            return transactionTypeService.getAllTransactionTypes(userId);
        } catch (Exception e) {
            throw new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Lỗi khi lấy loại giao dịch", e);
        }
    }

    @PutMapping("/users/{userId}/transactiontypes/{transactionTypeId}")
    public String updateTransactionType(@PathVariable("userId") String userId,
            @PathVariable("transactionTypeId") String transactionTypeId,
            @RequestBody TransactionType transactionType)
            throws ExecutionException, InterruptedException {
        transactionType.setId(transactionTypeId);
        return transactionTypeService.updateTransactionType(userId, transactionType);
    }

    @DeleteMapping("/users/{userId}/transactiontypes/{transactionTypeId}")
    public String deleteTransactionType(@PathVariable("userId") String userId,
            @PathVariable("transactionTypeId") String transactionTypeId)
            throws ExecutionException, InterruptedException {
        return transactionTypeService.deleteTransactionType(userId, transactionTypeId);
    }

    @PostMapping("/users/{userId}/transactiontypes/{transactionTypeId}/categories")
    public String addCategory(@PathVariable("userId") String userId,
            @PathVariable("transactionTypeId") String transactionTypeId,
            @RequestBody List<String> categories)
            throws ExecutionException, InterruptedException {
        return transactionTypeService.addCategory(userId, transactionTypeId, categories);
    }

    @PostMapping("/users/{userId}/transactiontypes/{transactionTypeId}/categories/{category}/subcategories")
    public String addSubcategory(@PathVariable("userId") String userId,
            @PathVariable("transactionTypeId") String transactionTypeId,
            @PathVariable("category") String category, @RequestBody String subcategory)
            throws ExecutionException, InterruptedException {
        return transactionTypeService.addSubcategory(userId, transactionTypeId, category, subcategory);
    }

}