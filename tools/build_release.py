from pathlib import Path
import zipfile
root = Path(__file__).resolve().parents[1]
out = root / 'dist'
out.mkdir(exist_ok=True)
target = out / 'RE4-Map-Teleport-v0.2.0-mod-only.zip'
if target.exists():
    raise SystemExit('Archive exists; move it before rebuilding: ' + str(target))
files = [p for p in root.rglob('*') if p.is_file() and ('reframework' in p.relative_to(root).parts or 'third_party' in p.relative_to(root).parts)]
files += [root / n for n in ['README.md', 'README.en.md', 'LICENSE', 'THIRD_PARTY_NOTICES.md', 'CHANGELOG.md']]
with zipfile.ZipFile(target, 'w', zipfile.ZIP_DEFLATED) as z:
    for p in sorted(files):
        z.write(p, p.relative_to(root).as_posix())
print(target)
