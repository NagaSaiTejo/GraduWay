package com.alumni.app.repository;

import com.alumni.app.entity.MentorshipRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import com.alumni.app.enums.MentorshipStatus;

public interface MentorshipRequestRepository extends JpaRepository<MentorshipRequest, String> {
    Page<MentorshipRequest> findByMentorId(String mentorId, Pageable pageable);
    
    Page<MentorshipRequest> findByMentorIdAndStatus(String mentorId, MentorshipStatus status, Pageable pageable);
    
    long countByMentorIdAndStatus(String mentorId, MentorshipStatus status);
}
