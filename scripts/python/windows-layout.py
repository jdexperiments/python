import sys
import shutil
from pathlib import Path

# Define paths
src_dir = Path( sys.argv[1] )
dest_dir = Path( sys.argv[2] )

bin_dir = dest_dir / "bin"
lib_dir = dest_dir / "lib"
include_dir = dest_dir / "include"

# 1. Create Unix directories
for d in [bin_dir, lib_dir, include_dir]:
    d.mkdir(parents=True, exist_ok=True)

# 2. Move Binaries (.exe, .dll, .pyd) to bin/
binary_exts = {".exe", ".dll", ".pyd"}
for item in src_dir.iterdir():
    if item.is_file() and item.suffix.lower() in binary_exts:
        shutil.copy(item, bin_dir / item.name)

# 3. Move standard library to lib/
if (src_dir / "Lib").exists():
    shutil.copytree(src_dir / "Lib", lib_dir / "python", dirs_exist_ok=True)

# 4. Move Headers to include/
if (src_dir / "include").exists():
    shutil.copytree(src_dir / "include", include_dir / "python", dirs_exist_ok=True)

# 5. CRITICAL: Create pythonXX._pth inside the bin/ folder
# This tells python.exe inside bin/ exactly where to find its DLLs and standard library.
# We determine the exact DLL name from the copied files
dll_name = next(f.name for f in bin_dir.iterdir() if f.name.startswith("python") and f.suffix == ".dll" and "python3" in f.name)

pth_content = f"""\
.
..\\lib\\python
{dll_name}
import site
"""

# Write the path file right next to python.exe
# Format matches your specific python version, e.g., python314._pth
version_suffix = dll_name.replace("python", "").replace(".dll", "")
with open(bin_dir / f"python{version_suffix}._pth", "w", encoding="utf-8") as f:
    f.write(pth_content)

print( "Unix-like layout generated successfully at ", dest_dir )
