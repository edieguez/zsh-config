#! /bin/bash
# Pack the current directory into a single runnable Python zipapp at ../<name>
set -e

if [ -z "$1" ]; then
    echo "Usage: $(basename "$0") <output-name>"
    exit 1
fi

zip -r "../$1.zip" * -x '*__pycache__*' '*.pyc'
echo "#! /usr/bin/env python3" | cat - "../$1.zip" > "../$1"
rm "../$1.zip"
chmod +x "../$1"
