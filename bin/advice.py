#! /usr/bin/env python
# Simple advice client for https://api.adviceslip.com

import requests

API_URL = 'https://api.adviceslip.com/advice'

response = requests.get(API_URL).json()

if ('slip' in response):
    id = response['slip']['id']
    advice = response['slip']['advice']

    print(f'[{id}] {advice}')
else:
    print(f'No response from {API_URL}')
