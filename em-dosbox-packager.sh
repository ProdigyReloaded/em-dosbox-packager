#!/bin/bash
#
# Copyright 2026, Phillip Heller
#
# This file is part of Prodigy Reloaded.
#
# Prodigy Reloaded is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# Prodigy Reloaded is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even
# the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License along with Prodigy Reloaded. If not,
# see <https://www.gnu.org/licenses/>.

IMAGE_NAME="em-dosbox-packager"
PLATFORM="linux/amd64"

# Check if the image exists
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Image '$IMAGE_NAME' not found. Building..."
    docker build --platform "$PLATFORM" -t "$IMAGE_NAME" .
    if [ $? -ne 0 ]; then
        echo "Build failed!"
        exit 1
    fi
    echo "Build complete!"
fi

# Check if we have the required volume mount argument
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 /path/to/dosbox/assets FILE_TO_RUN"
    echo "   or: $0 /path/to/dosbox/assets OUTPUT_NAME FILE_TO_RUN"
    exit 1
fi

# Extract the directory path and remaining arguments
DOSBOX_DIR="$1"
shift  # Remove first argument, pass the rest to the container

# Verify the directory exists
if [ ! -d "$DOSBOX_DIR" ]; then
    echo "Error: Directory '$DOSBOX_DIR' does not exist"
    exit 1
fi

# Run the container
docker run --platform "$PLATFORM" -it --rm \
    -v "$DOSBOX_DIR:/dosbox" \
    "$IMAGE_NAME" "$@"
