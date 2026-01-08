package com.premisave.auth.service;

import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import org.springframework.amqp.rabbit.annotation.RabbitListener;

@Service
public class EmailService {

    private final JavaMailSender mailSender;
    private final RabbitTemplate rabbitTemplate;

    public EmailService(JavaMailSender mailSender, RabbitTemplate rabbitTemplate) {
        this.mailSender = mailSender;
        this.rabbitTemplate = rabbitTemplate;
    }

    public void queueEmail(String to, String subject, String htmlContent) {
        EmailMessage message = new EmailMessage(to, subject, htmlContent);
        rabbitTemplate.convertAndSend("email_queue", message);
    }

    @RabbitListener(queues = "email_queue")
    public void sendEmail(EmailMessage message) {
        MimeMessage mimeMessage = mailSender.createMimeMessage();
        try {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true);
            helper.setTo(message.getTo());
            helper.setSubject(message.getSubject());
            helper.setText(message.getHtmlContent(), true);
            mailSender.send(mimeMessage);
        } catch (MessagingException e) {
            // Handle error
        }
    }

    // Inner class for message
    private static class EmailMessage {
        private String to;
        private String subject;
        private String htmlContent;

        public EmailMessage(String to, String subject, String htmlContent) {
            this.to = to;
            this.subject = subject;
            this.htmlContent = htmlContent;
        }

        // Getters
        public String getTo() { return to; }
        public String getSubject() { return subject; }
        public String getHtmlContent() { return htmlContent; }
    }
}