package com.alumni.app.entity;

import jakarta.persistence.*;
import lombok.*;
import java.util.List;

@Entity
@Table(name = "users")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    @Id
    private String id; // Use String to match Flutter's uuid if needed, or Long for DB
    
    private String name;
    private String email;
    private String password; // For real auth later
    private String branch;
    private String year;
    
    @ElementCollection
    private List<String> skills;
    
    // Professional info (matched from AuthProvider)
    private String techField;
    private String company;
    private String yoe;
}
