psql chuds << EOF
CREATE TABLE chuds_temp(id SERIAL, foreign_id INTEGER UNIQUE NOT NULL, nick TEXT NOT NULL, registered_at TIMESTAMP NOT NULL, keyid TEXT NULL, fingerprint TEXT NULL, bitcoinaddress TEXT NULL, last_authed TIMESTAMP NULL, is_authed BOOL);
\COPY chuds_temp FROM 'chuds.csv' DELIMITER ',' CSV HEADER;
CREATE TABLE chuds(id SERIAL, foreign_id INTEGER UNIQUE NOT NULL, nick TEXT NOT NULL, registered_at TIMESTAMP NOT NULL, keyid BYTEA NULL CONSTRAINT gpg_keyid_check CHECK (length(keyid) = 8), keyid_disabled BOOL DEFAULT FALSE, fingerprint BYTEA NULL CONSTRAINT fp_check CHECK (length(fingerprint) = 20), bitcoinaddress TEXT NULL CONSTRAINT addy_check CHECK (length(bitcoinaddress) >= 27 AND length(bitcoinaddress) <= 34), last_authed TIMESTAMP NULL, is_authed BOOL);
INSERT INTO chuds (SELECT id, foreign_id, nick, registered_at, decode(replace(keyid, '_disabled', ''), 'hex') AS BYTEA, keyid LIKE '%_disabled', decode(fingerprint, 'hex') AS BYTEA, bitcoinaddress, last_authed, is_authed FROM chuds_temp WHERE length(fingerprint) = 40 OR fingerprint IS NULL);
EOF
./scripts/html_to_csv.py <(curl https://bitcoin-otc.com/viewgpg.php) creeptochuds.csv
./scripts/gpg_download.sh
gpg2 --homedir=gpghome --export --armor > gpgkeyring2.asc
./scripts/gpg_to_json.py
