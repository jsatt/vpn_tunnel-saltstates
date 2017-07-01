{% set openvpn = pillar.get('openvpn', {}) -%}
#!/usr/bin/env python3

import sys

import boto3

HOSTED_ZONE_ID = "{{openvpn.get('dynamic_dns', {}).get('record_set_id', '')}}"
TTL = {{openvpn.get('dynamic_dns', {}).get('ttl', 300)}}


def get_client():
    return boto3.client('route53')


def get_fqdn(client, name):
    zone_name = client.get_hosted_zone(Id=HOSTED_ZONE_ID)['HostedZone']['Name']
    return '{}.{}'.format(name, zone_name)


def update_address(name, target):
    r53 = get_client()
    r53.change_resource_record_sets(
        HostedZoneId=HOSTED_ZONE_ID,
        ChangeBatch={
            'Changes': [{
                'Action': 'UPSERT',
                'ResourceRecordSet': {
                    'Name': get_fqdn(r53, name),
                    'Type': 'A',
                    'TTL': TTL,
                    'ResourceRecords': [{
                        'Value': target
                    }]
                }
            }]
        }
    )


def delete_address(name):
    r53 = get_client()
    fqdn = get_fqdn(r53, name)
    record_sets = r53.list_resource_record_sets(HostedZoneId=HOSTED_ZONE_ID)
    changes = [{'Action': 'DELETE', 'ResourceRecordSet': record}
               for record in record_sets['ResourceRecordSets']
               if record['Name'] == fqdn]
    r53.change_resource_record_sets(
        HostedZoneId=HOSTED_ZONE_ID,
        ChangeBatch={'Changes': changes}
    )


def usage():
    print('USAGE: {} (add|update|delete) ADDRESS CN'.format(sys.argv[0]))


if __name__ == '__main__':
    if len(sys.argv) != 4:
        usage()
        sys.exit(1)

    _, action, address, cn = sys.argv

    if action in ['add', 'update']:
        update_address(cn, address)
    elif action == 'delete':
        delete_address(cn)
    else:
        usage()
        sys.exit(2)

