package com.example.demo.util;

import java.util.*;

public class DefaultTransactionTypes {
    public static Map<String, Map<String, List<String>>> getDefaultTypes() {
        Map<String, Map<String, List<String>>> defaultTypes = new HashMap<>();

        // Expense
        Map<String, List<String>> expenseCategories = new HashMap<>();
        expenseCategories.put("Shopping", Arrays.asList("Online", "Supermarket"));
        expenseCategories.put("Food", Arrays.asList("Dining out"));
        expenseCategories.put("Transport", Arrays.asList("Fuel"));
        expenseCategories.put("Rental", Arrays.asList("House", "Parking lot"));
        expenseCategories.put("Bills", Arrays.asList("Internet", "Electricity", "Water", "Phone", "Other utilities"));
        expenseCategories.put("Entertainment", Arrays.asList("Games"));
        expenseCategories.put("Healthcare", Arrays.asList("Functional food", "Dietary supplement"));
        expenseCategories.put("Investment", new ArrayList<>());
        expenseCategories.put("Education", new ArrayList<>());
        expenseCategories.put("Other expenses", new ArrayList<>());
        defaultTypes.put("Expense", expenseCategories);

        // Income
        Map<String, List<String>> incomeCategories = new HashMap<>();
        incomeCategories.put("Salary", new ArrayList<>());
        incomeCategories.put("Interest", new ArrayList<>());
        incomeCategories.put("Incoming transfer", new ArrayList<>());
        incomeCategories.put("Other income", new ArrayList<>());
        defaultTypes.put("Income", incomeCategories);

        // Debt/Loan
        Map<String, List<String>> debtLoanCategories = new HashMap<>();
        debtLoanCategories.put("Loan", new ArrayList<>());
        debtLoanCategories.put("Debt", new ArrayList<>());
        debtLoanCategories.put("Repayment", new ArrayList<>());
        defaultTypes.put("Debt/Loan", debtLoanCategories);

        return defaultTypes;
    }
}