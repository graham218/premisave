package com.premisave.auth.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.premisave.auth.dto.ProfileUpdateRequest;
import com.premisave.auth.dto.UserDto;
import com.premisave.auth.entity.User;
import com.premisave.auth.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
@Slf4j
public class ProfileService {

    private final UserRepository userRepository;
    private final Cloudinary cloudinary;
    private final PasswordEncoder passwordEncoder;

    public ProfileService(UserRepository userRepository, Cloudinary cloudinary, PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.cloudinary = cloudinary;
        this.passwordEncoder = passwordEncoder;
    }

    public UserDto getCurrentUserProfile() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String principalName = authentication.getName();
        log.debug("Getting profile for principal: {}", principalName);
        
        // First try to find by email (since authentication likely uses email)
        User user = userRepository.findByEmail(principalName)
            .or(() -> {
                // If not found by email, try by username
                log.debug("User not found by email {}, trying username", principalName);
                return userRepository.findByUsername(principalName);
            })
            .orElseThrow(() -> new RuntimeException("User not found for principal: " + principalName));
            
        log.debug("Found user with username: {}, email: {}", user.getUsername(), user.getEmail());
        return convertToDto(user);
    }

    public void updateProfile(ProfileUpdateRequest request) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String principalName = authentication.getName();
        
        User user = userRepository.findByEmail(principalName)
            .or(() -> userRepository.findByUsername(principalName))
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Only update username if it's being changed AND it's not already taken by another user
        if (request.getUsername() != null && !request.getUsername().equals(user.getUsername())) {
            // Check if new username is available
            if (userRepository.existsByUsername(request.getUsername())) {
                throw new RuntimeException("Username already taken");
            }
            user.setUsername(request.getUsername());
        }
        
        if (request.getFirstName() != null) user.setFirstName(request.getFirstName());
        if (request.getMiddleName() != null) user.setMiddleName(request.getMiddleName());
        if (request.getLastName() != null) user.setLastName(request.getLastName());
        if (request.getPhoneNumber() != null) user.setPhoneNumber(request.getPhoneNumber());
        if (request.getAddress1() != null) user.setAddress1(request.getAddress1());
        if (request.getAddress2() != null) user.setAddress2(request.getAddress2());
        if (request.getCountry() != null) user.setCountry(request.getCountry());
        if (request.getLanguage() != null) {
            try {
                user.setLanguage(com.premisave.auth.enums.Language.valueOf(request.getLanguage().toUpperCase()));
            } catch (IllegalArgumentException e) {
                throw new RuntimeException("Invalid language value: " + request.getLanguage());
            }
        }
        userRepository.save(user);
        
        log.info("Profile updated for user: {}", user.getEmail());
    }

    @SuppressWarnings("rawtypes")
    public String uploadProfilePic(MultipartFile file) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String principalName = authentication.getName();
        
        User user = userRepository.findByEmail(principalName)
            .or(() -> userRepository.findByUsername(principalName))
            .orElseThrow(() -> new RuntimeException("User not found"));
            
        try {
            // Validate file type
            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                throw new RuntimeException("Only image files are allowed");
            }
            
            // Validate file size (e.g., 5MB max)
            long maxSize = 5 * 1024 * 1024; // 5MB
            if (file.getSize() > maxSize) {
                throw new RuntimeException("File size must be less than 5MB");
            }
            
            Map uploadResult = cloudinary.uploader().upload(file.getBytes(), 
                ObjectUtils.asMap("resource_type", "image"));
            String url = (String) uploadResult.get("secure_url");
            user.setProfilePictureUrl(url);
            userRepository.save(user);
            
            log.info("Profile picture uploaded for user: {}", user.getEmail());
            return url;
        } catch (IOException e) {
            log.error("Failed to upload profile picture for user: {}", user.getEmail(), e);
            throw new RuntimeException("Upload failed: " + e.getMessage());
        }
    }

    /**
     * Update user password
     */
    public void updatePassword(String currentPassword, String newPassword, String confirmPassword) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String principalName = authentication.getName();
        
        User user = userRepository.findByEmail(principalName)
            .or(() -> userRepository.findByUsername(principalName))
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        // Validate current password
        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            log.warn("Incorrect current password attempt for user: {}", user.getEmail());
            throw new RuntimeException("Current password is incorrect");
        }
        
        // Validate new password and confirmation match
        if (!newPassword.equals(confirmPassword)) {
            throw new RuntimeException("New password and confirmation do not match");
        }
        
        // Validate new password is different from current password
        if (passwordEncoder.matches(newPassword, user.getPassword())) {
            throw new RuntimeException("New password must be different from current password");
        }
        
        // Validate password strength
        validatePasswordStrength(newPassword);
        
        // Encode and set new password
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        
        log.info("Password updated successfully for user: {}", user.getEmail());
    }

    /**
     * Password strength validation
     */
    private void validatePasswordStrength(String password) {
        if (password.length() < 8) {
            throw new RuntimeException("Password must be at least 8 characters long");
        }
        
        if (!password.matches(".*[A-Z].*")) {
            throw new RuntimeException("Password must contain at least one uppercase letter");
        }
        
        if (!password.matches(".*[a-z].*")) {
            throw new RuntimeException("Password must contain at least one lowercase letter");
        }
        
        if (!password.matches(".*\\d.*")) {
            throw new RuntimeException("Password must contain at least one digit");
        }
        
        if (!password.matches(".*[@#$%^&+=!].*")) {
            throw new RuntimeException("Password must contain at least one special character (@#$%^&+=!)");
        }
    }

    private UserDto convertToDto(User user) {
        UserDto dto = new UserDto();
        dto.setId(user.getId().toString());
        dto.setUsername(user.getUsername());
        dto.setFirstName(user.getFirstName());
        dto.setMiddleName(user.getMiddleName());
        dto.setLastName(user.getLastName());
        dto.setEmail(user.getEmail());
        dto.setPhoneNumber(user.getPhoneNumber());
        dto.setAddress1(user.getAddress1());
        dto.setAddress2(user.getAddress2());
        dto.setCountry(user.getCountry());
        dto.setLanguage(user.getLanguage());
        dto.setProfilePictureUrl(user.getProfilePictureUrl());
        dto.setRole(user.getRole());
        dto.setActive(user.isActive());
        dto.setVerified(user.isVerified());
        dto.setArchived(user.isArchived());
        // Password should never be returned in DTO
        
        log.debug("Converted user to DTO - username: {}, email: {}", dto.getUsername(), dto.getEmail());
        return dto;
    }
}