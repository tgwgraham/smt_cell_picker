import os, numpy as np, pandas as pd
from glob import glob
import scipy.io

def classifycompartments(maskmat,csvfolder):

    columns = ['y','x','I0','bg','y_err','x_err','I0_err','bg_err','H_det','error_flag', 
              'snr','rmse','n_iter','y_detect','x_detect','frame','loc_idx','trajectory',  
              'subproblem_n_traj','subproblem_n_locs','compartment']

    masks = scipy.io.loadmat(maskmat)
    nfiles = len(masks['classification'][0])

    for j in range(1,nfiles+1):

        # read in localization file and corresponding mask
        currmask = masks['masks'][0][j-1]

        # skip this number if mask is empty
        if currmask.size==0:
            continue

        csvfile = "%s/%d.csv" % (csvfolder,j)
        df = pd.read_csv(csvfile)
        x = df['x'].round().astype('int')
        y = df['y'].round().astype('int')
        df['compartment']=currmask[y,x]
        df.to_csv(csvfile, index=False, columns=columns)


def classify_and_write_csv(maskmat,csvfolder,outfolder):
    
    import os
    os.makedirs(outfolder,exist_ok = True)
    
    columns = ['y','x','frame','trajectory']

    masks = scipy.io.loadmat(maskmat)
    nfiles = len(masks['classification'][0])

    for j in range(1,nfiles+1):

        # read in localization file and corresponding mask
        currmask = masks['masks'][0][j-1]

        # skip this number if mask is empty
        if currmask.size==0:
            continue
            
        # skip this FOV if current mask has no selected cells 
        if not (currmask<0).any():
            continue
        
        print('Processing FOV %d.' % j, end="\r")
        
        try:
            csvfile = "%s/%d.csv" % (csvfolder,j)
            df = pd.read_csv(csvfile)
            x = df['x'].round().astype('int')
            y = df['y'].round().astype('int')
            df['compartment']=currmask[y,x]

            # dictionary of trajectory indices for each compartment
            compind = df['compartment'].unique()
            compind = compind[compind < 0] # user-selected compartments, i.e., those with index < 0
            trajind_by_comp = {i: [] for i in compind}    

            # loop over trajectories and identify which ones correspond to which compartments
            trajind = df['trajectory'].unique()
            for t in trajind:
                currtraj = df[df['trajectory']==t]
                c = currtraj['compartment']
                cneg = c[c < 0].unique()
                if len(cneg)==1: # if this trajectory touches one and only one non-zero compartment, add its index to the list
                    trajind_by_comp[cneg[0]].append(t)

            for k in trajind_by_comp.keys():
                # write out each set of trajectories to a new output file
                trajind = trajind_by_comp[k]
                currtraj = df[df['trajectory'].isin(trajind)]

                currtraj.to_csv("%s/%d_%d.csv" % (outfolder,j,-k),columns=columns)    
        except:
            print('Encountered a glitch with %d.' % j, end="\r")
        
            
    # TO DO: IMPLEMENT DIFFERENT OPTIONS FOR CLASSIFICATION
    # rule=
    # “any” - if any of the localizations are in a non-background region (and no more than one non-background region is represented), classify the whole trajectory in that region. Throw those with more than one non-background region into an “indeterminate” category
    # “all” - if any of the localizations are in the same non-background region, classify the whole trajectory in that region. If a trajectory is in more than one region, classify as indeterminate
    # “majority” - classify the trajectory based on which region the majority of localizations are in; if there’s no majority, throw it into an “indeterminate” category
    # “split” - divide trajectories into shorter segments within the same region
    # sign=
    # “negative”-only export negative labels (don’t include a negative sign)
    # “positive”-only export positive labels
    # “both”-export both positive and negative labels (designate negative with negative sign)
