"""SQL text parser adapted from ForeverLearner (MIT)."""
import re, json

token = re.compile(r"\s*(?:'((?:[^'\\]|\\.|'')*)'|(-?\d+(?:\.\d+)?)|(NULL)|([(),;]))", re.S)
escapes = {'0':'\0','n':'\n','r':'\r','t':'\t','b':'\b','Z':'\x1a'}
def tuples(values):
    pos, row, expect = 0, None, '('
    while pos < len(values):
        m=token.match(values,pos)
        if not m:
            assert not values[pos:].strip(), repr(values[pos:pos+80]); break
        pos=m.end()
        s,n,null,mark=m.groups()
        if mark=='(':
            assert row is None; row=[]
        elif mark==')':
            assert row is not None; yield row; row=None
        elif mark in (',',';'): pass
        else:
            assert row is not None
            if s is not None: value=re.sub(r'\\(.)',lambda x:escapes.get(x[1],x[1]),s).replace("''", "'")
            elif n is not None: value=float(n) if '.' in n else int(n)
            else: value=None
            row.append(value)
    assert row is None

def records(sql, table):
    schema=re.search(r'CREATE TABLE `'+table+r'` \((.*?)\) ENGINE',sql,re.S)
    columns=re.findall(r'^\s*`([^`]+)`',schema[1],re.M) if schema else None
    rows={}
    for line in sql.splitlines():
        if not line.startswith('INSERT INTO `'+table+'`'): continue
        prefix,values=line.split(' VALUES ',1)
        explicit=re.findall(r'`([^`]+)`',prefix)[1:]
        cols=explicit or columns
        assert cols
        for row in tuples(values):
            assert len(row)==len(cols),(table,len(row),len(cols))
            assert row[0] not in rows,(table,row[0])
            rows[row[0]]=dict(zip(cols,row))
    assert rows,table
    return rows

def lua(value):
    # JSON strings without Unicode escapes are Lua 5.1 compatible for these texts.
    if isinstance(value,str): return json.dumps(value,ensure_ascii=False).replace('\\u0000','').replace('\\/','/')
    if isinstance(value,dict): return '{'+','.join('['+lua(k)+']='+lua(v) for k,v in value.items())+'}'
    if isinstance(value,list): return '{'+','.join(lua(v) for v in value)+'}'
    if value is None: return 'nil'
    return str(value)

