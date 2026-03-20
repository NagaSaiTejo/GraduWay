package com.alumni.app.controller;

import com.alumni.app.entity.ChatMessage;
import com.alumni.app.entity.ChatSession;
import com.alumni.app.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/chats")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class ChatController {
    private final ChatService chatService;

    @PostMapping("/sessions")
    public ChatSession createSession(@RequestBody ChatSession session) {
        return chatService.createOrGetSession(session);
    }

    @GetMapping("/user/{userId}")
    public List<ChatSession> getUserSessions(@PathVariable String userId) {
        return chatService.getUserSessions(userId);
    }

    @PostMapping("/{sessionId}/messages")
    public ChatMessage sendMessage(@PathVariable String sessionId, @RequestBody ChatMessage message) {
        return chatService.sendMessage(sessionId, message);
    }

    @GetMapping("/{sessionId}/messages")
    public List<ChatMessage> getMessages(@PathVariable String sessionId) {
        return chatService.getMessages(sessionId);
    }
}
