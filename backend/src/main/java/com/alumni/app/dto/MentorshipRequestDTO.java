package com.alumni.app.dto;

import com.alumni.app.enums.MentorshipStatus;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class MentorshipRequestDTO {
    private String id;
    private String studentName;
    private String message;
    private MentorshipStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
