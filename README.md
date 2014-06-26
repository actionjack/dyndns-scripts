DNS Switcher
============

To use create .config.yaml file in home dir e.g. vi ~/.config.yaml

Add authentication details to file i.e.:

```sh
  customer_name: $CUSTOMER-ACCOUNT-ID
  user_name: $USERNAME
  password: $PASSWORD
  zone: $DNS-ZONE
  fqdn: $FULLY-QUALIFIED-DOMAIN-NAME
```

Installation
--------------

Usage:
```sh
dyndns-switcher.rb $Primary_IP_Address  $Failover_IP_Address
```

