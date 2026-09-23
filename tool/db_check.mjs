// Verifikasi cepat skema & constraint dari docs/dev-db.md.
// Jalankan setelah `npm run apply`. Kalau di bawah ini lolos semua → backend
// dasar valid. (Selalu buang data uji di akhir.)

import pg from 'pg';

const config = {
  host: process.env.PGHOST ?? '127.0.0.1',
  port: Number(process.env.PGPORT ?? 5432),
  user: process.env.PGUSER ?? 'postgres',
  password: process.env.PGPASSWORD ?? '',
  database: process.env.PGDATABASE ?? 'spektra',
};

const client = new pg.Client(config);
await client.connect();

const checks = [];
const ok = (n, msg) => checks.push(`${n ? '✓' : '✗'} ${msg}`);

try {
  // 1. schema ada
  const tables = await client.query(
    `select table_name from information_schema.tables
     where table_schema='public' order by table_name`,
  );
  ok(
    tables.rows.some((r) => r.table_name === 'projects') &&
      tables.rows.some((r) => r.table_name === 'tasks'),
    `tabel projects & tasks ada (${tables.rows.map((r) => r.table_name).join(', ')})`,
  );

  // 2. data valid
  await client.query('begin');
  await client.query(
    `insert into public.projects (title, category) values ('__sanity__', 0)`,
  );
  await client.query(
    `insert into public.tasks (project_id, name, status, position)
     select id, 'UI', 1, 0 from public.projects where title='__sanity__'`,
  );
  const count = await client.query(
    `select count(*)::int as n from public.tasks t
     join public.projects p on p.id=t.project_id
     where p.title='__sanity__'`,
  );
  ok(count.rows[0].n === 1, 'insert valid → task terbaca');

  // 3. constraint: category di luar range harus ditolak
  // (pakai savepoint supaya transaksi tidak aborted oleh kegagalan ini)
  let rejected = false;
  await client.query('savepoint sp_bad');
  try {
    await client.query(
      `insert into public.projects (title, category) values ('__bad__', 7)`,
    );
  } catch {
    rejected = true;
  }
  await client.query('rollback to savepoint sp_bad');
  ok(rejected, 'category=7 ditolak CHECK constraint');

  // 4. cascade delete
  await client.query(`delete from public.projects where title='__sanity__'`);
  const leftover = await client.query(
    `select count(*)::int as n from public.tasks t
     join public.projects p on p.id=t.project_id
     where p.title='__sanity__'`,
  );
  const orphan = await client.query(
    `select count(*)::int as n from public.tasks
     where project_id not in (select id from public.projects)`,
  );
  ok(leftover.rows[0].n === 0 && orphan.rows[0].n === 0, 'delete project → cascade bersih');
  await client.query('rollback');
} finally {
  await client.end();
}

const allPassed = checks.every((c) => c.startsWith('✓'));
checks.forEach((c) => console.log(c));
console.log(allPassed ? '\n✅ semua cek lolos — backend dasar valid' : '\n❌ ada cek gagal');
process.exit(allPassed ? 0 : 1);