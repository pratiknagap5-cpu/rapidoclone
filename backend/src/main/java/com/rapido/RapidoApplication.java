package com.rapido;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories(basePackages = "com.rapido.repositories")
public class RapidoApplication {
    public static void main(String[] args) {
        SpringApplication.run(RapidoApplication.class, args);
    }
}
