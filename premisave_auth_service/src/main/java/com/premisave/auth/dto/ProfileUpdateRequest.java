package com.premisave.auth.dto;

import lombok.Data;

@Data
public class ProfileUpdateRequest {
    private String username;
    private String firstName;
    private String middleName;
    private String lastName;
    private String phoneNumber;
    private String address1;
    private String address2;
    private String country;
    private String language;
}