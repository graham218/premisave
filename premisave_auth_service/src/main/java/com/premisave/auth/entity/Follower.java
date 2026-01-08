package com.premisave.auth.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DocumentReference;

@Data
@Document(collection = "followers")
public class Follower {
    @Id
    private String id;

    @DocumentReference
    private User user;

    @DocumentReference
    private User follower;
}