# == Definition: network::if::static
#
# Creates a normal interface with static IP address.
#
# === Parameters:
#
#   $ensure         - required - up|down
#   $ifname         - optional - default $title 
#   $device         - required - device name
#   $ipaddress      - required
#   $netmask        - required
#   $gateway        - optional
#   $ipv6address    - optional
#   $ipv6init       - optional - defaults to false
#   $ipv6gateway    - optional
#   $manage_hwaddr  - optional - defaults to true
#   $macaddress     - optional - defaults to macaddress_$title
#   $ipv6autoconf   - optional - defaults to false
#   $userctl        - optional - defaults to false
#   $mtu            - optional
#   $ethtool_opts   - optional
#   $peerdns        - optional
#   $ipv6peerdns    - optional - defaults to false
#   $dns1           - optional
#   $dns2           - optional
#   $domain         - optional
#   $scope          - optional
#   $flush          - optional
#   $zone           - optional
#   $metric         - optional
#   $defroute       - optional
#
# === Actions:
#
# Deploys the file /etc/sysconfig/network-scripts/ifcfg-$ifname.
#
# === Sample Usage:
#
#   network::if::static { 'test0':
#     ensure      => 'up',
#     device      => 'eth0',
#     ipaddress   => '10.21.30.248',
#     netmask     => '255.255.255.128',
#     macaddress  => $::macaddress_eth0,
#     domain      => 'is.domain.com domain.com',
#     zone        => 'public',
#     ipv6init    => true,
#     ipv6address => '123:4567:89ab:cdef:123:4567:89ab:cdef',
#     ipv6gateway => '123:4567:89ab:cdef:123:4567:89ab:1',
#   }
#
# === Authors:
#
# Mike Arnold <mike@razorsedge.org>
#
# === Copyright:
#
# Copyright (C) 2011 Mike Arnold, unless otherwise noted.
#
define network::if::static (
  $ensure,
  $ipaddress,
  $netmask,
  $device = $title,
  $gateway = undef,
  $ipv6address = undef,
  $ipv6init = false,
  $ipv6gateway = undef,
  $macaddress = undef,
  $manage_hwaddr = true,
  $ipv6autoconf = false,
  $userctl = false,
  $mtu = undef,
  $ethtool_opts = undef,
  $peerdns = false,
  $ipv6peerdns = false,
  $dns1 = undef,
  $dns2 = undef,
  $domain = undef,
  $linkdelay = undef,
  $scope = undef,
  $flush = false,
  $zone = undef,
  $defroute = undef,
  $metric = undef
) {
  # Validate our data
  if is_array($ipaddress) {
    if size($ipaddress) > 0 {
      validate_ip_address { $ipaddress: }
      if ! count($ipaddress) == count($netmask) { fail("Number of IP address are different to number of Netmask.") }
      $primary_ipaddress = $ipaddress[0]
      $secondary_ipaddresses = delete_at($ipaddress, 0)
    }
  } elsif $ipaddress {
    if ! is_ip_address($ipaddress) { fail("${ipaddress} is not an IP address.") }
    $primary_ipaddress = $ipaddress
    $secondary_ipaddresses = undef
  }
  if is_array($ipv6address) {
    if size($ipv6address) > 0 {
      validate_ip_address { $ipv6address: }
      $primary_ipv6address = $ipv6address[0]
      $secondary_ipv6addresses = delete_at($ipv6address, 0)
    }
  } elsif $ipv6address {
    if ! is_ip_address($ipv6address) { fail("${ipv6address} is not an IPv6 address.") }
    $primary_ipv6address = $ipv6address
    $secondary_ipv6addresses = undef
  }
  if is_array($netmask) {
    if size($netmask) > 0 {
      $primary_netmask = $netmask[0]
      $secondary_netmask = delete_at($netmask, 0)
    }
  } elsif $netmask {
    $primary_netmask = $netmask
    $secondary_netmask = undef
  }

  if ! is_mac_address($macaddress) {
    # Strip off any tailing VLAN (ie eth5.90 -> eth5).
    $device_clean = regsubst($device,'^(\w+)\.\d+$','\1')
    $macaddy = getvar("::macaddress_${device_clean}")
  } else {
    $macaddy = $macaddress
  }
  # Validate booleans
  validate_bool($userctl)
  validate_bool($ipv6init)
  validate_bool($ipv6autoconf)
  validate_bool($peerdns)
  validate_bool($ipv6peerdns)
  validate_bool($manage_hwaddr)
  validate_bool($flush)

  network_if_base { $title:
    ensure             => $ensure,
    ifname             => $title,
    device             => $device,
    ipv6init           => $ipv6init,
    ipaddress          => $primary_ipaddress,
    ipv6address        => $primary_ipv6address,
    netmask            => $primary_netmask,
    gateway            => $gateway,
    ipv6gateway        => $ipv6gateway,
    ipv6autoconf       => $ipv6autoconf,
    ipsecondaries      => $secondary_ipaddresses,
    ipv6secondaries    => $secondary_ipv6addresses,
    netmasksecondaries => $secondary_netmask,
    macaddress         => $macaddy,
    manage_hwaddr      => $manage_hwaddr,
    bootproto          => 'none',
    userctl            => $userctl,
    mtu                => $mtu,
    ethtool_opts       => $ethtool_opts,
    peerdns            => $peerdns,
    ipv6peerdns        => $ipv6peerdns,
    dns1               => $dns1,
    dns2               => $dns2,
    domain             => $domain,
    linkdelay          => $linkdelay,
    scope              => $scope,
    flush              => $flush,
    zone               => $zone,
    defroute           => $defroute,
    metric             => $metric,
  }
} # define network::if::static
