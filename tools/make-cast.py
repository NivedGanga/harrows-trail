#!/usr/bin/env python3
"""Original 64x32 humanoid UV art; standard library only, no source images."""
import pathlib, struct, zlib
ROOT = pathlib.Path(__file__).resolve().parents[1] / 'mod/harrows_trail/textures'
# coat, shirt, hair, skin, accent. Each silhouette shares the pinned native mesh.
CAST = {
 'eli':('695843','e8d3aa','513422','c68f65','426471'),
 'eli_duster':('704423','d5be8d','513422','c68f65','426471'),
 'ada':('253b59','d4c9a9','34291e','b87954','e1b342'),
 'jonah':('733344','eee1b9','412619','d49b72','e7dfca'),
 'dutch':('a87b37','456340','592d19','bb7951','c9bb8d'),
 'ruth':('ad583d','317478','211b1a','9e6545','e6d8b4'),
 'amos':('325e66','bba981','d8d2bd','9f7453','aa4034'),
 'jesse':('b5ad95','353b39','3d2c20','c68a5c','a94435'),
 'nora':('638259','e1ce9c','8e4526','dbaa80','d39b49'),
 'crane':('33363a','e1d8c1','443a30','b3886b','693a3b'),
 'mercer':('302d2a','54504a','24211c','a16d4f','9c3633'),
}
def chunk(kind,data):
 return struct.pack('>I',len(data))+kind+data+struct.pack('>I',zlib.crc32(kind+data)&0xffffffff)
for name,(coat,shirt,hair,skin,accent) in CAST.items():
 p=[[(0,0,0,0) for _ in range(64)] for _ in range(32)]
 def rect(x,y,w,h,c):
  color=tuple(bytes.fromhex(c))+(255,)
  for j in range(y,y+h):
   for i in range(x,x+w): p[j][i]=color
 # Head and hair in all directions; independent original pixel construction.
 rect(0,0,32,16,hair);rect(8,8,8,8,skin);rect(8,8,8,2,hair)
 rect(9,11,2,1,'292621');rect(13,11,2,1,'292621');rect(11,14,2,1,'774e38')
 # Boots/legs, sleeves, coat back, front waistcoat and scarf/badge.
 rect(0,16,16,16,'403b35');rect(0,28,16,4,'30261d')
 rect(16,16,24,16,coat);rect(20,20,8,9,shirt);rect(23,20,2,6,accent)
 rect(40,16,16,16,coat);rect(40,29,16,3,skin)
 rect(20,29,8,3,coat);rect(20,27,8,1,'382a20');rect(23,27,2,1,accent)
 # Faded stitching, waistcoat buttons and hat overlay distinguish outfits at scale.
 for y in (23,26): rect(24,y,1,1,'b6a385')
 if name in ('eli','eli_duster','ada','dutch','crane','mercer'):
  rect(40,8,8,2,coat);rect(32,10,32,1,coat)
 if name=='ada': rect(20,23,2,2,accent)
 if name in ('jonah','ruth'): rect(21,25,6,7,accent)
 if name=='ruth': rect(8,11,8,1,'2b2925')
 if name=='amos': rect(8,8,8,2,accent);rect(9,14,6,2,hair)
 if name=='jesse':
  for y in (21,24,27): rect(20,y,8,1,'353b39')
 if name in ('crane','mercer','eli','eli_duster','dutch'):
  rect(8,8,8,1,coat);rect(0,7,32,1,accent)
 if name=='nora': rect(0,0,8,8,accent)
 if name=='eli_duster': rect(20,25,2,7,coat);rect(26,25,2,7,coat)
 raw=b''.join(b'\0'+bytes(v for color in row for v in color) for row in p)
 png=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',64,32,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(raw,9))+chunk(b'IEND',b'')
 (ROOT/f'harrows_{name}.png').write_bytes(png)
