tclsh

set show_trunks [exec "show interface trunk"]
set show_interfaces [exec "show interface status"]

set source_vlan 100
set target_vlan 200
set target_vlan_name TEST_VLAN
set trunking_vlan 4000

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
  #if [regexp {^([^ ]+) {2}.+ {2}.+ +trunk .+} $if_line match ifo] {
  #  ios_config "interface $ifo" "switchport trunk allowed vlan add $target_vlan"
  #}
}

#build list of trunk ports to change
set temp_trunk_ifaces [split [exec "show spanning-tree vlan $trunking_vlan | begin Gi"] "\n"]
foreach tIface $temp_trunk_ifaces {
  if [regexp {^([^ ]+) {2}.+ {2}.+ {2}.+ {2}.+ +([A-Za-z]+) .+} $tIface match tIfo iType ] {
    puts "$tIfo is an uplink to another switch"
    if {$iType == "P2p"} {
      ios_config "interface $tIfo" "switchport trunk allowed vlan add $target_vlan"
    } elseif {$iType == "Edge"} {
      puts "$tIface is NOT a an uplink to another switch"
    }
  }
}


puts [exec "show interface trunk"]
puts [exec "show interface status"]

#exec "write memory"

exec "logout"
