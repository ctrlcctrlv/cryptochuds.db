BEGIN TRANSACTION;
DROP TABLE IF EXISTS chuds_temp, chuds;
CREATE TABLE chuds_temp(
    id SERIAL PRIMARY KEY,
    foreign_id INTEGER UNIQUE NOT NULL,
    nick TEXT NOT NULL,
    registered_at TEXT NOT NULL,
    keyid TEXT NULL,
    fingerprint TEXT NULL,
    bitcoinaddress TEXT NULL,
    last_authed TEXT NULL,
    is_authed BOOL
);

\COPY chuds_temp FROM 'chuds.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE chuds(
    id SERIAL PRIMARY KEY,
    foreign_id INTEGER UNIQUE NOT NULL,
    nick TEXT NOT NULL,
    registered_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    keyid BYTEA NULL CONSTRAINT gpg_keyid_check CHECK (length(keyid) = 8),
    keyid_disabled BOOL DEFAULT FALSE,
    fingerprint BYTEA NULL CONSTRAINT fp_check CHECK (length(fingerprint) = 20),
    bitcoinaddress TEXT NULL CONSTRAINT addy_check CHECK (length(bitcoinaddress) >= 27 AND length(bitcoinaddress) <= 34),
    last_authed TIMESTAMP WITHOUT TIME ZONE NULL,
    is_authed BOOL
);

INSERT INTO chuds (
    SELECT
        id,
        foreign_id,
        nick,
        to_timestamp(registered_at, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC',
        decode(replace(keyid, '_disabled', ''), 'hex') AS BYTEA,
        keyid LIKE '%_disabled',
        decode(fingerprint, 'hex') AS BYTEA,
        bitcoinaddress,
        to_timestamp(last_authed, 'YYYY-MM-DD HH24:MI:SS') AT TIME ZONE 'UTC',
        is_authed
    FROM chuds_temp WHERE length(fingerprint) = 40 OR fingerprint IS NULL
);
COMMIT;
