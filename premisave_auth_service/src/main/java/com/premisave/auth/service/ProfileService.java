package com.premisave.auth.service;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.premisave.auth.dto.ProfileUpdateRequest;
import com.premisave.auth.entity.User;
import com.premisave.auth.repository.UserRepository;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.Map;

@Service
public class ProfileService {

    private final UserRepository userRepository;
    private final Cloudinary cloudinary;

    public ProfileService(UserRepository userRepository, Cloudinary cloudinary) {
        this.userRepository = userRepository;
        this.cloudinary = cloudinary;
    }

    public void updateProfile(ProfileUpdateRequest request) {
        User user = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (request.getUsername() != null) user.setUsername(request.getUsername());
        if (request.getFirstName() != null) user.setFirstName(request.getFirstName());
        if (request.getMiddleName() != null) user.setMiddleName(request.getMiddleName());
        if (request.getLastName() != null) user.setLastName(request.getLastName());
        if (request.getPhoneNumber() != null) user.setPhoneNumber(request.getPhoneNumber());
        if (request.getAddress1() != null) user.setAddress1(request.getAddress1());
        if (request.getAddress2() != null) user.setAddress2(request.getAddress2());
        if (request.getCountry() != null) user.setCountry(request.getCountry());
        if (request.getLanguage() != null) user.setLanguage(com.premisave.auth.enums.Language.valueOf(request.getLanguage().toUpperCase()));
        userRepository.save(user);
    }

    @SuppressWarnings("rawtypes")
	public String uploadProfilePic(MultipartFile file) {
        User user = (User) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        try {
            Map uploadResult = cloudinary.uploader().upload(file.getBytes(), ObjectUtils.asMap("resource_type", "image"));
            String url = (String) uploadResult.get("secure_url");
            user.setProfilePictureUrl(url);
            userRepository.save(user);
            return url;
        } catch (IOException e) {
            throw new RuntimeException("Upload failed");
        }
    }
}