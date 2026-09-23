# Spektra — resep standar (macOS/zsh)
# .env.local (gitignored) berisi SUPABASE_URL & SUPABASE_ANON_KEY.
# Password DB Supabase TIDAK disimpan — berikan via env saat target dipakai.

-include .env.local
export SUPABASE_URL SUPABASE_ANON_KEY SUPABASE_DB_HOST SUPABASE_DB_PORT SUPABASE_DB_USER

.PHONY: dev build-web-cloud analyze apply-cloud verify-cloud

## App lokal penuh (Drift/SQLite, tanpa Supabase)
dev:
	flutter run -d chrome

## App dengan backend cloud (auth login wajib saat pertama kali)
dev-cloud:
	test -n "$(SUPABASE_URL)" || (echo "SUPABASE_URL kosong — isi .env.local dulu"; exit 1)
	flutter run -d chrome --dart-define=SUPABASE_URL=$(SUPABASE_URL) --dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)

## Build web (lokal)
build-web:
	flutter build web

## Build web (mode cloud)
build-web-cloud:
	test -n "$(SUPABASE_URL)" || (echo "SUPABASE_URL kosong — isi .env.local dulu"; exit 1)
	flutter build web --dart-define=SUPABASE_URL=$(SUPABASE_URL) --dart-define=SUPABASE_ANON_KEY=$(SUPABASE_ANON_KEY)

analyze:
	flutter analyze

## Cek koneksi DB Supabase langsung (validasi kredensial pooler)
## (butuh SUPABASE_DB_PASSWORD di env)
validate-db-creds:
	test -n "$(SUPABASE_DB_PASSWORD)" || (echo "butuh SUPABASE_DB_PASSWORD di env"; exit 1)
	cd tool && SUPABASE_DB_PASSWORD=$(SUPABASE_DB_PASSWORD) node -e "\
	const pg=require('pg');\
	const p=new pg.Pool({host:process.env.SUPABASE_DB_HOST,port:Number(process.env.SUPABASE_DB_PORT)||5432,user:process.env.SUPABASE_DB_USER,password:process.env.SUPABASE_DB_PASSWORD,database:'postgres',ssl:{rejectUnauthorized:false},connectionTimeoutMillis:10000,max:1});\
	p.query('select 1 as ok').then(r=>{console.log('DB connected — ok =',r.rows[0].ok);return p.end()}).catch(e=>{console.error('DB FAIL:',e.message);process.exit(1)});"

## Apply migrasi db/migrations + db/supabase ke project Supabase
## (butuh SUPABASE_DB_PASSWORD di env)
apply-cloud:
	test -n "$(SUPABASE_DB_PASSWORD)" || (echo "butuh SUPABASE_DB_PASSWORD di env"; exit 1)
	cd tool && SUPABASE_DB_PASSWORD=$(SUPABASE_DB_PASSWORD) node apply_supabase.mjs

## Verifikasi E2E backend (auth+RLS+CRUD+cascade). exit 2 = rate-limit → coba lagi nanti
## (butuh SUPABASE_DB_PASSWORD di env)
verify-cloud:
	test -n "$(SUPABASE_DB_PASSWORD)" || (echo "butuh SUPABASE_DB_PASSWORD di env"; exit 1)
	cd tool && SUPABASE_DB_PASSWORD=$(SUPABASE_DB_PASSWORD) node verify_cloud.mjs