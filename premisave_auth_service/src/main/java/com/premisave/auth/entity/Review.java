package com.premisave.auth.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DocumentReference;

@Data
@Document(collection = "reviews")
public class Review {
    @Id
    private String id;

    @DocumentReference
    private User user;

    private String targetId; // e.g., property id

    private int rating;

    private String comment;
}