package com.novawallet.novawallet_core.user.entity;

import jakarta.persistence.*;

import java.time.OffsetDateTime;
import java.util.UUID;

@Entity
@Table(name="users")

public class User {
    @Id
    @Column(name="id",nullable = false)
    private UUID id;

    @Column(name="email",nullable = false,length = 255)
    private String email;
    @Column(name="password_hash",nullable = false,length = 255)
    private String passwordHash;
    @Column(name="full_name",nullable = false,length = 150)
    private String fullName;
    @Enumerated(EnumType.STRING)
    @Column(name="status",nullable = false,length = 20)
    private UserStatus status = UserStatus.PENDING;
    @Column(name="email_verifiedAt")
    private OffsetDateTime emailVerifiedAt;
    @Column(name="created_at",nullable = false)
    private OffsetDateTime createdAt;
    @Column(name="update_at",nullable = false)
    private OffsetDateTime updatedAt;
    protected User() {
    }

    public User(String email, String passwordHash, String fullName) {
        this.id = UUID.randomUUID();
        this.email = email;
        this.passwordHash = passwordHash;
        this.fullName = fullName;
    }
    public void activate(){
        if(this.status != UserStatus.PENDING){
            throw new IllegalStateException("Only pending users can be activated");
        }
        this.status =UserStatus.ACTIVE;
        this.emailVerifiedAt = OffsetDateTime.now();
    }
    public void lock(){
        if(this.status!=UserStatus.ACTIVE){
            throw new IllegalStateException("Only active users can be locked");
        }
        this.status=UserStatus.LOCKED;
    }

    public UUID getId() {
        return id;
    }

    public String getEmail() {
        return email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public String getFullName() {
        return fullName;
    }

    public UserStatus getStatus() {
        return status;
    }

    public OffsetDateTime getEmailVerifiedAt() {
        return emailVerifiedAt;
    }

    public OffsetDateTime getCreatedAt() {
        return createdAt;
    }

    public OffsetDateTime getUpdatedAt() {
        return updatedAt;
    }
    // Gan moc thoi gian khi luu entity
    @PrePersist
    protected void onCreate() {
        OffsetDateTime now = OffsetDateTime.now();
        this.createdAt = now;
        this.updatedAt = now;
    }
    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = OffsetDateTime.now();
    }
}
