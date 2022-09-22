#!/usr/bin/env python3
import gnupg
import json
import os
import shutil
import sys

try:
    shutil.rmtree("/tmp/gpghome")
except FileNotFoundError:
    pass
os.mkdir("/tmp/gpghome", mode=0o700)
gpg = gnupg.GPG(gnupghome="/tmp/gpghome", keyring="/tmp/gpghome/keyring.pbx")
keys = gpg.import_keys_file('./gpgkeyring2.asc')
uid_to_dict = lambda uid: dict(email=uid[uid.rindex('<')+1:uid.rindex('>')] if '<' in uid else None, name=uid[:uid.index('(')-1] if '(' in uid else uid[:uid.index('<')-1] if '<' in uid else uid, location = uid[uid.index('(')+1:uid.rindex(')')] if '(' in uid and ')' in uid else None)

f = open("keyring2.jsonl", "w+")

for i, key in enumerate(gpg.list_keys()):
    if 'subkey_info' in key:
        del key['subkey_info']
    if 'subkeys' in key:
        del key['subkeys']
    if 'sigs' in key:
        del key['sigs']
    if not 'uids' in key: continue
    key['uids'] = {i: uid_to_dict(uid) for i, uid in enumerate(key['uids'])}
    json.dump(key, f)
    f.write("\n")
    if i % 500 == 0 and i != 0:
        print(f"Wrote {i} keys to JSON", file=sys.stderr)

f.close()
