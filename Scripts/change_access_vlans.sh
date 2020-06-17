tclsh

set source_vlan 100
set target_vlan 200

set ifaces [split [exec "show interface status"] "\n"]
foreach if_line $ifaces {
  if [regexp {^([^ ]+) {2}.+ {2}.+ +([0-9]+) .+} $if_line match ifo vlan] {
    if {$vlan == $source_vlan} {
      ios_config "interface $ifo" "switchport access vlan $target_vlan"
    }
  }
  if [regexp {^([^ ]+) {2}.+ {2}.+ +trunk .+} $if_line match ifo] {
    ios_config "interface $ifo" "switchport trunk allowed vlan add $target_vlan"
  }
}

puts [exec "show interface status"]

#exec "write memory"

exec "logout"
