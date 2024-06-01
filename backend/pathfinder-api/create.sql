CREATE TABLE prizes (
    id TEXT PRIMARY KEY,
    sender TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    password TEXT,
    hashed_password TEXT,
    type TEXT,
    contract_address TEXT,
    name TEXT,
    symbol TEXT,
    amount BIGINT,
    expires BIGINT,
    active BOOLEAN
);