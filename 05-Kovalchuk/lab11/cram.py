#!/usr/bin/env python
import argparse
import base64
import hashlib
import hmac

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('-u', '--user', dest='user', required=True, type=str,
                    help='Username')
    ap.add_argument('-p', '--password', dest='password', required=True,
                    type=str, help='Pass')
    ap.add_argument('-t', '--ticket', dest='ticket', type=str, required=True,
                    help='Ticket given by server')
    args = ap.parse_args()

    ticket = base64.b64decode(args.ticket)
    hasher = hmac.new(key=args.password.encode(), digestmod=hashlib.md5)
    hasher.update(bytes(ticket))
    hashed = hasher.hexdigest()
    result = '%s %s' % (args.user, hashed)
    print(base64.b64encode(result.encode()).decode())

if __name__ == '__main__':
    main()
