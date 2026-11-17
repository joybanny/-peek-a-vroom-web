from pathlib import Path
import struct,hashlib,json,sys
root=Path(__file__).resolve().parent
base=Path(sys.argv[1]);output=Path(sys.argv[2]);patch=root/'patch'
b=base.read_bytes();assert hashlib.sha256(b).hexdigest()=='a0c3d65702f10e7f44df7dabf88f9f883e485a9c80a36d96c0a47c4d65951ca4'
baseoff=struct.unpack_from('<Q',b,24)[0];pos=struct.unpack_from('<Q',b,32)[0];n=struct.unpack_from('<I',b,pos)[0];pos+=4;entries={}
for _ in range(n):
 l=struct.unpack_from('<I',b,pos)[0];pos+=4;p=b[pos:pos+l].rstrip(b'\0').decode();pos+=l
 off,size=struct.unpack_from('<QQ',b,pos);pos+=16;md=b[pos:pos+16];pos+=16;flags=struct.unpack_from('<I',b,pos)[0];pos+=4
 raw=b[baseoff+off:baseoff+off+size];assert flags==0 and hashlib.md5(raw).digest()==md,p;entries[p]=raw
changed=[]
for p in sorted(patch.rglob('*')):
 if not p.is_file():continue
 rel=p.relative_to(patch).as_posix()
 if not (rel.startswith('scripts/') and rel.endswith('.gd') or rel.startswith('assets/') and not rel.endswith('.uid') or rel.startswith('.godot/imported/') and rel.endswith('.ctex')):continue
 if rel.endswith('.gd'):
  entries.pop(rel+'.remap',None);entries.pop(rel[:-3]+'.gdc',None)
 entries[rel]=p.read_bytes();changed.append(rel)
header=bytearray(b[:112]);buf=bytearray(header);table=[]
for p,raw in sorted(entries.items()):
 while len(buf)%16:buf.append(0)
 table.append((p,len(buf)-112,len(raw),hashlib.md5(raw).digest()));buf.extend(raw)
while len(buf)%16:buf.append(0)
directory=len(buf);buf.extend(struct.pack('<I',len(table)))
for p,off,size,md in table:
 name=p.encode();name+=b'\0'*((-len(name))%4);buf.extend(struct.pack('<I',len(name))+name+struct.pack('<QQ',off,size)+md+struct.pack('<I',0))
struct.pack_into('<Q',buf,24,112);struct.pack_into('<Q',buf,32,directory)
output.write_bytes(buf)
print(json.dumps({'bytes':len(buf),'sha256':hashlib.sha256(buf).hexdigest(),'entries':len(table),'changed':changed},indent=2))
