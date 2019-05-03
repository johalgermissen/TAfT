function cfg = tbx_cfg_taft


% ---------------------------------------------------------------------
% dir Directory
% ---------------------------------------------------------------------
dir         = cfg_files;
dir.tag     = 'dir';
dir.name    = 'Directory';
dir.help    = {'Select a directory where the .mat file containing the resulting data will be written.'};
dir.filter = 'dir';
dir.ufilter = '.*';
dir.num     = [1 1];

%% stA specifics

% ---------------------------------------------------------------------
% upsampling
% ---------------------------------------------------------------------
upsa         = cfg_entry;
upsa.tag     = 'ups';
upsa.name    = 'Upsampling factor';
upsa.help    = {'enter the upsampling factor used for hrf estimation.'};
upsa.strtype = 'r';
upsa.num     = [1 1];
upsa.val     = {10};

% ---------------------------------------------------------------------
% RT Interscan interval
% ---------------------------------------------------------------------
RT         = cfg_entry;
RT.tag     = 'RT';
RT.name    = 'Interscan interval';
RT.help    = {'Interscan interval, TR, (specified in seconds).  This is the time between acquiring a plane of one volume and the same plane in the next volume.  It is assumed to be constant throughout.'};
RT.strtype = 'r';
RT.num     = [1 1];

% ---------------------------------------------------------------------
% Trial dur
% ---------------------------------------------------------------------
trialdur   = cfg_entry;
trialdur.tag     = 'trialdur';
trialdur.name    = 'Trial duration';
trialdur.help    = {'Duration (in seconds) for each trial used to estimate the hrf amplitude.'
    'Duration can exceed the duration of the actual trial diration. Duration of >= 8 seconds is advisable for stable hrf estimation.'};
trialdur.strtype = 'r';
trialdur.num     = [1 1];

% ---------------------------------------------------------------------
% onset units
% ---------------------------------------------------------------------
ons_unit         = cfg_menu;
ons_unit.tag     = 'ons_unit';
ons_unit.name    = 'onset units';
ons_unit.help    = {'Units of onsets: time (s) or scan volumes (RT)'};
ons_unit.labels  = {'seconds' 'TRs'};
ons_unit.values  = {1 2};
ons_unit.val     = {1};

% ---------------------------------------------------------------------
% baseline correction
% ---------------------------------------------------------------------
blcorr         = cfg_menu;
blcorr.tag     = 'bl_corr';
blcorr.name    = 'Baseline correct BOLD';
blcorr.help    = {'Baseline-correct BOLD signal for each trial.'};
blcorr.labels  = {'Yes' 'No'};
blcorr.values  = {1 0};
blcorr.val     = {0};

% ---------------------------------------------------------------------
% VOI name
% ---------------------------------------------------------------------
voinam          = cfg_entry;
voinam.tag      = 'VOIname';
voinam.name     = 'Name of VOI';
voinam.help     = {''};
voinam.strtype  = 's';
voinam.num      = [1 inf];

% ---------------------------------------------------------------------
% VOI session number
% ---------------------------------------------------------------------
sessnum    = cfg_entry;
sessnum.tag     = 'sessnum';
sessnum.name    = 'Session number';
sessnum.help    = {''};
sessnum.strtype = 'i';
sessnum.num     = [1 1];
sessnum.val     = {1};

% ---------------------------------------------------------------------
% VOI file
% ---------------------------------------------------------------------
voif            = cfg_files;
voif.tag        = 'voif';
voif.name       = 'VOI file';
voif.help       = {''};
voif.filter     = 'mat';
voif.ufilter    = '.mat';
voif.num        = [1 1];

% ---------------------------------------------------------------------
% onsets
% ---------------------------------------------------------------------
onsets         = cfg_entry;
onsets.tag     = 'onsets';
onsets.name    = 'Onsets';
onsets.help    = {'Enter a vector of values, one for each trial.'};
onsets.strtype = 'r';
onsets.num     = [Inf 1];

% ---------------------------------------------------------------------
% VOI session branch
% ---------------------------------------------------------------------
voisess         = cfg_branch;
voisess.tag     = 'VOIdef';
voisess.name    = 'VOI definition';
voisess.val     = {sessnum voif onsets};
voisess.help    = {''}';

% ---------------------------------------------------------------------
% generic VOI sessions
% ---------------------------------------------------------------------
generic2         = cfg_repeat;
generic2.tag     = 'voiSess';
generic2.name    = 'VOI session';
generic2.help    = {''};
generic2.values  = {voisess};
generic2.num     = [0 Inf];

% ---------------------------------------------------------------------
% VOI branch
% ---------------------------------------------------------------------
voi         = cfg_branch;
voi.tag     = 'VOIs';
voi.name    = 'VOI definition';
voi.val     = {voinam generic2};
voi.help    = {''}';


% ---------------------------------------------------------------------
% generic VOIs
% ---------------------------------------------------------------------
generic1         = cfg_repeat;
generic1.tag     = 'voi';
generic1.name    = 'VOIs';
generic1.help    = {''};
generic1.values  = {voi };
generic1.num     = [0 Inf];

% ---------------------------------------------------------------------
% single trial amplitude estimation branch
% ---------------------------------------------------------------------
taftSTA        = cfg_exbranch;
taftSTA.tag    = 'stAmpEst';
taftSTA.name    = 'Single-trial amplitude estimation';
taftSTA.val     = {dir upsa RT trialdur blcorr ons_unit generic1 };
taftSTA.help    = {''};
taftSTA.prog    = @taft_stAmplitudeEstimation;
% taftSTA.out     = stAout;


%% GLM specifics


% ---------------------------------------------------------------------
% stVOI file
% ---------------------------------------------------------------------
stvoif            = cfg_files;
stvoif.tag        = 'stvoif';
stvoif.name       = 'single-trial VOI file';
stvoif.help       = {''};
stvoif.filter     = 'mat';
stvoif.ufilter    = '.mat';
stvoif.num        = [1 1];

% ---------------------------------------------------------------------
% MEEG file
% ---------------------------------------------------------------------
meegf            = cfg_files;
meegf.tag        = 'meegf';
meegf.name       = 'MEEG file';
meegf.help       = {''};
meegf.filter     = 'mat';
meegf.ufilter    = '.mat';
meegf.num        = [1 1];

% ---------------------------------------------------------------------
% session branch
% ---------------------------------------------------------------------
glmsess         = cfg_branch;
glmsess.tag     = 'SessionDef';
glmsess.name    = 'Session Definition';
glmsess.val     = {stvoif meegf};
glmsess.help    = {''}';

% ---------------------------------------------------------------------
% generic sessions
% ---------------------------------------------------------------------
generic3         = cfg_repeat;
generic3.tag     = 'Sess';
generic3.name    = 'Sessions';
generic3.help    = {''};
generic3.values  = {glmsess};
generic3.num     = [0 Inf];

% ---------------------------------------------------------------------
% timewin of Interest
% ---------------------------------------------------------------------
toi    = cfg_entry;
toi.tag     = 'toi';
toi.name    = 'time window';
toi.help    = {''};
toi.strtype = 'r';
toi.num     = [1 2];
toi.val     = {[-inf inf]};

% ---------------------------------------------------------------------
% frequencies of Interest
% ---------------------------------------------------------------------
foi         = cfg_entry;
foi.tag     = 'foi';
foi.name    = 'frequency range';
foi.help    = {'Only used if MEEG is time-frequency data'};
foi.strtype = 'r';
foi.num     = [1 2];
foi.val     = {[-inf inf]};


% ---------------------------------------------------------------------
% GLM estimation branch
% ---------------------------------------------------------------------
taftglm        = cfg_exbranch;
taftglm.tag    = 'fMRIEEGglm';
taftglm.name    = 'fMRI-EEG GLM';
taftglm.val     = {dir generic3 toi foi};
taftglm.help    = {''};
taftglm.prog    = @taft_fmri_eeg_glm;

% ---------------------------------------------------------------------
% main TAFT branch
% ---------------------------------------------------------------------
cfg         = cfg_repeat;
cfg.tag     = 'taft';
cfg.name    = 'TAFT';
cfg.values  = {taftSTA taftglm};