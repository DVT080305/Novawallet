package com.novawallet.novawallet_core.user.repository;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
public class UserRepositoryIntergrationTest {
    @Autowired
    private UserRepository userRepository;
    @Test
    void shouldAccessUsersTable(){
        long count = userRepository.count();
        System.out.println("Total users: " + count);
        assertTrue(count > 0);
    }
    @Test
    void shouldReturnEmptyWhenEmailDoesNotExist(){
        boolean exists = userRepository.existsByEmail("not-test@example.come");
        assertTrue(exists);
    }
}
