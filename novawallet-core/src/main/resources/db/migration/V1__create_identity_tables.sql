CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL ,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    email_verified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL  DEFAULT NOW(),
    update_at TIMESTAMPTZ NOT NULL DEFAULT  NOW(),
    CONSTRAINT chk_users_status CHECK( status IN ('PENDING','ACTIVE','LOCKED'))

);
CREATE TABLE roles(
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(30) NOT NULL UNIQUE ,
    CONSTRAINT chk_roles_name CHECK (name IN('CUSTOMER','ADMIN'))
);
CREATE TABLE user_roles(
    user_id UUID NOT NULL,
    role_id BIGINT NOT NULL ,
    PRIMARY KEY (user_id,role_id),
    CONSTRAINT fk_user_roles_user
                       FOREIGN KEY (user_id)
                       REFERENCES users(id),
    CONSTRAINT fk_user_roles_role
                       FOREIGN KEY (role_id)
                       REFERENCES roles(id)
);
INSERT INTO roles(name)
VALUES ('CUSTOMER'),('ADMIN');
