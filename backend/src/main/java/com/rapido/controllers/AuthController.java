package com.rapido.controllers;

import com.rapido.models.User;
import com.rapido.services.OTPService;
import com.rapido.services.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class AuthController {
    
    private final OTPService otpService;
    private final UserService userService;
    
    public AuthController(OTPService otpService, UserService userService) {
        this.otpService = otpService;
        this.userService = userService;
    }
    
    @PostMapping("/send-otp")
    public ResponseEntity<Map<String, Object>> sendOTP(@RequestBody Map<String, String> request) {
        String phoneNumber = request.get("phoneNumber");
        String otp = otpService.generateOTP();
        
        userService.saveOTP(phoneNumber, otp);
        otpService.sendOTP(phoneNumber);
        otpService.sendEmailOTP("pratiknagap5@gmail.com", otp);
        
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", "OTP sent successfully");
        response.put("otp", otp); // Remove in production
        return ResponseEntity.ok(response);
    }
    
    @PostMapping("/verify-otp")
    public ResponseEntity<Map<String, Object>> verifyOTP(@RequestBody Map<String, String> request) {
        String phoneNumber = request.get("phoneNumber");
        String otp = request.get("otp");
        
        boolean isValid = userService.verifyOTP(phoneNumber, otp);
        
        Map<String, Object> response = new HashMap<>();
        if (isValid) {
            User user = userService.getOrCreateUser(phoneNumber);
            response.put("success", true);
            response.put("message", "OTP verified successfully");
            response.put("user", Map.of("phone", phoneNumber, "name", user.getName() != null ? user.getName() : "User"));
        } else {
            response.put("success", false);
            response.put("message", "Invalid OTP");
        }
        return ResponseEntity.ok(response);
    }
}
