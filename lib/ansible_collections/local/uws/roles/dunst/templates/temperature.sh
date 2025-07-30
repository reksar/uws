#!/bin/bash
CRITICAL={{ settings.monitoring.temperature.critical }}
[[ $(temperature) -gt $CRITICAL ]] && notify-send --urgency=critical \
  "OVERHEAT" \
  "The hardware temperature is critical!"
exit 0
