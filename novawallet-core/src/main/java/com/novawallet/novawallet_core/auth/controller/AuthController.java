package com.novawallet.novawallet_core.auth.controller;

import com.novawallet.novawallet_core.auth.dto.RegisterRequest;
import com.novawallet.novawallet_core.auth.dto.RegisterResponse;
import com.novawallet.novawallet_core.auth.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {
    private final AuthService authService;
    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(
            @Valid @RequestBody RegisterRequest Request
    ){
        RegisterResponse response=authService.register(Request);
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(response);
    }

}
