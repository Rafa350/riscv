#!/bin/bash

cd ../Run
./rv-rtlsim > rtlsim.txt
./rv-bhvsim > bhvsim.txt
cd ..
