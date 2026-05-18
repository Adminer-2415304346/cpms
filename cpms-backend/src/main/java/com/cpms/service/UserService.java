package com.cpms.service;

import com.cpms.dto.LoginRequest;
import com.cpms.dto.LoginResponse;
import com.cpms.entity.User;
import com.cpms.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public LoginResponse login(LoginRequest req) {
        User user = userRepository.findByUsername(req.getUsername())
                .orElseThrow(() -> new RuntimeException("用户名或密码错误"));
        if (!user.getPassword().equals(req.getPassword())) {
            throw new RuntimeException("用户名或密码错误");
        }
        if ("disabled".equals(user.getStatus())) {
            throw new RuntimeException("账号已被禁用");
        }
        return new LoginResponse(user.getUserId(), user.getUsername(),
                user.getRole(), user.getRealName());
    }

    public User create(User user) {
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("用户名已存在");
        }
        return userRepository.save(user);
    }

    public User update(Long id, User updated) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
        if (updated.getRealName() != null) user.setRealName(updated.getRealName());
        if (updated.getPhone() != null) user.setPhone(updated.getPhone());
        if (updated.getEmail() != null) user.setEmail(updated.getEmail());
        if (updated.getStatus() != null) user.setStatus(updated.getStatus());
        if (updated.getPassword() != null && !updated.getPassword().isBlank()) {
            user.setPassword(updated.getPassword());
        }
        return userRepository.save(user);
    }

    public void delete(Long id) {
        userRepository.deleteById(id);
    }

    public User getById(Long id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("用户不存在"));
    }

    public List<User> listByRole(String role) {
        return userRepository.findByRole(role);
    }

    public List<User> listAll() {
        return userRepository.findAll();
    }
}
