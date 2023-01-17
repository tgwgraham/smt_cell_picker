from quot import read_config, track_file
import glob
from os.path import exists

basefnames = [""]

for basefname in basefnames:

  flist = glob.glob("%s*.nd2" % basefname)
  
  config = read_config('settings.toml')
  
  
  columns = ['y','x','I0','bg','y_err','x_err','I0_err','bg_err','H_det','error_flag', 
          'snr','rmse','n_iter','y_detect','x_detect','frame','loc_idx','trajectory',  
          'subproblem_n_traj','subproblem_n_locs']
  
  
  for f in flist:
      try:
        currbasefname = f[:-4]
        if exists('%s.csv' % currbasefname):
            print('%s.csv already tracked. Skipping.' % currbasefname)
            continue
        trajs = track_file(f, **config)
        print(trajs)
        trajs.to_csv('%s.csv' % currbasefname, index=False, columns=columns)
      except:
        print('Had a problem with %s' % currbasefname)

  
  
