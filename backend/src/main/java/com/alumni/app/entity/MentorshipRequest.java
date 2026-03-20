package com.alumni.app.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;
import java.util.List;
import com.alumni.app.enums.MentorshipStatus;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(org.springframework.data.jpa.domain.support.AuditingEntityListener.class)
public class MentorshipRequest {
    @Id
    private String id;

    @ManyToOne
    @JoinColumn(name = "student_id", nullable = false)
    private User student;

    @ManyToOne
    @JoinColumn(name = "mentor_id", nullable = true) // Can be nullable if not yet assigned
    private User mentor;

    @Column(columnDefinition = "TEXT")
    private String reason;

    @ElementCollection
    private List<String> topics;

    private String preferredSchedule;

    @Enumerated(EnumType.STRING)
    private MentorshipStatus status;

    @org.springframework.data.annotation.CreatedDate
    @Column(updatable = false)
    private LocalDateTime createdAt;

    @org.springframework.data.annotation.LastModifiedDate
    private LocalDateTime updatedAt;
}
