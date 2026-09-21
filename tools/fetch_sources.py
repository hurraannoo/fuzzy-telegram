"""Download and verify the public, pinned source inputs for build_entities.py."""
import argparse, hashlib, json, urllib.request
from pathlib import Path

ROOT=Path(__file__).resolve().parents[1]
REV='22b51464f1625f6ef6275771de1f5466c6f5d19e'

if __name__=='__main__':
    p=argparse.ArgumentParser(); p.add_argument('--output',type=Path,required=True)
    args=p.parse_args(); args.output.mkdir(parents=True,exist_ok=True)
    manifest=json.loads((ROOT/'tools/source-blobs.json').read_text())
    for filename,info in manifest.items():
        url=f'https://raw.githubusercontent.com/cmangos/classic-db/{REV}/{info["path"]}'
        raw=urllib.request.urlopen(url,timeout=120).read()
        digest=hashlib.sha1(b'blob '+str(len(raw)).encode()+b'\0'+raw).hexdigest()
        if digest!=info['sha']: raise ValueError('Source hash mismatch: '+filename)
        (args.output/filename).write_bytes(raw)
        print('Verified',filename)
