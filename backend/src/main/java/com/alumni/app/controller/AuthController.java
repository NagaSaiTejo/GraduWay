package com.alumni.app.controller;

import com.alumni.app.entity.User;
import com.alumni.app.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuthController {
    private final UserRepository userRepository;

    @PostMapping("/login")
    public User login(@RequestBody User loginRequest) {
        return userRepository.findByEmail(loginRequest.getEmail())
                .orElseGet(() -> {
                    // Auto-register for demo purposes if not found
                    loginRequest.setId(UUID.randomUUID().toString());
                    if (loginRequest.getName() == null) {
                        loginRequest.setName(loginRequest.getEmail().split("@")[0]);
                    }
                    return userRepository.save(loginRequest);
                });
    }

    @PostMapping("/signup")
    public User signup(@RequestBody User user) {
        if (user.getId() == null) {
            user.setId(UUID.randomUUID().toString());
        }
        return userRepository.save(user);
    }
}
