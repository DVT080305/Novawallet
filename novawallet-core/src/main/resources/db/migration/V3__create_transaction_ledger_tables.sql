
CREATE TABLE wallet_transactions (
                                     id UUID PRIMARY KEY,

                                     transaction_ref VARCHAR(64) NOT NULL UNIQUE,

                                     source_wallet_id UUID NOT NULL,
                                     destination_wallet_id UUID NOT NULL,

                                     amount BIGINT NOT NULL,
                                     currency CHAR(3) NOT NULL DEFAULT 'VND',

                                     type VARCHAR(30) NOT NULL DEFAULT 'P2P_TRANSFER',
                                     status VARCHAR(20) NOT NULL DEFAULT 'PENDING',

                                     failure_reason VARCHAR(100),

                                     created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
                                     completed_at TIMESTAMPTZ,

                                     CONSTRAINT fk_txn_source_wallet
                                         FOREIGN KEY (source_wallet_id)
                                             REFERENCES wallets(id),

                                     CONSTRAINT fk_txn_destination_wallet
                                         FOREIGN KEY (destination_wallet_id)
                                             REFERENCES wallets(id),

                                     CONSTRAINT chk_txn_amount
                                         CHECK (amount > 0),

                                     CONSTRAINT chk_txn_currency
                                         CHECK (currency = 'VND'),

                                     CONSTRAINT chk_txn_type
                                         CHECK (type = 'P2P_TRANSFER'),

                                     CONSTRAINT chk_txn_status
                                         CHECK (status IN ('PENDING', 'COMPLETED', 'FAILED')),

                                     CONSTRAINT chk_txn_different_wallets
                                         CHECK (source_wallet_id <> destination_wallet_id),

                                     CONSTRAINT chk_txn_completed_at
                                         CHECK (
                                             (status = 'COMPLETED' AND completed_at IS NOT NULL)
                                                 OR
                                             (status <> 'COMPLETED' AND completed_at IS NULL)
                                             )
);

CREATE TABLE journal_entries (
                                 id UUID PRIMARY KEY,

                                 transaction_id UUID NOT NULL UNIQUE,
                                 entry_ref VARCHAR(64) NOT NULL UNIQUE,
                                 entry_type VARCHAR(30) NOT NULL,
                                 posted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

                                 CONSTRAINT fk_journal_transaction
                                     FOREIGN KEY (transaction_id)
                                         REFERENCES wallet_transactions(id),

                                 CONSTRAINT chk_journal_entry_type
                                     CHECK (entry_type = 'P2P_TRANSFER')
);

CREATE TABLE journal_lines (
                               id UUID PRIMARY KEY,

                               journal_entry_id UUID NOT NULL,
                               ledger_account_id UUID NOT NULL,

                               line_number INTEGER NOT NULL,
                               direction VARCHAR(10) NOT NULL,
                               amount BIGINT NOT NULL,
                               currency CHAR(3) NOT NULL DEFAULT 'VND',

                               CONSTRAINT fk_journal_line_entry
                                   FOREIGN KEY (journal_entry_id)
                                       REFERENCES journal_entries(id),

                               CONSTRAINT fk_journal_line_account
                                   FOREIGN KEY (ledger_account_id)
                                       REFERENCES ledger_accounts(id),

                               CONSTRAINT uq_journal_line_number
                                   UNIQUE (journal_entry_id, line_number),

                               CONSTRAINT chk_journal_line_number
                                   CHECK (line_number > 0),

                               CONSTRAINT chk_journal_direction
                                   CHECK (direction IN ('DEBIT', 'CREDIT')),

                               CONSTRAINT chk_journal_amount
                                   CHECK (amount > 0),

                               CONSTRAINT chk_journal_currency
                                   CHECK (currency = 'VND')
);

CREATE INDEX idx_wallet_txn_source_created
    ON wallet_transactions(source_wallet_id, created_at DESC);

CREATE INDEX idx_wallet_txn_destination_created
    ON wallet_transactions(destination_wallet_id, created_at DESC);

CREATE INDEX idx_wallet_txn_status
    ON wallet_transactions(status);

CREATE INDEX idx_journal_lines_account
    ON journal_lines(ledger_account_id);
