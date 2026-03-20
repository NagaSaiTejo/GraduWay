package com.alumni.app.repository;

import com.alumni.app.entity.ChatSession;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChatSessionRepository extends JpaRepository<ChatSession, String> {
    List<ChatSession> findByMentorIdOrMenteeId(String mentorId, String menteeId);
}
