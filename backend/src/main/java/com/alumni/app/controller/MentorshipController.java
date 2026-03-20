package com.alumni.app.controller;

import com.alumni.app.entity.MentorshipRequest;
import com.alumni.app.enums.MentorshipStatus;
import com.alumni.app.service.MentorshipService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;
import java.util.List;

import com.alumni.app.dto.DashboardSummaryDTO;
import com.alumni.app.dto.MentorshipRequestDTO;
import com.alumni.app.entity.MentorshipRequest;
import com.alumni.app.enums.MentorshipStatus;
import com.alumni.app.service.MentorshipService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mentorship")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class MentorshipController {
    private final MentorshipService mentorshipService;

    @PostMapping("/requests")
    public ResponseEntity<MentorshipRequestDTO> submitRequest(@RequestBody MentorshipRequest request) {
        return new ResponseEntity<>(mentorshipService.submitRequest(request), HttpStatus.CREATED);
    }

    @GetMapping("/requests/{id}")
    public ResponseEntity<MentorshipRequestDTO> getRequestById(@PathVariable String id) {
        return ResponseEntity.ok(mentorshipService.getRequestById(id));
    }

    @GetMapping("/mentor/{mentorId}")
    public ResponseEntity<Page<MentorshipRequestDTO>> getMentorRequests(
            @PathVariable String mentorId,
            @RequestParam(required = false) MentorshipStatus status,
            @PageableDefault(size = 10, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable) {
        return ResponseEntity.ok(mentorshipService.getMentorRequests(mentorId, status, pageable));
    }

    @PatchMapping("/requests/{id}/status")
    public ResponseEntity<MentorshipRequestDTO> updateStatus(
            @PathVariable String id,
            @RequestParam String mentorId,
            @RequestParam MentorshipStatus status) {
        return ResponseEntity.ok(mentorshipService.updateStatus(id, mentorId, status));
    }

    @GetMapping("/mentor/{mentorId}/summary")
    public ResponseEntity<DashboardSummaryDTO> getDashboardSummary(@PathVariable String mentorId) {
        return ResponseEntity.ok(mentorshipService.getDashboardSummary(mentorId));
    }
}
