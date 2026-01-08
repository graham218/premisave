package com.premisave.auth.entity;

import com.premisave.auth.enums.Language;
import com.premisave.auth.enums.Role;
import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

@SuppressWarnings("serial")
@Data
@Document(collection = "users")
public class User implements UserDetails {
    @Id
    private String id;

    private String username;

    private String firstName;

    private String middleName;

    private String lastName;

    private String email;

    private String phoneNumber;

    private String address1;

    private String address2;

    private String country;

    private Language language = Language.ENGLISH;

    private String profilePictureUrl;

    private String password;

    private Role role;

    private boolean active = true;

    private boolean verified = false;

    private boolean archived = false;

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + role.name()));
    }

    @Override
    public String getUsername() {
        return email;
    }

    @Override
    public boolean isAccountNonExpired() {
        return true;
    }

    @Override
    public boolean isAccountNonLocked() {
        return true;
    }

    @Override
    public boolean isCredentialsNonExpired() {
        return true;
    }

    @Override
    public boolean isEnabled() {
        return active && verified;
    }
}