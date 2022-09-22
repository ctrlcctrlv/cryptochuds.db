BEGIN TRANSACTION;
DROP TABLE IF EXISTS gpg_keys_caps CASCADE;
CREATE TABLE gpg_keys_caps(
    id SERIAL PRIMARY KEY,
    key_id SERIAL NOT NULL,
    cap CHARACTER(1),
    CONSTRAINT fk_key_id FOREIGN KEY(key_id) REFERENCES gpg_keys(id)
);

DROP TYPE IF EXISTS COMPLIANCE CASCADE;
CREATE TYPE COMPLIANCE AS ENUM('RFC4880bis', 'de-vs', 'ROCA');

DROP FUNCTION IF EXISTS compliance_from_integer;
CREATE FUNCTION compliance_from_integer(i INTEGER)
    RETURNS COMPLIANCE
    AS
$$
    SELECT CASE i
        WHEN 8 THEN 'RFC4880bis'
        WHEN 1 THEN 'de-vs'
        WHEN 6001 THEN 'ROCA'
        ELSE NULL
    END::COMPLIANCE;
$$ LANGUAGE SQL;

DROP TABLE IF EXISTS gpg_keys CASCADE;
CREATE TABLE gpg_keys(
    id SERIAL PRIMARY KEY,
    algo SMALLINT NOT NULL,
    compliance COMPLIANCE NULL,
    curve TEXT NULL,
    "date" TIMESTAMP NOT NULL,
    "expires" TIMESTAMP NULL,
    "fingerprint" BYTEA NOT NULL CONSTRAINT fp_check CHECK (length(fingerprint) = 20),
    flag TEXT NULL,
    hash TEXT NULL,
    issuer TEXT NULL,
    "keygrip" BYTEA NOT NULL CONSTRAINT kg_check CHECK (length(keygrip) = 20),
    "keyid" BYTEA NOT NULL CONSTRAINT ki_check CHECK (length(keyid) = 8),
    length INTEGER NOT NULL,
    origin INTEGER NOT NULL,
    origin_url INET NULL,
    ownertrust CHARACTER(1) NULL,
    sig TEXT NULL,
    pkt_type_tag CHARACTER(3) NOT NULL,
    updated TIMESTAMP NULL
);

DROP TABLE IF EXISTS gpg_uids CASCADE;
CREATE TABLE gpg_uids(
    id SERIAL PRIMARY KEY,
    key_id SERIAL NOT NULL,
    key_for_uid INTEGER NOT NULL DEFAULT 0,
    email TEXT NULL,
    "location" TEXT NULL,
    "name" TEXT NULL,
    CONSTRAINT fk_key_id FOREIGN KEY(key_id) REFERENCES gpg_keys(id)
);

DROP FUNCTION IF EXISTS str_to_int(TEXT);
CREATE FUNCTION str_to_int(s TEXT)
    RETURNS INTEGER
    AS
$$
BEGIN
    IF NULLIF(s, '') IS NULL OR coalesce(trim(s)) = '' THEN
        RETURN NULL;
    ELSE
        RETURN s::INTEGER;
    END IF;
END
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS to_timestamp(TEXT);
CREATE FUNCTION to_timestamp(ts TEXT)
    RETURNS TIMESTAMP
    AS
$$
BEGIN
    IF NULLIF(ts, '') IS NULL OR coalesce(trim(ts)) = '' THEN
        RETURN NULL;
    ELSE
        RETURN to_timestamp(ts::BIGINT) AT TIME ZONE 'UTC';
    END IF;
END
$$ LANGUAGE plpgsql;

INSERT INTO gpg_keys (SELECT id, algo::SMALLINT, compliance_from_integer(str_to_int(compliance)), NULLIF(curve, ''), to_timestamp(date), to_timestamp(expires), decode(fingerprint, 'hex'), NULLIF(flag, ''), NULLIF(hash, ''), NULLIF(issuer, ''), decode(keygrip, 'hex'), decode(keyid, 'hex'), str_to_int(length), str_to_int(origin), NULL, substr(ownertrust, 0)::CHARACTER, NULLIF(sig, ''), "type"::CHARACTER(3), to_timestamp(updated) FROM "keyring"."root");
INSERT INTO gpg_uids (SELECT id, root_id, replace(prefix, '/uids/', '')::INTEGER, NULLIF(email, ''), NULLIF("location", ''), NULLIF("name", '') FROM "keyring"."uids");
INSERT INTO gpg_keys_caps(key_id, cap) (SELECT id, unnest(regexp_split_to_array(cap, '')) FROM "keyring"."root");
COMMIT;
