function out = taft_stAmplitudeEstimation(job)

%% check job-fields
if isempty(job.ups) || job.ups < 0 || ~isnumeric(job.ups)
    error('upsampling factor must be a positive number'); end;
if isempty(job.RT) || job.RT < 0 || ~isnumeric(job.RT)
    error('Repetition Time must be a positive number'); end;

out.in = job;

%% upsample voi-data
% loop through sessions
for s = 1:length(job.VOIs(1).VOIdef)
    out = [];
    
    % loop through VOIs
    for v = 1:length(job.VOIs)
        out.VOIlist{v} = job.VOIs(v).VOIname;
        [dat,RT_ups] = taft_get_upsDat(job.VOIs(v).VOIdef(s),job.ups,job.ons_unit,job.RT,job.trialdur);
        out.VOIdat{v} = taft_fitHRF(dat,RT_ups,job.bl_corr);
    end
    
    % save
    save([job.dir{:} '\st_VOI_sess' int2str(s) '.mat'],'out');
end
