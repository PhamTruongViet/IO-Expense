package com.example.demo.model;

import java.util.Date;

public class Wallet {
    private String id;
    private String name;
    private double balance;
    private Date date;

    public Wallet(String id, String name, double balance, Date date) {
        this.id = id;
        this.name = name;
        this.balance = balance;
        this.date = date;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }
}
