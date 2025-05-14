package com.example.demo.controller;

import com.example.demo.service.AuthenticationService;
import com.google.firebase.auth.FirebaseAuthException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;

@RestController
@RequestMapping("/api/auth")
public class AuthenticationController {

    @Autowired
    private AuthenticationService authenticationService;

    @PostMapping("/register")
    public ResponseEntity<Map<String, String>> registerUser(@RequestBody Map<String, String> credentials)
            throws InterruptedException, ExecutionException {
        try {
            String uid = authenticationService.registerUser(credentials.get("name"), credentials.get("email"),
                    credentials.get("password"));

            Map<String, String> response = new HashMap<>();
            response.put("uid", uid);
            return ResponseEntity.ok(response);
        } catch (FirebaseAuthException e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error: ", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> loginUser(@RequestBody Map<String, String> credentials) {
        try {
            String uid = authenticationService.loginUser(credentials.get("email"), credentials.get("password"));

            Map<String, String> response = new HashMap<>();
            response.put("uid", uid);
            return ResponseEntity.ok(response);
        } catch (FirebaseAuthException e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("error: ", e.getMessage());
            return ResponseEntity.badRequest().body(errorResponse);
        }
    }
}