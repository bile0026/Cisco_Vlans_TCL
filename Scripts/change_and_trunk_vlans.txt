tclsh

set show_trunks [exec "show interface trunk"]
set show_interfaces [exec "show interface status"]

set source_vlan 100
set target_vlan 200
set target_vlan_name TEST_VLAN

set vlan_db [split [exec "show vlan brief"] "\n"]
foreach vlan_line $vlan_db {
  if [regexp {^([^ ]+)} $vlan_line match vlan_var] {
    if {$vlan_var == $target_vlan} {
      set vlan_check "exists"
      puts "$vlan_check exists, no need to create"
      break
    } else {
      set vlan_check "not_exist"
      puts "vlan $target_vlan not found, need to create"
    }
  }
}

if {$vlan_check == "not_exist"} {
  puts "creating vlan $target_vlan"
  ios_config "vlan $target_vlan" "name $target_vlan_name" "exit"
}


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

puts [exec "show interface trunk"]
puts [exec "show interface status"]

#exec "write memory"

exec "logout"
