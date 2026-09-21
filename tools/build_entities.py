"""Build offline bilingual names from the same pinned Classic DB as ForeverLearner.

Usage: python tools/build_entities.py --sources path/to/source-directory
Directory must contain classic-base.sql.gz, chinese-creatures.sql, chinese-items.sql.
All inputs are verified against the pinned repository's Git blob hashes.
SQL is parsed as data and is never executed.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
from sql_read import records, lua

REV = '22b51464f1625f6ef6275771de1f5466c6f5d19e'
ROOT = Path(__file__).resolve().parents[1]

def build(sources):
    manifest = json.loads((ROOT / 'tools/source-blobs.json').read_text())
    content = {}
    for filename, info in manifest.items():
        raw = (sources / filename).read_bytes()
        actual = hashlib.sha1(b'blob ' + str(len(raw)).encode() + b'\0' + raw).hexdigest()
        if actual != info['sha']: raise ValueError('Source hash mismatch: ' + filename)
        content[filename] = raw
    base = gzip.decompress(content['classic-base.sql.gz']).decode('utf-8-sig')
    datasets, counts = {}, {}
    for kind, table, filename, locale_table in [
        ('npc', 'creature_template', 'chinese-creatures.sql', 'locales_creature'),
        ('item', 'item_template', 'chinese-items.sql', 'locales_item'),
    ]:
        english = records(base, table)
        chinese = records(content[filename].decode('utf-8-sig'), locale_table)
        result = {}
        for id, row in sorted(english.items()):
            cn = chinese.get(id, {})
            enname = row.get('Name') or row.get('name') or ''
            cnname = cn.get('name_loc4') or cn.get('Name_loc4') or ''
            if cnname == 'NULL': cnname = ''
            if enname == 'NULL': enname = ''
            if enname or cnname: result[id] = [cnname, enname]
        datasets[kind] = result
        counts[kind] = {'records':len(result),'bilingual':sum(bool(cn and en) for cn,en in result.values())}
    output = ROOT / 'WorldLearner/Data/Entities.lua'
    output.write_text('-- Derived from CMaNGOS Classic DB; see DATA-SOURCES.md.\nlocal _, W = ...\nW.Entities = {\n' +
        ''.join(kind+'={\n'+''.join('['+str(id)+']='+lua(row)+',\n' for id,row in data.items())+'},\n'
                for kind,data in datasets.items())+'}\n',encoding='utf-8')
    report = {'repository':'https://github.com/cmangos/classic-db','revision':REV,
        'scope':'Base Classic 1.12 snapshot, not subsequent updates or Forever custom data',
        'counts':counts,'sources':manifest}
    (ROOT/'WorldLearner/Data/ENTITY-SOURCE.json').write_text(json.dumps(report,indent=2),encoding='utf-8')
    print(json.dumps(counts))

if __name__=='__main__':
    parser=argparse.ArgumentParser(); parser.add_argument('--sources',type=Path,required=True)
    build(parser.parse_args().sources)
