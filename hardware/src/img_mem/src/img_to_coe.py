# ==============================================================================
#   File:   img_to_coe.py
#   Author: Austin Buchan (abuchan@eecs.berkeley.edu)
#   Copyright:  Copyright 2005-2014 UC Berkeley
#   Version: Updated for UC Berkeley CS150 Fall 2013 Course
# ==============================================================================

# ==============================================================================
#   Section:  License
# ==============================================================================
#   Copyright (c) 2005-2014, Regents of the University of California
#   All rights reserved.
# 
#   Redistribution and use in source and binary forms, with or without
#   modification, are permitted provided that the following conditions are met:
# 
#     - Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     - Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer
#       in the documentation and/or other materials provided with the
#       distribution.
#     - Neither the name of the University of California, Berkeley nor the
#       names of its contributors may be used to endorse or promote
#       products derived from this software without specific prior
#       written permission.
# 
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
#   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
#   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
#   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
#   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
#   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
#   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
#   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
#   POSSIBILITY OF SUCH DAMAGE.
# 
# ==============================================================================

# ------------------------------------------------------------------------------
#   Function: img_to_coe
# 
#   Desc: Read image file and format for storage in COE file for use in IMG_MEM.
#     Depends on OpenCV install.
# 
#   Params: -img_filename: Name of file to convert
# ------------------------------------------------------------------------------

#!/usr/bin/python

import cv2
import sys

infile = sys.argv[1]
outfile = infile.split('.')[0] + '.coe'

img = cv2.imread(infile)

fout = open(outfile,'w')

fout.write('memory_initialization_radix=16;\n')
fout.write('memory_initialization_vector=\n')

n_row = len(img)
n_col = len(img[0])

for i in range(n_row):
  for j in range(n_col):
    fout.write('%02x' # img[i,j,0])
    if i == (n_row-1) and j == (n_col-1):
      fout.write(';\n')
    else:
      fout.write(',\n')

fout.close()
