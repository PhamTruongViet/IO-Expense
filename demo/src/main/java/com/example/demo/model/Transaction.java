package com.example.demo.model;

import java.math.BigDecimal;
import java.util.Date;

public class Transaction {
    private String id;
    // private String userId;
    private BigDecimal amount;
    private String details;
    private String transactionType;
    private String category;
    private String subcategory;
    private String walletId;
    private String filePath;
    private Date date;

    public Transaction(String id, BigDecimal amount, String details, String transactionType,
            String category,
            String subcategory, String walletId, String filePath, Date date) {
        this.id = id;
        this.amount = amount;
        this.details = details;
        this.transactionType = transactionType;
        this.category = category;
        this.subcategory = subcategory;
        this.walletId = walletId;
        this.filePath = filePath;
        this.date = date;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    // public String getUserId() {
    // return userId;
    // }

    // public void setUserId(String userId) {
    // this.userId = userId;
    // }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getSubcategory() {
        return subcategory;
    }

    public void setSubcategory(String subcategory) {
        this.subcategory = subcategory;
    }

    public void setWalletId(String walletId) {
        this.walletId = walletId;
    }

    public String getWalletId() {
        return walletId;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}