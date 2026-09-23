// Apply migrasi core + Supabase RLS langsung ke project Supabase cloud.
//
// Dua cara memilih koneksi (pilih salah satu):
//   1) SUPABASE_REF + SUPABASE_DB_PASSWORD → host `db.<ref>.supabase.co`
//      (TIDAK selalu resolve di infra baru; kalau gagal, pakai opsi 2)
//   2) SUPABASE_DB_HOST + SUPABASE_DB_PASSWORD (+ optional SUPABASE_DB_PORT,
//      SUPABASE_DB_USER) → host persis dari Dashboard → Connect.
//
// Password hanya via env, TIDAK PERNAH disimpan ke repo.

import { readFile, readdir } from 'node:fs/promises';
import { resolve, dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');

const ref = process.env.SUPABASE_REF;
const dbHost = process.env.SUPABASE_DB_HOST;
const password = process.env.SUPABASE_DB_PASSWORD;

const host = dbHost ?? (ref ? `db.${ref}.supabase.co` : null);
if (!host || !password) {
  console.error(
    'Gunakan salah satu:\n' +
      '  SUPABASE_REF=<ref> SUPABASE_DB_PASSWORD=<pw> node apply_supabase.mjs\n' +
      '  SUPABASE_DB_HOST=<host> SUPABASE_DB_PASSWORD=<pw> node apply_supabase.mjs',
  );
  process.exit(1);
}

const pool = new pg.Pool({
  host,
  port: Number(process.env.SUPABASE_DB_PORT ?? 5432),
  user: process.env.SUPABASE_DB_USER ?? 'postgres',
  password,
  database: process.env.SUPABASE_DB_NAME ?? 'postgres',
  ssl: { rejectUnauthorized: false },
  max: 2,
});

async function applyDir(dir, label) {
  const files = (await readdir(dir)).filter((f) => f.endsWith('.sql')).sort();
  for (const file of files) {
    const client = await pool.connect();
    try {
      const sql = await readFile(join(dir, file), 'utf8');
      await client.query('begin');
      await client.query(sql);
      await client.query('commit');
      console.log(`• applied ${label}/${file}`);
    } catch (err) {
      await client.query('rollback');
      throw new Error(`gagal apply ${file}: ${err.message}`);
    } finally {
      client.release();
    }
  }
  return files.length;
}

try {
  const n1 = await applyDir(join(root, 'db', 'migrations'), 'migrations');
  const n2 = await applyDir(join(root, 'db', 'supabase'), 'supabase');

  const client = await pool.connect();
  try {
    const tabs = await client.query(
      `select table_name from information_schema.tables
       where table_schema='public' order by table_name`,
    );
    const pols = await client.query(
      `select tablename, count(*)::int as n from pg_policies
       where schemaname='public' group by tablename order by tablename`,
    );
    const rls = await client.query(
      `select relname from pg_class
       join pg_namespace n on n.oid = relnamespace
       where n.nspname='public' and relrowsecurity
       order by relname`,
    );
    console.log('\n✓ selesai. Tabel public:', tabs.rows.map((r) => r.table_name).join(', '));
    console.log('✓ RLS aktif pada:', rls.rows.map((r) => r.relname).join(', ') || '(tidak ada)');
    console.log('✓ Policy per tabel:', pols.rows
      .map((r) => `${r.tablename}=${r.n}`).join(', ') || '(tidak ada)');
  } finally {
    client.release();
  }
} finally {
  await pool.end();
}