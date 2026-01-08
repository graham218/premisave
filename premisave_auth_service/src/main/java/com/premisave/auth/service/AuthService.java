package com.premisave.auth.service;

import com.premisave.auth.dto.*;
import com.premisave.auth.entity.Token;
import com.premisave.auth.entity.User;
import com.premisave.auth.enums.Language;
import com.premisave.auth.enums.Role;
import com.premisave.auth.enums.TokenType;
import com.premisave.auth.repository.TokenRepository;
import com.premisave.auth.repository.UserRepository;
import com.premisave.auth.security.JwtService;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final TokenRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final EmailService emailService;
    private final RedisTemplate<String, Object> redisTemplate;

    public AuthService(UserRepository userRepository,
                       TokenRepository tokenRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       AuthenticationManager authenticationManager,
                       EmailService emailService,
                       RedisTemplate<String, Object> redisTemplate) {
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.emailService = emailService;
        this.redisTemplate = redisTemplate;
    }

    public AuthResponse signup(SignupRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email already exists");
        }

        User user = new User();
        user.setUsername(request.getUsername());
        user.setFirstName(request.getFirstName());
        user.setMiddleName(request.getMiddleName());
        user.setLastName(request.getLastName());
        user.setEmail(request.getEmail());
        user.setPhoneNumber(request.getPhoneNumber());
        user.setAddress1(request.getAddress1());
        user.setAddress2(request.getAddress2());
        user.setCountry(request.getCountry());
        user.setLanguage(Language.valueOf(request.getLanguage().toUpperCase()));
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : Role.CLIENT);
        user.setVerified(false);

        user = userRepository.save(user);

        String activationToken = generateToken(user, TokenType.ACTIVATION);
        emailService.queueEmail(
                user.getEmail(),
                "Activate Your Premisave Account",
                buildActivationEmail(activationToken)
        );

        AuthResponse response = new AuthResponse();
        response.setToken(jwtService.generateToken(user));
        response.setRole(user.getRole().name());
        response.setRedirectUrl(getDashboardUrl(user.getRole()));
        return response;
    }

    public AuthResponse signin(AuthRequest request) {
        Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        User user = (User) authentication.getPrincipal();

        if (!user.isVerified()) {
            throw new RuntimeException("Account not verified");
        }

        // Update last login timestamp
        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        // Optional: cache user in Redis
        redisTemplate.opsForValue().set("user:" + user.getEmail(), user);

        AuthResponse response = new AuthResponse();
        response.setToken(jwtService.generateToken(user));
        response.setRole(user.getRole().name());
        response.setRedirectUrl(getDashboardUrl(user.getRole()));
        return response;
    }

    public void verifyAccount(String tokenStr) {
        Token token = tokenRepository.findByToken(tokenStr)
                .orElseThrow(() -> new RuntimeException("Invalid or expired token"));

        if (token.isUsed() || token.getExpiryDate().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Token has expired or already been used");
        }

        User user = token.getUser();
        user.setVerified(true);
        userRepository.save(user);

        token.setUsed(true);
        tokenRepository.save(token);
    }

    public void resendActivation(String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (user.isVerified()) {
            throw new RuntimeException("Account is already verified");
        }

        String activationToken = generateToken(user, TokenType.ACTIVATION);
        emailService.queueEmail(
                email,
                "Activate Your Premisave Account",
                buildActivationEmail(activationToken)
        );
    }

    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String resetToken = generateToken(user, TokenType.RESET_PASSWORD);
        emailService.queueEmail(
                user.getEmail(),
                "Reset Your Premisave Password",
                buildResetEmail(resetToken)
        );
    }

    public void changePassword(ChangePasswordRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) auth.getPrincipal();

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("Current password is incorrect");
        }

        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new RuntimeException("New passwords do not match");
        }

        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    private String generateToken(User user, TokenType type) {
        String tokenValue = UUID.randomUUID().toString();

        Token token = new Token();
        token.setToken(tokenValue);
        token.setType(type);
        token.setExpiryDate(LocalDateTime.now().plus(24, ChronoUnit.HOURS));
        token.setUsed(false);
        token.setUser(user);

        tokenRepository.save(token);
        return tokenValue;
    }

    private String buildActivationEmail(String token) {
        String link = "http://localhost:8080/auth/verify/" + token;
        return "<html>" +
                "<body>" +
                "<h2>Welcome to Premisave!</h2>" +
                "<p>Please click the link below to activate your account:</p>" +
                "<a href='" + link + "' style='padding:10px 20px; background:#007bff; color:white; text-decoration:none; border-radius:5px;'>Activate Account</a>" +
                "<p>Or copy and paste this link: " + link + "</p>" +
                "<p>This link expires in 24 hours.</p>" +
                "</body>" +
                "</html>";
    }

    private String buildResetEmail(String token) {
        String link = "http://localhost:3000/reset-password?token=" + token; // Adjust to your frontend URL
        return "<html>" +
                "<body>" +
                "<h2>Password Reset Request</h2>" +
                "<p>Click the link below to reset your password:</p>" +
                "<a href='" + link + "' style='padding:10px 20px; background:#dc3545; color:white; text-decoration:none; border-radius:5px;'>Reset Password</a>" +
                "<p>Or copy and paste this link: " + link + "</p>" +
                "<p>This link expires in 24 hours.</p>" +
                "</body>" +
                "</html>";
    }

    private String getDashboardUrl(Role role) {
        return switch (role) {
            case CLIENT -> "/dashboard/client";
            case HOME_OWNER -> "/dashboard/home-owner";
            case ADMIN -> "/dashboard/admin";
            case OPERATIONS -> "/dashboard/operations";
            case FINANCE -> "/dashboard/finance";
            case SUPPORT -> "/dashboard/support";
        };
    }
}