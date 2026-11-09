CREATE TABLE wallets
(
    id       UUID PRIMARY KEY,
    user_id  UUID        NOT NULL UNIQUE,
    currency CHAR(3)     NOT NULL DEFAULT 'VND',
    status   VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_wallet_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT chk_wallet_currency
        CHECK(currency='VND'),
    CONSTRAINT chk_wallet_status
        CHECK ( status IN('ACTIVE','FROZEN'))
);
CREATE TABLE ledger_accounts(
    id UUID PRIMARY KEY ,
    wallet_id UUID UNIQUE ,
    account_code VARCHAR(100) NOT NULL  UNIQUE ,
    account_type VARCHAR(20) NOT NULL ,
    currency CHAR(3) NOT NULL DEFAULT 'VND',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_ledger_account_wallet
                            FOREIGN KEY (wallet_id) REFERENCES wallets(id),

    CONSTRAINT chk_ledger_account_type
                            CHECK (account_type IN ('ASSET','LIABILITY')),
    CONSTRAINT chk_ledger_currency
                            CHECK (currency ='VND'),
    CONSTRAINT  chk_ledger_account_status
                            CHECK (status IN ('ACTIVE','CLOSED')),
    CONSTRAINT chk_wallet_liability_account
                            CHECK (wallet_id IS NULL OR account_type = 'LIABILITY')
);
CREATE TABLE account_balances(
    LEDGER_ACCOUNT_ID UUID PRIMARY KEY ,
    posted_balance BIGINT NOT NULL DEFAULT 0,
    held_amount BIGINT NOT NULL DEFAULT 0,
    version BIGINT NOT NULL  DEFAULT 0,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_balance_ledger_account
                             FOREIGN KEY (ledger_account_id)
                             REFERENCES ledger_accounts(id),
    CONSTRAINT chk_posted_balance
                             CHECK ( posted_balance>=0),
    CONSTRAINT chk_held_amount
                             CHECK(held_amount>=0),
    CONSTRAINT chk_available_balance
                             CHECK (posted_balance>=held_amount),
    CONSTRAINT chk_balance_version
                             CHECK ( version>=0)
);