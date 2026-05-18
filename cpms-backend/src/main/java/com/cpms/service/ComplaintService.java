package com.cpms.service;

import com.cpms.entity.Complaint;
import com.cpms.repository.ComplaintRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ComplaintService {

    private final ComplaintRepository complaintRepository;

    public List<Complaint> listAll() {
        return complaintRepository.findAll();
    }

    public List<Complaint> listByOwner(Long ownerId) {
        return complaintRepository.findByOwner_OwnerId(ownerId);
    }

    public List<Complaint> listByStatus(String status) {
        return complaintRepository.findByStatus(status);
    }

    public Complaint getById(Long id) {
        return complaintRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("投诉建议不存在"));
    }

    public Complaint create(Complaint complaint) {
        return complaintRepository.save(complaint);
    }

    public Complaint reply(Long id, String replyText) {
        Complaint complaint = getById(id);
        complaint.setReply(replyText);
        complaint.setStatus("resolved");
        complaint.setRepliedAt(LocalDateTime.now());
        return complaintRepository.save(complaint);
    }

    public void delete(Long id) {
        complaintRepository.deleteById(id);
    }
}
