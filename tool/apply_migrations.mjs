// Apply migrasi Postgres lokal (DBngin) ke database `spektra`.
//
// Koneksi via env (default pola DBngin lokal):
//   PGHOST=127.0.0.1 PGPORT=<port DBngin> PGUSER=postgres PGPASSWORD=
//
// Database `spektra` dibuat otomatis jika belum ada, lalu db/migrations/*.sql
// dijalankan urut (setiap file dibungkus transaction sendiri).

import { readFile, readdir } from 'node:fs/promises';
import { resolve, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const MIGRATIONS_DIR = join(root, 'db', 'migrations');
const DB_NAME = process.env.PGDATABASE ?? 'spektra';

const baseConfig = {
  host: process.env.PGHOST ?? '127.0.0.1',
  port: Number(process.env.PGPORT ?? 5432),
  user: process.env.PGUSER ?? 'postgres',
  password: process.env.PGPASSWORD ?? '',
};

async function createDatabaseIfMissing() {
  const admin = new pg.Client({ ...baseConfig, database: 'postgres' });
  await admin.connect();
  const res = await admin.query('select 1 from pg_database where datname = $1', [DB_NAME]);
  if (res.rowCount === 0) {
    await admin.query(`create database "${DB_NAME}"`);
    console.log(`• database "${DB_NAME}" dibuat`);
  } else {
    console.log(`• database "${DB_NAME}" sudah ada`);
  }
  await admin.end();
}

async function applyMigration(file) {
  const sql = await readFile(join(MIGRATIONS_DIR, file), 'utf8');
  const client = new pg.Client({ ...baseConfig, database: DB_NAME });
  await client.connect();
  try {
    await client.query('begin');
    await client.query(sql);
    await client.query('commit');
    console.log(`• applied ${file}`);
  } catch (err) {
    await client.query('rollback');
    throw new Error(`gagal apply ${file}: ${err.message}`);
  } finally {
    await client.end();
  }
}

const files = (await readdir(MIGRATIONS_DIR))
  .filter((f) => f.endsWith('.sql'))
  .sort();

await createDatabaseIfMissing();
for (const file of files) {
  await applyMigration(file);
}
console.log(`✓ semua migrasi diterapkan ke "${DB_NAME}" (${files.length} file)`);