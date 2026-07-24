import urllib.request
import urllib.error
import zipfile
import os

os.makedirs('tools', exist_ok=True)

opener = urllib.request.build_opener()
opener.addheaders = [('User-agent', 'Mozilla/5.0')]
urllib.request.install_opener(opener)

print('Downloading JRE...')
try:
    urllib.request.urlretrieve('https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jre/hotspot/normal/eclipse', 'tools/jre.zip')
except urllib.error.HTTPError as e:
    print(f"Failed to download JRE: {e}")

print('Extracting JRE...')
try:
    with zipfile.ZipFile('tools/jre.zip', 'r') as zip_ref:
        zip_ref.extractall('tools/jre')
except Exception as e:
    print(f"Failed to extract JRE: {e}")

print('Downloading FFDec...')
try:
    urllib.request.urlretrieve('https://github.com/jindrapetrik/jpexs-decompiler/releases/download/version14.4.0/ffdec_14.4.0.zip', 'tools/ffdec.zip')
except urllib.error.HTTPError as e:
    print(f"Failed to download FFDec: {e}")

print('Extracting FFDec...')
try:
    with zipfile.ZipFile('tools/ffdec.zip', 'r') as zip_ref:
        zip_ref.extractall('tools/ffdec')
except Exception as e:
    print(f"Failed to extract FFDec: {e}")

print('Done!')
