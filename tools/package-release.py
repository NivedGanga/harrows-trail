#!/usr/bin/env python3
"""Package only version-controlled runtime files and release documentation; no saves or vendor assets."""
import argparse, hashlib, json, pathlib, subprocess, zipfile
ROOT=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--output',type=pathlib.Path,default=ROOT/'.local/releases/harrows-trail-rc1.zip');p.add_argument('--verify',type=pathlib.Path);args=p.parse_args()
def digest(data):return hashlib.sha256(data).hexdigest()
if args.verify:
 with zipfile.ZipFile(args.verify)as z:
  names=z.namelist();assert len(names)==len(set(names)) and all(n.startswith('harrows_trail/') and '..'not in pathlib.PurePosixPath(n).parts for n in names)
  m=json.loads(z.read('harrows_trail/MANIFEST.json'))
  assert set(names)=={'harrows_trail/'+n for n in m['files']}|{'harrows_trail/MANIFEST.json'}
  for name,sha in m['files'].items():assert digest(z.read('harrows_trail/'+name))==sha,name
 print('PASS package hashes and safe paths:',args.verify.resolve());raise SystemExit
paths=subprocess.check_output(['git','ls-files','-z','--','mod/harrows_trail'],cwd=ROOT).decode().split('\0')
files={}
for name in filter(None,paths):
 path=ROOT/name;assert path.is_file() and not path.is_symlink(),name
 files[str(path.relative_to(ROOT/'mod/harrows_trail'))]=path.read_bytes()
assert 'release.lua'in files,'Stage the intended release module before packaging.'
for name,source in {'INSTALL.md':'docs/release-candidate.md','ASSETS.md':'docs/assets.md','RELEASE_NOTES.md':'docs/release-notes.md'}.items():files[name]=(ROOT/source).read_bytes()
revision=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip()
runtime={name:digest(data)for name,data in sorted(files.items())if name not in ('INSTALL.md','ASSETS.md','RELEASE_NOTES.md')}
m={'release':'RC1','engine':'Luanti 5.17.0','game':'Mineclonia 0.124.1','seed':'1730940739604968791','source_commit':revision,'runtime_sha256':digest(json.dumps(runtime,sort_keys=True).encode()),'files':{name:digest(data)for name,data in sorted(files.items())}}
files['MANIFEST.json']=(json.dumps(m,sort_keys=True,indent=2)+'\n').encode()
args.output.parent.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(args.output,'w',compression=zipfile.ZIP_DEFLATED,compresslevel=9)as z:
 for name,data in sorted(files.items()):
  info=zipfile.ZipInfo('harrows_trail/'+name,(2026,11,21,0,0,0));info.create_system=3;info.external_attr=0o100644<<16;info.compress_type=zipfile.ZIP_DEFLATED;z.writestr(info,data,compresslevel=9)
print(args.output.resolve());print('SHA256',digest(args.output.read_bytes()));print('Runtime SHA256',m['runtime_sha256'])
