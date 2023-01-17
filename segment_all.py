from csbdeep.utils import normalize
import matplotlib.pyplot as plt
import skimage
from skimage import io
from stardist.models import StarDist2D
import glob
import os
import numpy as np

basefnames = [''] # list of snapshot folders to analyze

model = StarDist2D.from_pretrained('2D_versatile_fluo')

for basefname in basefnames:
    tiffiles = glob.glob(basefname + '*.tif')
    for f in tiffiles:
        segfname = f[0:-4] + '_seg.csv'
        I = io.imread(f, plugin='pil')
        labels, details = model.predict_instances(normalize(I), prob_thresh=0.5) 
        np.savetxt(segfname,labels,delimiter=',',fmt='%d')
