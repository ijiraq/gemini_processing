#!/bin/bash

ln -s /iraf/login.cl /scratch/login.cl

source activate iraf27

runNifty nifsPipeline -f $1
