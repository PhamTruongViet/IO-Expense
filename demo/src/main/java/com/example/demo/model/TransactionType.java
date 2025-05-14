package com.example.demo.model;

import java.util.Map;
import java.util.List;
import java.util.ArrayList;

public class TransactionType {
    private String id;
    private String name; // expense, income, debt/loan
    private Map<String, List<String>> categories; // category -> subcategories

    // Constructors
    public TransactionType() {
    }

    public TransactionType(String id, String name, Map<String, List<String>> categories) {
        this.id = id;
        this.name = name;
        this.categories = categories;
    }

    // Getters and setters
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

    public Map<String, List<String>> getCategories() {
        return categories;
    }

    public void setCategories(Map<String, List<String>> categories) {
        this.categories = categories;
    }

    // Phương thức để thêm danh mục mới
    public void addCategory(String category) {
        if (!categories.containsKey(category)) {
            categories.put(category, new ArrayList<>());
        }
    }

    // Phương thức để thêm danh mục con mới
    public void addSubcategory(String category, String subcategory) {
        if (!categories.containsKey(category)) {
            addCategory(category);
        }
        if (!categories.get(category).contains(subcategory)) {
            categories.get(category).add(subcategory);
        }
    }
}