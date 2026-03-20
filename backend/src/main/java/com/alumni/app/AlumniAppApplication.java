package com.alumni.app;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

@SpringBootApplication
@EnableJpaAuditing
public class AlumniAppApplication {

    public static void main(String[] args) {
        SpringApplication.run(AlumniAppApplication.class, args);
    }

}
