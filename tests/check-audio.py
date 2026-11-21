#!/usr/bin/env python3
"""Validate actual Ogg/Vorbis decode, duration and levels, without claiming listening QA."""
import array,json,math,pathlib,subprocess
root=pathlib.Path(__file__).resolve().parents[1]/'mod/harrows_trail/sounds'
for name in ('wind','crickets','whistle','saloon','swamp','rail'):
 p=root/f'harrows_{name}.ogg'
 data=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_streams','-of','json',str(p)]))['streams'][0]
 assert data['codec_name']=='vorbis' and 7.95<float(data['duration'])<8.05 and data['channels']==2
 samples=array.array('h',subprocess.check_output(['ffmpeg','-v','error','-i',str(p),'-f','s16le','-ac','1','-ar','22050','-']))
 peak=max(abs(x)for x in samples);rms=math.sqrt(sum(x*x for x in samples)/len(samples))/32768
 assert peak<32760 and .001<rms<.3,(name,peak,rms)
 print(f'PASS audio {name}: Vorbis, {data["duration"]}s, peak={peak}, rms={rms:.4f}; listening unverified')
