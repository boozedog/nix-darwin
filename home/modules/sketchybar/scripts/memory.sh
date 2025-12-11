FREE_MEM=$(echo "$(memory_pressure | awk '/free percentage/ {print $5}' | tr -d '%') * $(sysctl -n hw.memsize) / 100 / 1024 / 1024 / 1024" | bc -l | xargs printf '%.1f')
sketchybar --set "$NAME" label="${FREE_MEM}GB"
