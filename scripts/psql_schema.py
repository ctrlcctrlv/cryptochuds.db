#!/usr/bin/env python3
import json
import jsonschema2db
import psycopg2

j2db = jsonschema2db.JSONSchemaToPostgres(json.load(open('keyring_schema.json')), postgres_schema="keyring", item_col_name="keyring_id", debug=True)
con = psycopg2.connect(dbname='chuds')
j2db.create_tables(con)
j2db.insert_items(con, enumerate(json.load(open('keyring.json'))))
j2db.create_links(con)
j2db.analyze(con)
con.commit()
