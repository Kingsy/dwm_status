#!/bin/elvish

# use ./lib/dwm_date
modules = [ ]

script = (src)[name]
include = [(splits '/' $script)]
includes = $include[:-1]
includes = (joins '/' $includes)"/" 
-source $includes"lib/dwm_date.elv"

fn reduce [arr]{
  reduced = [ ] 
  for node $arr {
    if (not-eq $node '') {
      reduced = [ $@reduced $node ]
    }
  }
  put $reduced
}

fn dwm_date {
  modules = [ $@modules "[ "(date "+DATE: %d/%m/%y TIME: %H:%M:%S")" ]" ]
}

fn dwm_battery {
  raw_output = [(acpi -b)]
  for node $raw_output {
    direction = (echo $node | cut -d ',' -f 1 | cut -d ' ' -f 3)
    if (not-eq $direction "Unknown") {
      battery = (echo $node | cut -d ',' -f 2 | cut -d ' ' -f 2)
      direction_symbol = '-'
      if (eq $direction Charging) {
        direction_symbol = '+'
      } elif (eq $battery '100%') {
        direction_symbol = ''
      }
      modules = [ $@modules "[ "$battery$direction_symbol" ]" ]
    }
  }
}

fn dwm_resources {
  # Used and total memory
  memory_raw=[(splits ' ' (free -h | grep Mem))]
  memory_raw = (reduce $memory_raw)
  modules = [ $@modules "[ RAM: "$memory_raw[2]"/"$memory_raw[1] "]" ]
  # CPU temperature
  cpu_raw=[(splits ' ' (sensors | grep Package))]
  modules = [ $@modules "[ CPU TEMP: "$cpu_raw[4]" ]" ]
}

fn populate {
  modules = [ ]
  dwm_date
  dwm_battery
  dwm_resources
}

while $true {
  populate
  xsetroot -name " "(joins ' ' $modules)" "
  sleep 1
}
