package com.novawallet.novawallet_core.common.exception;

public record ErrorResponse(
        String code,
        String message
) {
}
