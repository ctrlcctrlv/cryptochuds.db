CREATE UNIQUE INDEX chuds_keyid_idx ON chuds(keyid);
CREATE UNIQUE INDEX gpg_keyid_idx ON gpg_keys(keyid);
CREATE UNIQUE INDEX gpg_fp_idx ON gpg_keys(fingerprint);
CREATE INDEX uids_text_search_idx ON gpg_uids USING GIN (to_tsvector('english', "name" || "email" || "location"));
