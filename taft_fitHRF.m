function stAmp = taft_fitHRF(data,RT,bl_corr)

if nargin < 3
    error('not enough input arguments')
end

%% obtain canonical hrf for specific RT
hrf = spm_hrf(RT);

%% prepare GLM
if bl_corr  % add intercept to remove offset-effects
    dm = [hrf(1:size(data,2)) ones(1,size(data,2))];
    con = [1 0];
else
    dm = hrf(1:size(data,2));
    con = 1;
end

%% calculate GLM
x = spm_sp('Set',dm);

if x.rk ~= size(dm,2)
    error('design matrix is rank defficient.')
end

% pseudo invers
pdm=spm_sp('x-',x);

% beta estimates
stAmp=con*pdm*data';