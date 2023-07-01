#! /usr/bin/env python

'''
Simple Python script to download OpenVPN configs from VPN Gate.
'''

import base64
import csv
from urllib import request

SERVERS_CSV_URL='http://www.vpngate.net/api/iphone'
HEADERS_COUNT=2

class OpenVPNConfig:
    '''Class to represent an OpenVPN config from VPN Gate.'''

    def __init__(self, raw_data) -> None:
        self.country_code = raw_data[6]
        self.country_name = raw_data[5]
        self.speed = int(raw_data[4]) / 1000000
        self.sessions = int(raw_data[7])
        self.ping = raw_data[3]
        self.score = int(raw_data[2])
        self.base64_config = raw_data[14]

    def avg_speed(self) -> float:
        '''Calculate the average speed of the VPN server.'''
        return self.speed / self.sessions if self.sessions else self.speed

    def export(self) -> None:
        '''Export the OpenVPN config to a file.'''
        filename = f'VPNGate_{self.country_code}.ovpn'

        with open(filename, 'w', encoding='utf-8') as openvpn_config_file:
            openvpn_config_file.write(base64.b64decode(self.base64_config).decode('utf-8'))

    def __lt__(self, other) -> bool:
        return self.score < other.score

    def __str__(self) -> str:
        country_code = f'[{self.country_code}]'
        speed = f'{self.speed:.2f}Mbps'.rjust(11)
        sessions = f'{self.sessions}'.rjust(8)
        ping = f'{self.ping}ms'.rjust(6)
        avg_speed = f'{self.avg_speed():.3f}Mbps'.rjust(11)
        score = f'{self.score:,}'.rjust(9)

        return (f' {country_code} | {speed} | {avg_speed} | '
                f'{sessions} | {ping} | {score} | {self.country_name}')

def get_vpngate_configs() -> dict:
    '''Get the OpenVPN configs from VPN Gate.'''
    openvpn_configs = {}

    with request.urlopen(SERVERS_CSV_URL) as response:
        csv_reader = csv.reader(response.read().decode('utf-8').splitlines())

        for row in csv_reader:
            if csv_reader.line_num <= HEADERS_COUNT or len(row) < 15:
                continue

            openvpn_config = OpenVPNConfig(row)
            current_config = openvpn_configs.get(openvpn_config.country_code, None)

            if current_config is None or current_config < openvpn_config:
                openvpn_configs[openvpn_config.country_code] = openvpn_config

    return openvpn_configs

def read_user_vpn_choice(choices) -> str:
    '''Read the user's choice of VPN country.'''
    print('Visit https://www.vpngate.net/en to see the full list\n')
    print(' CODE |    SPEED    |  AVG SPEED  | SESSIONS |  PING  |   SCORE   | COUNTRY')
    print('------+-------------+-------------+----------+--------+-----------+---------')

    for config in sorted(choices.values(), reverse=True):
        print(config)

    return input('\nCountry code: ').upper()

if __name__ == '__main__':
    vpngate_configs = get_vpngate_configs()
    choice = read_user_vpn_choice(vpngate_configs)

    if choice in vpngate_configs:
        vpngate_configs[choice].export()
        print(f'\nOpenVPN config for {choice} successfully exported.')
    else:
        print(f'\nCountry code {choice} not found.')
