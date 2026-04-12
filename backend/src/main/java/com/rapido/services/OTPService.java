package com.rapido.services;

import com.rapido.repositories.UserRepository;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import java.util.Random;

@Service
public class OTPService {
    private final UserRepository userRepository;
    private final JavaMailSender mailSender;

    public OTPService(UserRepository userRepository, JavaMailSender mailSender) {
        this.userRepository = userRepository;
        this.mailSender = mailSender;
    }

    public String generateOTP() {
        Random random = new Random();
        return String.format("%06d", random.nextInt(1000000));
    }

    public void sendOTP(String phoneNumber) {
        // Mock SMS - print to console
        String otp = generateOTP();
        System.out.println("SMS OTP for " + phoneNumber + ": " + otp);
    }

    public void sendEmailOTP(String email, String otp) {
        try {
            SimpleMailMessage message = new SimpleMailMessage();
            message.setTo(email);
            message.setSubject("Rapido OTP Verification");
            message.setText("Your Rapido OTP is: " + otp + "\\nValid for 5 minutes.");
            mailSender.send(message);
            System.out.println("Email OTP sent to " + email + ": " + otp);
        } catch (Exception e) {
            System.out.println("Email failed: " + e.getMessage());
        }
    }
}
