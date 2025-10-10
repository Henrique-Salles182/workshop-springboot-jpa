package com.cursojavaudemy.webservice_program.Resources;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.cursojavaudemy.webservice_program.Entities.User;

@RestController
@RequestMapping(value = "/users")
public class UserResources {

    @GetMapping
    public ResponseEntity<User> findAll(){
        User user = new User(1L, "maria", "maria@gmail.com", "999999999", "123456");
        return ResponseEntity.ok().body(user);
    }
}
