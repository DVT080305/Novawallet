package com.novawallet.novawallet_core.common.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
@AllArgsConstructor
public enum ErrorCode {
    EMAIL_ALREADY_EXISTS("EMAIL_ ALREADY_EXISTS","email is already registered", HttpStatus.CONFLICT),
    INVALID_REQUEST("INVALID_REQUEST","invalid request data", HttpStatus.BAD_REQUEST),
    INTERNAL_ERROR("INTERNAL_ERROR","internal error", HttpStatus.INTERNAL_SERVER_ERROR);
    private final String code;
    private final String message;
    private final HttpStatus status;
}
