#!/usr/bin/env node
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { createRequire } from 'node:module';
import { pathToFileURL } from 'node:url';

const require = createRequire('/root/repos/vliving-2026/package.json');
const sharp = require('sharp');
const { Client } = require('pg');

function arg(name, fallback='') {
  const i = process.argv.indexOf('--'+name);
  return i >= 0 ? process.argv[i+1] : fallback;
}
const input = arg('input');
const slug = arg('slug').replace(/[^a-z0-9-]/gi,'-').toLowerCase();
const ids = arg('property-ids').split(',').map(x=>Number(x.trim())).filter(Number.isInteger);
const coverNeedle = arg('cover').toLowerCase();
const envFile = arg('env');
if (!input || !slug || !ids.length || !envFile) throw new Error('args_required');
process.loadEnvFile(envFile);
if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL_missing');

const appObj = await import(pathToFileURL('/root/repos/vliving-2026/lib/objeto.js').href);
const { guardarPublico } = appObj;
const work = path.dirname(envFile);
const optimized = path.join(work,'optimized');
fs.mkdirSync(optimized,{recursive:true});
const exts = new Set(['.jpg','.jpeg','.png','.webp']);
const files = fs.readdirSync(input).filter(f=>exts.has(path.extname(f).toLowerCase()));
if (!files.length) throw new Error('no_images');

const valid=[];
for (const f of files) {
  const src=path.join(input,f);
  const st=fs.statSync(src);
  if (st.size < 20000) continue;
  try {
    const meta=await sharp(src).metadata();
    const long=Math.max(meta.width||0,meta.height||0);
    if (long < 900) continue;
    const outName=path.basename(f,path.extname(f)).replace(/[^a-z0-9_-]/gi,'-').toLowerCase()+'.webp';
    const out=path.join(optimized,outName);
    await sharp(src).rotate().resize({width:1800,height:1800,fit:'inside',withoutEnlargement:true}).webp({quality:84,effort:5}).toFile(out);
    const om=await sharp(out).metadata();
    valid.push({source:f,file:out,name:outName,width:om.width||0,height:om.height||0,bytes:fs.statSync(out).size});
  } catch {}
}
if (valid.length < 3) throw new Error('fewer_than_3_valid_images');

let coverIndex=-1;
if (coverNeedle) coverIndex=valid.findIndex(x=>x.source.toLowerCase().includes(coverNeedle)||x.name.includes(coverNeedle));
if (coverIndex<0) {
  const ranked=[...valid].map((x,i)=>({i,score:(x.width>=x.height?1000000:0)+x.width*x.height})).sort((a,b)=>b.score-a.score);
  coverIndex=ranked[0].i;
}
const ordered=[valid[coverIndex],...valid.filter((_,i)=>i!==coverIndex)];

const client=new Client({connectionString:process.env.DATABASE_URL});
await client.connect();
const snap=(await client.query('SELECT id,nombre,fotos,actualizada FROM vl_propiedades WHERE id = ANY($1::int[]) ORDER BY id',[ids])).rows;
if (snap.length !== ids.length) throw new Error(`property_id_mismatch:${snap.length}/${ids.length}`);
const ts=new Date().toISOString().replace(/[:.]/g,'-');
const backupDir=`/root/backups/vliving-media/${ts}`;
fs.mkdirSync(backupDir,{recursive:true});
fs.writeFileSync(path.join(backupDir,'before.json'),JSON.stringify(snap,null,2),{mode:0o600});

const uploaded=[];
for (let i=0;i<ordered.length;i++) {
  const x=ordered[i];
  const buf=fs.readFileSync(x.file);
  const digest=crypto.createHash('sha256').update(buf).digest('hex').slice(0,12);
  const r=await guardarPublico(`propiedades/${slug}/${String(i+1).padStart(2,'0')}-${digest}.webp`,buf,'image/webp');
  uploaded.push({url:r.url,source:x.source,width:x.width,height:x.height,bytes:x.bytes});
}
const urls=uploaded.map(x=>x.url);
await client.query('BEGIN');
try {
  await client.query('UPDATE vl_propiedades SET fotos=$1::jsonb, actualizada=now() WHERE id = ANY($2::int[])',[JSON.stringify(urls),ids]);
  await client.query(`UPDATE vl_unidades u SET fotos=$1::jsonb, actualizado=now() WHERE EXISTS (SELECT 1 FROM vl_fractional f WHERE f.unidad_id=u.id AND f.propiedad_id = ANY($2::text[]))`,[JSON.stringify(urls),ids.map(String)]);
  await client.query('COMMIT');
} catch(e) { await client.query('ROLLBACK'); throw e; }
await client.end();
fs.writeFileSync(path.join(backupDir,'result.json'),JSON.stringify({slug,ids,cover:uploaded[0],count:uploaded.length,uploaded},null,2),{mode:0o600});
console.log(JSON.stringify({ok:true,slug,property_ids:ids,downloaded:files.length,valid:valid.length,uploaded:uploaded.length,cover_source:uploaded[0].source,cover_url:uploaded[0].url,backup:backupDir}));