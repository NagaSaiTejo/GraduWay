package com.alumni.app.service;

import com.alumni.app.entity.ChatMessage;
import com.alumni.app.entity.ChatSession;
import com.alumni.app.repository.ChatMessageRepository;
import com.alumni.app.repository.ChatSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatSessionRepository sessionRepository;
    private final ChatMessageRepository messageRepository;

    public ChatSession createOrGetSession(ChatSession session) {
        if (session.getId() == null) {
            session.setId(UUID.randomUUID().toString());
        }
        if (session.getCreatedAt() == null) {
            session.setCreatedAt(LocalDateTime.now());
        }
        return sessionRepository.save(session);
    }

    public List<ChatSession> getUserSessions(String userId) {
        return sessionRepository.findByMentorIdOrMenteeId(userId, userId);
    }

    public ChatMessage sendMessage(String sessionId, ChatMessage message) {
        ChatSession session = sessionRepository.findById(sessionId)
                .orElseThrow(() -> new RuntimeException("Session not found"));
        
        if (message.getId() == null) {
            message.setId(UUID.randomUUID().toString());
        }
        if (message.getTimestamp() == null) {
            message.setTimestamp(LocalDateTime.now());
        }
        message.setSession(session);
        return messageRepository.save(message);
    }

    public List<ChatMessage> getMessages(String sessionId) {
        return messageRepository.findBySessionIdOrderByTimestampAsc(sessionId);
    }
}
