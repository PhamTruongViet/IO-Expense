package com.example.demo.model;

import java.math.BigDecimal;
import java.util.Date;

public class Budget {
    private String id;
    private BigDecimal amount;
    private String details;
    private String category;
    private String walletId;
    private Date startDate;
    private Date endDate;
    private int isRepeat;

    public Budget(String id, BigDecimal amount, String details,
            String category,
            String wallet, Date startDate, Date endDate, int isRepeat) {
        this.id = id;
        this.amount = amount;
        this.details = details;
        this.category = category;
        this.walletId = wallet;
        this.startDate = startDate;
        this.endDate = endDate;
        this.isRepeat = isRepeat;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

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

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getWalletId() {
        return walletId;
    }

    public void setWalletId(String wallet) {
        this.walletId = wallet;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public int getIsRepeat() {
        return isRepeat;
    }

    public void setIsRepeat(int isRepeat) {
        this.isRepeat = isRepeat;
    }
}