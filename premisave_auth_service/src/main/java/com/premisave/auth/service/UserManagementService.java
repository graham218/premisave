package com.premisave.auth.service;

import com.premisave.auth.dto.UserDto;
import com.premisave.auth.dto.UserSearchRequest;
import com.premisave.auth.entity.User;
import com.premisave.auth.repository.UserRepository;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class UserManagementService {

    private final UserRepository userRepository;
    private final ModelMapper modelMapper = new ModelMapper();

    public UserManagementService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public UserDto createUser(UserDto userDto) {
        User user = modelMapper.map(userDto, User.class);
        user = userRepository.save(user);
        return modelMapper.map(user, UserDto.class);
    }

    public UserDto updateUser(String id, UserDto userDto) {
        User user = userRepository.findById(id).orElseThrow(() -> new RuntimeException("User not found"));
        modelMapper.map(userDto, user);
        user = userRepository.save(user);
        return modelMapper.map(user, UserDto.class);
    }

    public void deleteUser(String id) {
        userRepository.deleteById(id);
    }

    public void archiveUser(String id) {
        User user = userRepository.findById(id).orElseThrow();
        user.setArchived(true);
        userRepository.save(user);
    }

    public void unarchiveUser(String id) {
        User user = userRepository.findById(id).orElseThrow();
        user.setArchived(false);
        userRepository.save(user);
    }

    public void activateUser(String id) {
        User user = userRepository.findById(id).orElseThrow();
        user.setActive(true);
        userRepository.save(user);
    }

    public void deactivateUser(String id) {
        User user = userRepository.findById(id).orElseThrow();
        user.setActive(false);
        userRepository.save(user);
    }

    public void verifyUser(String id) {
        User user = userRepository.findById(id).orElseThrow();
        user.setVerified(true);
        userRepository.save(user);
    }

    public void unverifyUser(String id) {
        User user = userRepository.findById(id).orElseThrow();
        user.setVerified(false);
        userRepository.save(user);
    }

    public List<UserDto> searchUsers(UserSearchRequest request) {
        List<User> users = userRepository.searchUsers(request.getQuery());
        return users.stream().map(u -> modelMapper.map(u, UserDto.class)).collect(Collectors.toList());
    }
}