
CREATE TABLE idempotency_records (
                                     id UUID PRIMARY KEY,

                                     user_id UUID NOT NULL,
                                     operation VARCHAR(50) NOT NULL,
                                     idempotency_key VARCHAR(100) NOT NULL,
                                     request_hash VARCHAR(64) NOT NULL,

                                     transaction_id UUID,

                                     status VARCHAR(20) NOT NULL DEFAULT 'PROCESSING',
                                     http_status INTEGER,
                                     response_body JSONB,

                                     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                     updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                     expires_at TIMESTAMPTZ NOT NULL,

                                     CONSTRAINT fk_idempotency_user
                                         FOREIGN KEY (user_id)
                                             REFERENCES users(id),

                                     CONSTRAINT fk_idempotency_transaction
                                         FOREIGN KEY (transaction_id)
                                             REFERENCES wallet_transactions(id),

                                     CONSTRAINT uq_idempotency_request
                                         UNIQUE (user_id, operation, idempotency_key),

                                     CONSTRAINT chk_idempotency_status
                                         CHECK (status IN (
                                                           'PROCESSING', 'COMPLETED', 'FAILED'
                                             )),

                                     CONSTRAINT chk_idempotency_key_not_empty
                                         CHECK (length(trim(idempotency_key)) > 0),

                                     CONSTRAINT chk_idempotency_operation_not_empty
                                         CHECK (length(trim(operation)) > 0),

                                     CONSTRAINT chk_idempotency_hash
                                         CHECK (request_hash ~ '^[0-9a-f]{64}$'),

    CONSTRAINT chk_idempotency_http_status
        CHECK (
            http_status IS NULL
            OR http_status BETWEEN 100 AND 599
        ),

    CONSTRAINT chk_idempotency_result
        CHECK (
            status = 'PROCESSING'
            OR (
                http_status IS NOT NULL
                AND response_body IS NOT NULL
            )
        ),

    CONSTRAINT chk_idempotency_expiry
        CHECK (expires_at > created_at)
);

-- 2. OUTBOX EVENTS
CREATE TABLE outbox_events (
                               id UUID PRIMARY KEY,

                               event_key VARCHAR(150) NOT NULL UNIQUE,
                               aggregate_type VARCHAR(50) NOT NULL,
                               aggregate_id UUID NOT NULL,
                               event_type VARCHAR(100) NOT NULL,

                               payload JSONB NOT NULL,

                               status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                               retry_count INTEGER NOT NULL DEFAULT 0,

                               available_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                               locked_until TIMESTAMPTZ,

                               created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                               published_at TIMESTAMPTZ,
                               last_error TEXT,

                               CONSTRAINT chk_outbox_status
                                   CHECK (status IN (
                                                     'PENDING', 'PUBLISHED', 'FAILED'
                                       )),

                               CONSTRAINT chk_outbox_retry_count
                                   CHECK (retry_count >= 0),

                               CONSTRAINT chk_outbox_event_key
                                   CHECK (length(trim(event_key)) > 0),

                               CONSTRAINT chk_outbox_published_at
                                   CHECK (
                                       status <> 'PUBLISHED'
                                           OR published_at IS NOT NULL
                                       ),

                               CONSTRAINT chk_outbox_payload_object
                                   CHECK (jsonb_typeof(payload) = 'object')
);

-- 3. INDEXES

CREATE INDEX idx_idempotency_expiry
    ON idempotency_records(expires_at);

CREATE INDEX idx_idempotency_transaction
    ON idempotency_records(transaction_id)
    WHERE transaction_id IS NOT NULL;

CREATE INDEX idx_outbox_pending
    ON outbox_events(available_at, created_at)
    WHERE status = 'PENDING';

CREATE INDEX idx_outbox_aggregate
    ON outbox_events(aggregate_type, aggregate_id);
