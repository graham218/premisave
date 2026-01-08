package com.premisave.auth.controller;

import com.premisave.auth.dto.ProfileUpdateRequest;
import com.premisave.auth.service.ProfileService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/profile")
public class ProfileController {

    private final ProfileService profileService;

    public ProfileController(ProfileService profileService) {
        this.profileService = profileService;
    }

    @PutMapping("/update")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> updateProfile(@Valid @RequestBody ProfileUpdateRequest request) {
        profileService.updateProfile(request);
        return ResponseEntity.ok("Profile updated");
    }

    @PostMapping("/upload-pic")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> uploadProfilePic(@RequestParam("file") MultipartFile file) {
        String url = profileService.uploadProfilePic(file);
        return ResponseEntity.ok(url);
    }
}