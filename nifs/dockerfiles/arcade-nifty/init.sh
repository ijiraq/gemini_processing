#!/bin/bash

echo "[skaha] start init.sh"

if [ ! -f "/scratch/login.cl" ]; then
	ln -s /iraf/login.cl /scratch/login.cl
fi

echo "[skaha] start source activate iraf27"
source activate iraf27
echo "[skaha] end source activate iraf27"

# To make container useful in both interactive sessions
# and batch processing, check if xterm is available.
# If so, start up xterm. If not, get ready for
# incoming processing command.
if xhost >& /dev/null; then 
	# Display exists
	xterm -T $1
else 
	# Display invalid"
	exec "$@"
fi

echo "[skaha] end init.sh"
