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

    public AuthService(UserRepository userRepository, TokenRepository tokenRepository, PasswordEncoder passwordEncoder, JwtService jwtService, AuthenticationManager authenticationManager, EmailService emailService, RedisTemplate<String, Object> redisTemplate) {
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
        user.setRole(request.getRole());
        user.setVerified(false);
        user = userRepository.save(user);

        String activationToken = generateToken(user, TokenType.ACTIVATION);
        emailService.queueEmail(user.getEmail(), "Activate Your Account", buildActivationEmail(activationToken));

        AuthResponse response = new AuthResponse();
        response.setToken(jwtService.generateToken(user)); // Provisional token, but require verification
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

        // Cache user in Redis
        redisTemplate.opsForValue().set("user:" + user.getEmail(), user);

        AuthResponse response = new AuthResponse();
        response.setToken(jwtService.generateToken(user));
        response.setRole(user.getRole().name());
        response.setRedirectUrl(getDashboardUrl(user.getRole()));
        return response;
    }

    public void verifyAccount(String tokenStr) {
        Token token = tokenRepository.findByToken(tokenStr).orElseThrow(() -> new RuntimeException("Invalid token"));
        if (token.isUsed() || token.getExpiryDate().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("Token expired or used");
        }
        User user = token.getUser();
        user.setVerified(true);
        userRepository.save(user);
        token.setUsed(true);
        tokenRepository.save(token);
    }

    public void resendActivation(String email) {
        User user = userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
        if (user.isVerified()) {
            throw new RuntimeException("Already verified");
        }
        String activationToken = generateToken(user, TokenType.ACTIVATION);
        emailService.queueEmail(email, "Activate Your Account", buildActivationEmail(activationToken));
    }

    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElseThrow(() -> new RuntimeException("User not found"));
        String resetToken = generateToken(user, TokenType.RESET_PASSWORD);
        emailService.queueEmail(user.getEmail(), "Reset Password", buildResetEmail(resetToken));
    }

    public void changePassword(ChangePasswordRequest request) {
        // Assume authenticated user
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        User user = (User) auth.getPrincipal();
        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new RuntimeException("Invalid old password");
        }
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            throw new RuntimeException("Passwords don't match");
        }
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    private String generateToken(User user, TokenType type) {
        String tokenStr = UUID.randomUUID().toString();
        Token token = new Token();
        token.setToken(tokenStr);
        token.setType(type);
        token.setExpiryDate(LocalDateTime.now().plus(1, ChronoUnit.DAYS));
        token.setUser(user);
        tokenRepository.save(token);
        return tokenStr;
    }

    private String buildActivationEmail(String token) {
        // Load template and replace placeholders
        String template = "<html><body><h1>Activate Account</h1><a href='http://localhost:8080/auth/verify/" + token + "'>Click to activate</a></body></html>";
        return template;
    }

    private String buildResetEmail(String token) {
        String template = "<html><body><h1>Reset Password</h1><a href='http://localhost:8080/auth/reset-confirm/" + token + "'>Click to reset</a></body></html>";
        return template;
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