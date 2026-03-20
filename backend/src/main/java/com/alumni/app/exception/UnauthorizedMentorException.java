package com.alumni.app.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.FORBIDDEN)
public class UnauthorizedMentorException extends RuntimeException {
    public UnauthorizedMentorException(String message) {
        super(message);
    }
}
