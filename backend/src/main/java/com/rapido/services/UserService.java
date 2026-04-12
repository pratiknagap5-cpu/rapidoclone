package com.rapido.services;

import com.rapido.models.User;
import com.rapido.repositories.UserRepository;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class UserService {
    private final UserRepository userRepository;

    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public void saveOTP(String phoneNumber, String otp) {
        userRepository.findByPhoneNumber(phoneNumber).ifPresentOrElse(
            user -> {
                user.setOtp(otp);
                user.setOtpExpiry(LocalDateTime.now().plusMinutes(5));
                userRepository.save(user);
            },
            () -> {
                User newUser = new User();
                newUser.setPhoneNumber(phoneNumber);
                newUser.setOtp(otp);
                newUser.setOtpExpiry(LocalDateTime.now().plusMinutes(5));
                newUser.setVerified(false);
                newUser.setCreatedAt(LocalDateTime.now());
                userRepository.save(newUser);
            }
        );
    }

    public boolean verifyOTP(String phoneNumber, String otp) {
        Optional<User> userOpt = userRepository.findByPhoneNumberAndOtp(phoneNumber, otp);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getOtpExpiry().isAfter(LocalDateTime.now())) {
                user.setVerified(true);
                user.setOtp(null);
                userRepository.save(user);
                return true;
            }
        }
        return false;
    }

    public User getOrCreateUser(String phoneNumber) {
        return userRepository.findByPhoneNumber(phoneNumber)
            .orElseGet(() -> {
                User user = new User();
                user.setPhoneNumber(phoneNumber);
                user.setVerified(true);
                user.setCreatedAt(LocalDateTime.now());
                return userRepository.save(user);
            });
    }
}
