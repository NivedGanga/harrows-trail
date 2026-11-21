#!/usr/bin/env python3
"""Original CC0 pixel materials and synthesized audio; no input artwork or recordings."""
import math, pathlib, random, struct, subprocess, tempfile, wave, zlib
ROOT=pathlib.Path(__file__).resolve().parents[1]/'mod/harrows_trail'
def png(name,pixels):
 def chunk(k,d):return struct.pack('>I',len(d))+k+d+struct.pack('>I',zlib.crc32(k+d)&0xffffffff)
 h=len(pixels);w=len(pixels[0]);data=b''.join(b'\0'+bytes(v for p in row for v in p)for row in pixels)
 (ROOT/'textures'/f'harrows_{name}.png').write_bytes(b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',w,h,8,6,0,0,0))+chunk(b'IDAT',zlib.compress(data,9))+chunk(b'IEND',b''))
rng=random.Random(710)
for name,base in {'wood':(121,92,59),'dark_wood':(83,65,45),'rust':(112,70,44),'cloth':(183,159,111)}.items():
 p=[]
 for y in range(16):
  row=[]
  for x in range(16):
   n=rng.randrange(-10,11)
   if name.endswith('wood') and (y%5==0 or x==(y//5*7)%16):n-=20
   if name=='rust' and rng.random()<.2:n+=26
   if name=='cloth' and (x+y)%2:n+=6
   row.append(tuple(max(0,min(255,c+n))for c in base)+(255,))
  p.append(row)
 png(name,p)
for name,color in {'dust':(191,161,104,85),'rain':(139,168,179,130),'fog':(206,211,189,30)}.items():
 p=[[(0,0,0,0)for x in range(16)]for y in range(16)]
 for y in range(16):
  for x in range(16):
   if name=='rain' and x==8 or name!='rain' and ((x-8)**2+(y-8)**2)<rng.randrange(12,45):p[y][x]=color
 png(name,p)
(ROOT/'sounds').mkdir(exist_ok=True)
RATE=22050;DURATION=8
# Composed motif: original six-note phrase, no transcription or samples.
notes=[220,261.6256,329.6276,293.6648,246.9417,220,164.8138,0]
with tempfile.TemporaryDirectory(prefix='harrows-audio-')as tmp:
 for name in ('wind','crickets','whistle','saloon','swamp','rail'):
  values=[];noise=0.0;rand=random.Random(name)
  for i in range(RATE*DURATION):
   t=i/RATE;noise=.98*noise+.02*rand.uniform(-1,1)
   if name=='wind':v=noise*(.4+.18*math.sin(2*math.pi*t/8))
   elif name=='crickets':v=.08*math.sin(2*math.pi*3400*t)*max(0,math.sin(2*math.pi*3*t))**8
   elif name=='whistle':v=.1*(math.sin(2*math.pi*440*t)+.4*math.sin(2*math.pi*550*t))*math.sin(math.pi*min(1,t/3)) if t<3 else 0
   elif name=='saloon':
    f=notes[int(t)];u=t%1;v=.13*math.exp(-4*u)*(math.sin(2*math.pi*f*t)+.25*math.sin(4*math.pi*f*t))if f else 0
   elif name=='swamp':v=.3*noise+.06*math.sin(2*math.pi*(130+10*math.sin(t*9))*t)*max(0,math.sin(t*4))**6
   else:v=.3*noise+.03*math.sin(2*math.pi*180*t)*math.exp(-12*(t%2))
   # Fade at both boundaries: no sample or loop discontinuity.
   v*=min(1,t/.1,(DURATION-t)/.15)
   values.append(struct.pack('<h',max(-32767,min(32767,int(v*32767)))))
  wav=pathlib.Path(tmp)/f'{name}.wav'
  with wave.open(str(wav),'wb')as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(RATE);w.writeframes(b''.join(values))
  subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-i',str(wav),'-c:a','vorbis','-strict','-2','-ac','2','-q:a','3',str(ROOT/'sounds'/f'harrows_{name}.ogg')],check=True)
