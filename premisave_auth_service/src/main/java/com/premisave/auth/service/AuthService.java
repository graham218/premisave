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
import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.FileCopyUtils;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;
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
    private final ResourceLoader resourceLoader;

    @Value("${frontend.url:http://localhost:3000}")
    private String frontendUrl;

    @Value("${backend.url:http://localhost:8080}")
    private String backendUrl;

    @Value("${email.activation.path:/templates/activation-email.html}")
    private String activationEmailPath;

    @Value("${email.reset-password.path:/templates/reset-password-email.html}")
    private String resetPasswordEmailPath;

    // Dashboard URLs from properties
    @Value("${dashboard.url.client:${frontend.url}/dashboard/client}")
    private String clientDashboardUrl;

    @Value("${dashboard.url.home-owner:${frontend.url}/dashboard/home-owner}")
    private String homeOwnerDashboardUrl;

    @Value("${dashboard.url.admin:${frontend.url}/dashboard/admin}")
    private String adminDashboardUrl;

    @Value("${dashboard.url.operations:${frontend.url}/dashboard/operations}")
    private String operationsDashboardUrl;

    @Value("${dashboard.url.finance:${frontend.url}/dashboard/finance}")
    private String financeDashboardUrl;

    @Value("${dashboard.url.support:${frontend.url}/dashboard/support}")
    private String supportDashboardUrl;

    private Map<Role, String> dashboardUrls;

    @PostConstruct
    public void init() {
        dashboardUrls = new HashMap<>();
        dashboardUrls.put(Role.CLIENT, clientDashboardUrl);
        dashboardUrls.put(Role.HOME_OWNER, homeOwnerDashboardUrl);
        dashboardUrls.put(Role.ADMIN, adminDashboardUrl);
        dashboardUrls.put(Role.OPERATIONS, operationsDashboardUrl);
        dashboardUrls.put(Role.FINANCE, financeDashboardUrl);
        dashboardUrls.put(Role.SUPPORT, supportDashboardUrl);
    }

    public AuthService(UserRepository userRepository,
                       TokenRepository tokenRepository,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService,
                       AuthenticationManager authenticationManager,
                       EmailService emailService,
                       RedisTemplate<String, Object> redisTemplate,
                       ResourceLoader resourceLoader) {
        this.userRepository = userRepository;
        this.tokenRepository = tokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.authenticationManager = authenticationManager;
        this.emailService = emailService;
        this.redisTemplate = redisTemplate;
        this.resourceLoader = resourceLoader;
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
        
        // Fix Language handling
        try {
            Language language = Language.valueOf(request.getLanguage().toUpperCase());
            user.setLanguage(language);
        } catch (IllegalArgumentException e) {
            user.setLanguage(Language.ENGLISH);
        }
        
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setRole(request.getRole() != null ? request.getRole() : Role.CLIENT);
        user.setVerified(false);
        user.setActive(true);

        user = userRepository.save(user);
        System.out.println("DEBUG: User saved to MongoDB with ID: " + user.getId());

        String activationToken = generateToken(user, TokenType.ACTIVATION);
        String activationLink = backendUrl + "/auth/verify/" + activationToken;
        
        try {
            String emailContent = readEmailTemplate(activationEmailPath)
                    .replace("[activationLink]", activationLink);
            
            // Use RabbitMQ to queue the email
            emailService.queueEmail(
                    user.getEmail(),
                    "Activate Your Premisave Account",
                    emailContent
            );
            System.out.println("DEBUG: Email queued for: " + user.getEmail());
            
        } catch (IOException e) {
            // Fallback to simple email if template fails
            emailService.queueEmail(
                    user.getEmail(),
                    "Activate Your Premisave Account",
                    buildActivationEmail(activationToken)
            );
            System.out.println("DEBUG: Using fallback email template for: " + user.getEmail());
        }

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
            throw new RuntimeException("Account not verified. Please check your email.");
        }

        if (!user.isActive()) {
            throw new RuntimeException("Account is deactivated. Please contact support.");
        }

        // Update last login timestamp
        user.setLastLoginAt(LocalDateTime.now());
        userRepository.save(user);

        // Cache user in Redis
        redisTemplate.opsForValue().set("user:" + user.getId(), user);

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
        String activationLink = backendUrl + "/auth/verify/" + activationToken;
        
        try {
            String emailContent = readEmailTemplate(activationEmailPath)
                    .replace("[activationLink]", activationLink);
            emailService.queueEmail(
                    email,
                    "Activate Your Premisave Account",
                    emailContent
            );
        } catch (IOException e) {
            emailService.queueEmail(
                    email,
                    "Activate Your Premisave Account",
                    buildActivationEmail(activationToken)
            );
        }
    }

    public void resetPassword(ResetPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new RuntimeException("User not found"));

        String resetToken = generateToken(user, TokenType.RESET_PASSWORD);
        String resetLink = frontendUrl + "/reset-password?token=" + resetToken;
        
        try {
            String emailContent = readEmailTemplate(resetPasswordEmailPath)
                    .replace("[resetLink]", resetLink);
            emailService.queueEmail(
                    user.getEmail(),
                    "Reset Your Premisave Password",
                    emailContent
            );
        } catch (IOException e) {
            emailService.queueEmail(
                    user.getEmail(),
                    "Reset Your Premisave Password",
                    buildResetEmail(resetToken)
            );
        }
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
        
        // Clear cached user
        redisTemplate.delete("user:" + user.getId());
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
        System.out.println("DEBUG: Token saved for user: " + user.getId());
        return tokenValue;
    }

    private String buildActivationEmail(String token) {
        String link = backendUrl + "/auth/verify/" + token;
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
        String link = frontendUrl + "/reset-password?token=" + token;
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
        return dashboardUrls.getOrDefault(role, frontendUrl + "/dashboard");
    }

    private String readEmailTemplate(String templatePath) throws IOException {
        Resource resource = resourceLoader.getResource("classpath:" + templatePath);
        if (!resource.exists()) {
            throw new IOException("Email template not found: " + templatePath);
        }
        try (Reader reader = new InputStreamReader(resource.getInputStream(), StandardCharsets.UTF_8)) {
            return FileCopyUtils.copyToString(reader);
        }
    }
}