#!/bin/bash


if [ ! -f "/scratch/login.cl" ]; then
	ln -s /iraf/login.cl /scratch/login.cl
fi

source activate iraf27

exec "$@"
