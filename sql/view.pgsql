BEGIN TRANSACTION;
DROP VIEW IF EXISTS chuds_with_keys_and_uids;
\set query1 ' ''SELECT  c.id,g.fingerprint,g.keyid, \' || (SELECT ARRAY_TO_STRING(ARRAY_AGG(column_name), '', '') FROM information_schema.columns WHERE table_schema = ''public'' AND column_name NOT IN (''id'',''fingerprint'',''keyid'',''key_id'',''cap'')) || '', ARRAY_TO_STRING(ARRAY(SELECT kc.cap FROM gpg_keys_caps kc WHERE kc.key_id = u.key_id),''\'\,\''') caps FROM chuds c LEFT JOIN gpg_keys g on g.keyid = c.keyid LEFT JOIN gpg_uids u ON u.key_id = g.id'' "query2" '
SELECT :query1
\gset
CREATE OR REPLACE VIEW chuds_with_keys_and_uids AS (:query2);
COMMIT;
