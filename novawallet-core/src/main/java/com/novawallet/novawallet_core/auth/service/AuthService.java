package com.novawallet.novawallet_core.auth.service;

import com.novawallet.novawallet_core.auth.dto.RegisterRequest;
import com.novawallet.novawallet_core.auth.dto.RegisterResponse;
import com.novawallet.novawallet_core.user.entity.User;
import com.novawallet.novawallet_core.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;

@Service
@RequiredArgsConstructor
public class AuthService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Transactional
    public RegisterResponse register(RegisterRequest request){
        // Chuan hoa email
        String email =request.email()
                .trim()
                .toLowerCase(Locale.ROOT);
        if(userRepository.existsByEmail(email)){
            throw new IllegalStateException("Email already register!");}

            String passwordHash = passwordEncoder.encode(request.password());
            User user = new User(email, passwordHash, request.fullName().trim());
            User savedUser = userRepository.save(user);
            return new RegisterResponse(
                    savedUser.getId(),
                    savedUser.getEmail(),
                    savedUser.getStatus().name(),
                    "Registration successful. Please verify your email."
            );
        }
    }
