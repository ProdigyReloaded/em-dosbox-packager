#!/bin/bash

cd /src/em-dosbox/src

if [ "$#" -lt 1 ]; then
    echo "Usage: docker run -v /path/to/dosbox/assets:/dosbox em-dosbox-packager FILE_TO_RUN"
    echo "   or: docker run -v /path/to/dosbox/assets:/dosbox em-dosbox-packager OUTPUT_NAME FILE_TO_RUN"
    exit 1
fi

# Determine if we have 1 or 2 arguments
if [ "$#" -eq 1 ]; then
    # Single argument - use it as both output name and file to run
    OUTPUT_NAME="${1%.*}"  # Remove extension for output name
    FILE_TO_RUN="$1"
else
    # Two arguments - first is output name, second is file to run
    OUTPUT_NAME="$1"
    FILE_TO_RUN="$2"
fi

# Create a temporary directory for packaging (excluding dosbox.js and dosbox.wasm)
TEMP_DIR="/tmp/dosbox_package"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# Copy only the DOS application files (excluding emscripten artifacts)
cd /dosbox
for file in *; do
    # Skip the emscripten output files and previously generated packages
    if [[ "$file" != "dosbox.js" && "$file" != "dosbox.wasm" && \
          "$file" != *.html && "$file" != *.data ]]; then
        cp -r "$file" "$TEMP_DIR/"
    fi
done

cd /src/em-dosbox/src

# Run the packager on the clean directory
python ./packager.py "$OUTPUT_NAME" "$TEMP_DIR" "$FILE_TO_RUN"

# Move the output files to the mounted volume
mv "${OUTPUT_NAME}.data" "${OUTPUT_NAME}.html" /dosbox/ 2>/dev/null || true

# Extract the inline Module data-loader from the generated html as loader.js
# for pages (like the portal /start page) that supply their own html. The
# loader block is the only flush-left script tag in the generated page.
awk '/^<script type="text\/javascript">$/{f=1;next} /^<\/script>$/{f=0} f' \
  "/dosbox/${OUTPUT_NAME}.html" > /dosbox/loader.js || true

# Copy the emscripten runtime files (these should be referenced, not packaged)
cp dosbox.js dosbox.wasm /dosbox/ 2>/dev/null || true

# Clean up
rm -rf "$TEMP_DIR"

echo "Packaging complete. Files created in /dosbox:"
echo "  ${OUTPUT_NAME}.html - Main HTML file"
echo "  ${OUTPUT_NAME}.data - Packaged DOS application data"
echo "  loader.js - Module data-loader extracted from the html"
echo "  dosbox.js - Emscripten JavaScript runtime"
echo "  dosbox.wasm - Emscripten WebAssembly runtime"
ls -lh /dosbox/"${OUTPUT_NAME}".* /dosbox/loader.js /dosbox/dosbox.js /dosbox/dosbox.wasm 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
