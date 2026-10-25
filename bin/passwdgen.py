#! /usr/bin/env python3
"""Generate a random password of letters and digits (default length 16)."""

import secrets
import string
from sys import argv

length = int(argv[1]) if len(argv) > 1 else 16
alphabet = string.ascii_letters + string.digits

print(''.join(secrets.choice(alphabet) for _ in range(length)))
