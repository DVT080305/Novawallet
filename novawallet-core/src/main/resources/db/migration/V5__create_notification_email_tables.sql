
CREATE TABLE email_verifications (
                                     id UUID PRIMARY KEY,

                                     user_id UUID NOT NULL,
                                     token_hash VARCHAR(64) NOT NULL UNIQUE,

                                     expires_at TIMESTAMPTZ NOT NULL,
                                     used_at TIMESTAMPTZ,

                                     attempt_count INTEGER NOT NULL DEFAULT 0,
                                     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                     CONSTRAINT fk_email_verification_user
                                         FOREIGN KEY (user_id)
                                             REFERENCES users(id),

                                     CONSTRAINT chk_email_verification_attempts
                                         CHECK (attempt_count >= 0),

                                     CONSTRAINT chk_email_verification_token_hash
                                         CHECK (token_hash ~ '^[0-9a-f]{64}$'),

    CONSTRAINT chk_email_verification_expiry
        CHECK (expires_at > created_at),

    CONSTRAINT chk_email_verification_used_at
        CHECK (
            used_at IS NULL
            OR used_at >= created_at
        )
);

-- 2. NOTIFICATIONS
CREATE TABLE notifications (
                               id UUID PRIMARY KEY,

                               user_id UUID NOT NULL,
                               transaction_id UUID,

                               type VARCHAR(50) NOT NULL,
                               title VARCHAR(200) NOT NULL,
                               body TEXT NOT NULL,

                               is_read BOOLEAN NOT NULL DEFAULT FALSE,

                               created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                               read_at TIMESTAMPTZ,

                               CONSTRAINT fk_notification_user
                                   FOREIGN KEY (user_id)
                                       REFERENCES users(id),

                               CONSTRAINT fk_notification_transaction
                                   FOREIGN KEY (transaction_id)
                                       REFERENCES wallet_transactions(id),

                               CONSTRAINT chk_notification_type
                                   CHECK (type IN (
                                                   'WELCOME',
                                                   'TRANSFER_SENT',
                                                   'TRANSFER_RECEIVED'
                                       )),

                               CONSTRAINT chk_notification_read
                                   CHECK (
                                       (is_read = FALSE AND read_at IS NULL)
                                           OR
                                       (is_read = TRUE AND read_at IS NOT NULL)
                                       )
);

-- 3. EMAIL DELIVERIES
CREATE TABLE email_deliveries (
                                  id UUID PRIMARY KEY,

                                  user_id UUID NOT NULL,
                                  outbox_event_id UUID,

                                  template_code VARCHAR(60) NOT NULL,
                                  recipient_email VARCHAR(255) NOT NULL,

                                  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                                  retry_count INTEGER NOT NULL DEFAULT 0,

                                  next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                  provider_message_id VARCHAR(255),
                                  last_error TEXT,

                                  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                  sent_at TIMESTAMPTZ,

                                  CONSTRAINT fk_email_delivery_user
                                      FOREIGN KEY (user_id)
                                          REFERENCES users(id),

                                  CONSTRAINT fk_email_delivery_outbox
                                      FOREIGN KEY (outbox_event_id)
                                          REFERENCES outbox_events(id),

                                  CONSTRAINT chk_email_delivery_status
                                      CHECK (status IN ('PENDING', 'SENT', 'FAILED')),

                                  CONSTRAINT chk_email_delivery_retry
                                      CHECK (retry_count >= 0),

                                  CONSTRAINT chk_email_delivery_template
                                      CHECK (template_code IN (
                                                               'EMAIL_VERIFICATION',
                                                               'WELCOME',
                                                               'TRANSFER_SUCCESS',
                                                               'TRANSFER_RECEIVED'
                                          )),

                                  CONSTRAINT chk_email_delivery_sent_at
                                      CHECK (
                                          (status = 'SENT' AND sent_at IS NOT NULL)
                                              OR
                                          (status <> 'SENT' AND sent_at IS NULL)
                                          )
);

-- 4. INDEXES

CREATE INDEX idx_email_verifications_user
    ON email_verifications(user_id);

CREATE INDEX idx_email_verifications_expiry
    ON email_verifications(expires_at)
    WHERE used_at IS NULL;

CREATE INDEX idx_notifications_user_created
    ON notifications(user_id, created_at DESC);

CREATE INDEX idx_notifications_unread
    ON notifications(user_id, created_at DESC)
    WHERE is_read = FALSE;

CREATE INDEX idx_email_deliveries_pending
    ON email_deliveries(next_attempt_at)
    WHERE status = 'PENDING';

CREATE INDEX idx_email_deliveries_outbox
    ON email_deliveries(outbox_event_id)
    WHERE outbox_event_id IS NOT NULL;

-- Prevent duplicate delivery records for the
-- same event, recipient and template.
CREATE UNIQUE INDEX uq_email_delivery_event_recipient
    ON email_deliveries(
                        outbox_event_id,
                        recipient_email,
                        template_code
        )
    WHERE outbox_event_id IS NOT NULL;
