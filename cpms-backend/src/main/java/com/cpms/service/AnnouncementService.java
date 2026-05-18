package com.cpms.service;

import com.cpms.entity.Announcement;
import com.cpms.repository.AnnouncementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnnouncementService {

    private final AnnouncementRepository announcementRepository;

    public List<Announcement> listAll() {
        return announcementRepository.findAllByOrderByPublishTimeDesc();
    }

    public Announcement getById(Long id) {
        return announcementRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("公告不存在"));
    }

    public Announcement create(Announcement announcement) {
        return announcementRepository.save(announcement);
    }

    public void delete(Long id) {
        announcementRepository.deleteById(id);
    }
}
