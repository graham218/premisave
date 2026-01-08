package com.premisave.auth.controller;

import com.premisave.auth.dto.UserDto;
import com.premisave.auth.dto.UserSearchRequest;
import com.premisave.auth.service.UserManagementService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/admin/users")
@PreAuthorize("hasRole('ADMIN')")
public class UserManagementController {

    private final UserManagementService userManagementService;

    public UserManagementController(UserManagementService userManagementService) {
        this.userManagementService = userManagementService;
    }

    @PostMapping("/create")
    public ResponseEntity<UserDto> createUser(@RequestBody UserDto userDto) {
        return ResponseEntity.ok(userManagementService.createUser(userDto));
    }

    @PutMapping("/update/{id}")
    public ResponseEntity<UserDto> updateUser(@PathVariable String id, @RequestBody UserDto userDto) {
        return ResponseEntity.ok(userManagementService.updateUser(id, userDto));
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<String> deleteUser(@PathVariable String id) {
        userManagementService.deleteUser(id);
        return ResponseEntity.ok("User deleted");
    }

    @PutMapping("/archive/{id}")
    public ResponseEntity<String> archiveUser(@PathVariable String id) {
        userManagementService.archiveUser(id);
        return ResponseEntity.ok("User archived");
    }

    @PutMapping("/unarchive/{id}")
    public ResponseEntity<String> unarchiveUser(@PathVariable String id) {
        userManagementService.unarchiveUser(id);
        return ResponseEntity.ok("User unarchived");
    }

    @PutMapping("/activate/{id}")
    public ResponseEntity<String> activateUser(@PathVariable String id) {
        userManagementService.activateUser(id);
        return ResponseEntity.ok("User activated");
    }

    @PutMapping("/deactivate/{id}")
    public ResponseEntity<String> deactivateUser(@PathVariable String id) {
        userManagementService.deactivateUser(id);
        return ResponseEntity.ok("User deactivated");
    }

    @PutMapping("/verify/{id}")
    public ResponseEntity<String> verifyUser(@PathVariable String id) {
        userManagementService.verifyUser(id);
        return ResponseEntity.ok("User verified");
    }

    @PutMapping("/unverify/{id}")
    public ResponseEntity<String> unverifyUser(@PathVariable String id) {
        userManagementService.unverifyUser(id);
        return ResponseEntity.ok("User unverified");
    }

    @PostMapping("/search")
    public ResponseEntity<List<UserDto>> searchUsers(@RequestBody UserSearchRequest request) {
        return ResponseEntity.ok(userManagementService.searchUsers(request));
    }
}