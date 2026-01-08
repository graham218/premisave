package com.premisave.auth.entity;

import com.premisave.auth.enums.TokenType;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.DocumentReference;

import java.time.LocalDateTime;

@Data
@Document(collection = "tokens")
public class Token {
    @Id
    private String id;

    private String token;

    private TokenType type;

    private LocalDateTime expiryDate;

    private boolean used;

    @DocumentReference
    private User user;
}