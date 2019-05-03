function [data,RT_ups] = taft_get_upsDat(VOIdef,ups,ons_unit,RT,trialdur)

%% load data
dat = load(VOIdef.voif{:});
dat = dat.Y;

%% timestamps of data
if ons_unit==1         % in seconds
    t_ons = VOIdef.onsets;
elseif ons_unit==2  % convert RTs to seconds
    t_ons = VOIdef.onsets .* RT;
else
    error('unknown onset units.');
end

RT_ups = RT/ups;

%% upsample data and epoch

% upsampling
dat_ups = spline(1:length(dat),dat,1:(1/ups):length(dat));

% prepare epoching
t_ups_ons = 0:RT_ups:(length(dat_ups)-1)*RT_ups;
i_ons = taft_findc(t_ups_ons,t_ons);
dur_hrf_ups = round(trialdur/RT_ups);

% epoch
for t = 1:length(t_ons)
    t_ind(t,:) = i_ons(t):(i_ons(t)+dur_hrf_ups);
end
data = dat_ups(t_ind);
