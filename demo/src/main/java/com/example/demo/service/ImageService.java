package com.example.demo.service;


import com.google.cloud.storage.Storage;
import com.google.cloud.storage.StorageException;
import com.google.firebase.cloud.StorageClient;
import com.google.cloud.storage.StorageOptions;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import java.util.concurrent.ExecutionException;

@Service
public class ImageService {

    private final Storage storage = StorageOptions.getDefaultInstance().getService();

    public String uploadFile(String userId, String transactionId, MultipartFile photo)
            throws IOException, ExecutionException, InterruptedException {
        if (photo == null || photo.isEmpty()) {
            return "No file to upload";
        }

        String fileName = photo.getOriginalFilename();

        try {
            StorageClient.getInstance()
                    .bucket()
                    .create(fileName, photo.getInputStream(), photo.getContentType());
            return "File uploaded successfully";
        } catch (IOException e) {
            e.printStackTrace();
            return "Error occurred during file upload";
        }
    }


    // public String deleteFile(String userId, String transactionId, String
    // fileName)
    // throws ExecutionException, InterruptedException {
    // String destination = String.format("%s/%s/%s", userId, transactionId,
    // fileName);
    // BlobId blobId = BlobId.of("expense-management-74276.appspot.com",
    // destination);
    // boolean deleted = storage.delete(blobId);
    // if (deleted) {
    // return "File deleted successfully";
    // } else {
    // return "Error occurred during file deletion";
    // }
    // }
}