package com.alumni.app.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessage {
    @Id
    private String id;

    @ManyToOne
    @JoinColumn(name = "session_id")
    private ChatSession session;

    @ManyToOne
    @JoinColumn(name = "sender_id")
    private User sender;

    @Column(columnDefinition = "TEXT")
    private String text;

    private LocalDateTime timestamp;
    private boolean isSeen;
}
