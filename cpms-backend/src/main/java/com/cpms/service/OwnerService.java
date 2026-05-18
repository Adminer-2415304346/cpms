package com.cpms.service;

import com.cpms.entity.Owner;
import com.cpms.entity.User;
import com.cpms.exception.NotFoundException;
import com.cpms.repository.OwnerRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class OwnerService {

    private final OwnerRepository ownerRepository;
    private final UserService userService;

    public List<Owner> listAll() {
        return ownerRepository.findAll();
    }

    public Owner getById(Long id) {
        return ownerRepository.findById(id)
                .orElseThrow(() -> new NotFoundException("业主不存在"));
    }

    public Owner getByUserId(Long userId) {
        return ownerRepository.findByUser_UserId(userId)
                .orElseThrow(() -> new NotFoundException("业主信息不存在"));
    }

    public Owner create(Owner owner) {
        if (owner.getUser() != null && owner.getUser().getUserId() != null) {
            User user = userService.getById(owner.getUser().getUserId());
            owner.setUser(user);
        }
        if (ownerRepository.existsByIdCard(owner.getIdCard())) {
            throw new RuntimeException("该身份证号已注册");
        }
        return ownerRepository.save(owner);
    }

    public Owner update(Long id, Owner updated) {
        Owner owner = getById(id);
        if (updated.getName() != null) owner.setName(updated.getName());
        if (updated.getPhone() != null) owner.setPhone(updated.getPhone());
        if (updated.getMoveInDate() != null) owner.setMoveInDate(updated.getMoveInDate());
        return ownerRepository.save(owner);
    }

    public void delete(Long id) {
        ownerRepository.deleteById(id);
    }
}
