// Verifikasi END-TO-END backend Supabase Spektra: auth → RLS → CRUD → cascade.
//
// Alur: signup via API asli (identitas dibuat benar oleh gotrue) → "klik link
// email" disimulasikan dengan set email_confirmed_at via DB → login REST →
// insert project/task, select embedded `tasks(*)`, update, RLS isolasi antar
// user, delete cascade → CLEANUP semua data tes + user (wajib).
//
//   cd tool
//   SUPABASE_URL=... SUPABASE_ANON_KEY=... \
//   SUPABASE_DB_HOST=... SUPABASE_DB_USER=... SUPABASE_DB_PASSWORD=... \
//   node verify_cloud.mjs
//
// Kredensial bisa juga diambil dari .env.local bila env kosong.
//
// Exit code: 0 = semua pass · 1 = ada yang gagal · 2 = otomatis-skip
// (email rate limit project, mis. 429 — jalankan lagi nanti / pakai app E2E).

import { readFile } from 'node:fs/promises';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import pg from 'pg';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const envLocal = await readFile(resolve(root, '.env.local'), 'utf8').catch(() => '');

const env = (name) =>
  process.env[name] ??
  envLocal.split('\n').find((l) => l.startsWith(`${name}=`))?.split('=').slice(1).join('=');

const SUPABASE_URL = env('SUPABASE_URL');
const ANON_KEY = env('SUPABASE_ANON_KEY');
const DB_HOST = env('SUPABASE_DB_HOST');
const DB_USER = env('SUPABASE_DB_USER');
const DB_PASSWORD = env('SUPABASE_DB_PASSWORD');
const DB_PORT = Number(env('SUPABASE_DB_PORT')) || 5432;

if (!SUPABASE_URL || !ANON_KEY || !DB_HOST || !DB_PASSWORD) {
  console.error('Env kurang lengkap (Supabase URL/anon, DB host/user/password).');
  process.exit(1);
}

const ts = Date.now();
const A = { email: `spektra.e2e.a.${ts}@example.com`, password: 'SpektraE2E!1' };
const B = { email: `spektra.e2e.b.${ts}@example.com`, password: 'SpektraE2E!2' };
const userIds = {};

const pool = new pg.Pool({
  host: DB_HOST,
  port: DB_PORT,
  user: DB_USER ?? 'postgres',
  password: DB_PASSWORD,
  database: 'postgres',
  ssl: { rejectUnauthorized: false },
  max: 2,
  connectionTimeoutMillis: 15000,
});

const API = `${SUPABASE_URL}/rest/v1`;
const AUTH = `${SUPABASE_URL}/auth/v1`;
const jh = (token) => ({
  apikey: ANON_KEY,
  Authorization: token ? `Bearer ${token}` : `Bearer ${ANON_KEY}`,
  'Content-Type': 'application/json',
});

let failures = 0;
const check = (label, ok, extra = '') => {
  console.log(`${ok ? '  PASS' : '! FAIL'}  ${label}${extra ? `  (${extra})` : ''}`);
  if (!ok) failures++;
};

async function api(token, method, path, body) {
  const res = await fetch(`${API}${path}`, {
    method,
    headers: jh(token),
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const raw = await res.text();
  let json = null;
  try {
    json = raw === '' ? null : JSON.parse(raw);
  } catch {
    json = raw;
  }
  return { status: res.status, json };
}

async function authApi(path, body) {
  const res = await fetch(`${AUTH}${path}`, {
    method: 'POST',
    headers: jh(null),
    body: JSON.stringify(body),
  });
  return { status: res.status, json: await res.json() };
}

async function tx(fn) {
  const client = await pool.connect();
  try {
    await client.query('begin');
    try {
      const out = await fn(client);
      await client.query('commit');
      return out;
    } catch (e) {
      await client.query('rollback').catch(() => {});
      throw e;
    }
  } finally {
    client.release();
  }
}

async function signUpAndConfirm(u) {
  const su = await authApi('/signup', { email: u.email, password: u.password });
  const uid = su.json?.id ?? su.json?.user?.id;
  if (su.status === 429) {
    return { blocked: true, detail: su.json?.error_code ?? su.status };
  }
  if (!uid) {
    throw new Error(`signup gagal (${su.status}): ${JSON.stringify(su.json).slice(0, 200)}`);
  }
  const upd = await tx((client) =>
    client.query(
      `update auth.users
         set email_confirmed_at = now(), confirmation_token = null
       where id = $1 and email_confirmed_at is null`,
      [uid],
    ),
  );
  if ((upd.rowCount ?? 0) !== 1) throw new Error(`gagal konfirmasi user ${u.email}`);
  return { blocked: false, uid, email: u.email, password: u.password };
}

async function signIn(u) {
  const res = await authApi('/token?grant_type=password', {
    email: u.email,
    password: u.password,
  });
  return res.status === 200 && res.json?.access_token
    ? res.json.access_token
    : null;
}

try {
  const ua = await signUpAndConfirm(A);
  if (ua.blocked) {
    console.log(
      'SKIP otomatis: email rate limit Supabase aktif (' +
        `${JSON.stringify(ua.detail)}).` +
        '\n  Jalankan lagi nanti saat limit sudah cooldown, atau verifikasi lewat app E2E' +
        ' (registrasi email asli + klik link konfirmasi).',
    );
    process.exit(2);
  }
  userIds.A = ua.uid;
  const ub = await signUpAndConfirm(B);
  userIds.B = ub.uid;
  check('signup + konfirmasi user A & B', !!userIds.A && !!userIds.B);

  const tokenA = await signIn(A);
  const tokenB = await signIn(B);
  check('login A (email+password)', !!tokenA);
  check('login B (email+password)', !!tokenB);
  if (!tokenA || !tokenB) throw new Error('login gagal — tes berhenti');

  const deadlineIn = '2026-10-05T08:00:00+00:00';
  const projectRes = await api(tokenA, 'POST', '/projects', {
    title: `Verifikasi E2E ${ts}`,
    category: 1,
    deadline: deadlineIn,
    owner_id: userIds.A,
  });
  const project = projectRes.json?.[0];
  check('insert project (owner_id, deadline)', projectRes.status === 201 && project?.id, String(projectRes.status));

  const task1 = await api(tokenA, 'POST', '/tasks', {
    project_id: project?.id,
    name: 'Task satu',
    status: 0,
    position: 0,
  });
  check('insert task 1', task1.status === 201, String(task1.status));
  const task2 = await api(tokenA, 'POST', '/tasks', {
    project_id: project?.id,
    name: 'Task dua',
    status: 0,
    position: 1,
  });
  check('insert task 2', task2.status === 201, String(task2.status));

  const embedded = await api(tokenA, 'GET', `/projects?select=*,tasks(*)&id=eq.${project?.id}`);
  const row = embedded.json?.[0];
  const tasks = row?.tasks ?? [];
  const tsFormatOk =
    typeof row?.deadline === 'string' &&
    !Number.isNaN(Date.parse(row.deadline)) &&
    row?.created_at !== undefined;
  check('select embedded tasks(*)', Array.isArray(tasks) && tasks.length === 2);
  check('timestamps ISO-8601 parsable', !!tsFormatOk, JSON.stringify(row?.deadline));
  check('position order (0,1)', tasks[0]?.position === 0 && tasks[1]?.position === 1);

  const updStatus = await api(tokenA, 'PATCH', `/tasks?id=eq.${task2.json?.[0]?.id}`, { status: 2 });
  check('update task status (→Review)', updStatus.status === 204, String(updStatus.status));

  const updDeadline = await api(tokenA, 'PATCH', `/projects?id=eq.${project?.id}`, {
    deadline: '2026-11-20T12:30:00+00:00',
  });
  check('update project deadline', updDeadline.status === 204, String(updDeadline.status));

  const iso = await api(tokenB, 'GET', `/projects?select=id&id=eq.${project?.id}`);
  check('RLS isolasi user B (tak lihat milik A)', iso.status === 200 && iso.json.length === 0);

  const forb = await api(tokenB, 'DELETE', `/projects?id=eq.${project?.id}`);
  check('RLS cegah user B hapus proyek A', forb.status === 403 || forb.status === 401, String(forb.status));

  const delRes = await api(tokenA, 'DELETE', `/projects?id=eq.${project?.id}`);
  const afterDel = await api(tokenA, 'GET', `/tasks?select=id&project_id=eq.${project?.id}`);
  check('delete project via REST (owner)', [200, 204].includes(delRes.status), String(delRes.status));
  check('cascade: tasks ikut terhapus', afterDel.json.length === 0);

  console.log('--- hasil backend:', failures === 0 ? 'SEMUA PASS' : `${failures} GAGAL`);
} catch (e) {
  console.error('ERROR:', e.message);
  failures++;
} finally {
  // CLEANUP WAJIB: data tes + user (anak → induk). Email membalik: contoh
  // email berbeda, jadi cukup id user.
  await tx(async (client) => {
    for (const id of [userIds.A, userIds.B]) {
      if (!id) continue;
      await client.query('delete from public.tasks where project_id in (select id from public.projects where owner_id = $1)', [id]);
      await client.query('delete from public.projects where owner_id = $1', [id]);
      await client.query('delete from public.profiles where id = $1', [id]);
      await client.query('delete from auth.identities where user_id = $1', [id]);
      await client.query('delete from auth.users where id = $1', [id]);
    }
  }).catch((e) => {
    console.error('CLEANUP ERROR:', e.message);
    failures++;
  });

  const r = await tx(async (client) =>
    (
      await client.query(
        `select (select count(*) from public.projects) p,
                (select count(*) from public.tasks) t,
                (select count(*) from public.profiles) f,
                (select count(*) from auth.users where email like 'spektra.e2e.%@example.com') u`,
      )
    ).rows[0],
  ).catch(() => null);
  const clean = r && r.p === '0' && r.t === '0' && r.f === '0' && r.u === '0';
  check(
    'cleanup: tabel bersih (tak ada sisa tes)',
    !!clean,
    r ? `projects=${r.p} tasks=${r.t} profiles=${r.f} sisa_user=${r.u}` : 'gagal baca',
  );

  await Promise.race([pool.end(), new Promise((t) => setTimeout(t, 5000))]);
  process.exit(failures === 0 ? 0 : 1);
}