package com.premisave.auth.dto;

import lombok.Data;

@Data
public class AuthResponse {
    private String token;
    private String role;
    private String redirectUrl; // e.g., /dashboard/client based on role
}