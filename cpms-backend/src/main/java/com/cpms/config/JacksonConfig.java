package com.cpms.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.json.Jackson2ObjectMapperBuilder;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

@Configuration
public class JacksonConfig {

    @Bean
    public ObjectMapper objectMapper(Jackson2ObjectMapperBuilder builder) {
        JavaTimeModule module = new JavaTimeModule();

        // Handle both "yyyy-MM-dd" and ISO datetime strings for LocalDate
        module.addDeserializer(LocalDate.class, new com.fasterxml.jackson.databind.JsonDeserializer<LocalDate>() {
            @Override
            public LocalDate deserialize(com.fasterxml.jackson.core.JsonParser p,
                                         com.fasterxml.jackson.databind.DeserializationContext ctxt)
                    throws java.io.IOException {
                String text = p.getText().trim();
                if (text.isEmpty()) return null;
                try {
                    // Try date-only format first
                    return LocalDate.parse(text, DateTimeFormatter.ISO_LOCAL_DATE);
                } catch (DateTimeParseException e1) {
                    try {
                        // Try datetime with offset (e.g., "2026-06-30T00:00:00+08:00")
                        return LocalDate.parse(text, DateTimeFormatter.ISO_OFFSET_DATE_TIME);
                    } catch (DateTimeParseException e2) {
                        try {
                            // Try datetime with Z (e.g., "2026-06-30T00:00:00.000Z")
                            if (text.endsWith("Z")) {
                                text = text.substring(0, text.length() - 1) + "+00:00";
                            }
                            return LocalDate.parse(text, DateTimeFormatter.ISO_OFFSET_DATE_TIME);
                        } catch (DateTimeParseException e3) {
                            // Try datetime without zone (e.g., "2026-06-30T00:00:00")
                            return LocalDate.parse(text, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                        }
                    }
                }
            }
        });

        module.addSerializer(LocalDate.class,
                new LocalDateSerializer(DateTimeFormatter.ISO_LOCAL_DATE));
        module.addSerializer(LocalDateTime.class,
                new LocalDateTimeSerializer(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        return builder
                .modules(module)
                .build();
    }
}
