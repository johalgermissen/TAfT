function out = taft_fmri_eeg_glm(job)

verbose = 1;

%% load & aggregate data
for s = 1:length(job.SessionDef)
    
    % load MEEG
    fprintf(['Session ' int2str(s) ': loading MEEG data.\n'])
    D{s} = spm_eeg_load(job.SessionDef(s).meegf{:});
    
    % adjust timewin & frequency
    if any(job.toi ~= [-inf inf]) || any(job.foi ~= [-inf inf])
         fprintf(['Session ' int2str(s) ': adapting time and/or frequency window.\n'])
         S = [];
         S.D = D{s};
         S.timewin = job.toi;
         S.freqwin = job.foi;
         S.channels = 'all';
         D{s} = spm_eeg_crop(S);
    end
    
    % load VOI
    fprintf(['Session ' int2str(s) ': loading single-trial VOI data.\n'])
    tmpV = load(job.SessionDef(s).stvoif{:});
    
    % rearrange VOI
    for v = 1:length(tmpV.out.VOIdat)
        V{s}(v,:) = tmpV.out.VOIdat{v};
    end
    
    % exclude bad trials
    fprintf(['Session ' int2str(s) ': removing bad trials.\n'])
    [D{s},badtrls{s}] = MEG_rm_badtrials(D{s});
    V{s}(:,badtrls{s}) = [];
    
end

%% merge sessions & put in design matrix
fprintf('setting up design matrix and data array.\n');
X = []; Y = []; itcp = []; con.x = []; 
for s = 1:length(job.SessionDef)
    % design matrix
%     X = blkdiag(X,V{s});
    X = [X; V{s}'];
    
    % data
    tmp_eeg = permute(D{s}(:,:,:),[3,1,2]); % meeg(nchannels, nsamples, ntrials)
    Y = [Y; tmp_eeg];
    
    % intercepts for sessions
    block_length(s) = size(tmp_eeg,1);
    itcp =  blkdiag(itcp,ones(block_length(s),1));
    
    % contrast vector for VOIs
%     con.x = [con.x spm_diag(ones(1,size(V{s},1)))];
    con.x = 1;
end
con.name = tmpV.out.VOIlist;

% add intercepts for sessions and whole experiment
% X = [X itcp ones(size(X,1),1)];
X = [X itcp];
con.x = [con.x zeros(1,size(X,2)-length(con.x))];

% plot design matrix and first vector
if verbose
    F = spm_figure('Create','design matrix','Graphics','on');
    
    % example con
    subplot(5,1,1)
    imagesc(1-con.x(1,:))
    title(['contrast VOI ' con.name{1}])
    axis off
    
    % desigm matrix
    subplot(5,1,[2 5])
    imagesc(X)
    title('design matrix')
end


%% run GLM  
spm('CreateIntWin','on');
spm('FigName','TAFT GLM'); 
spm_progress_bar('Init',D{1}.nchannels)
spm('Pointer','Watch');
spm_progress_bar('Set','ylabel','channel')

nR = size(X,2);
x  = spm_sp('Set',X);
if x.rk~=nR
    error('Rank deficient design matrix (after removal of bad trials)');
end
pX = spm_sp('x-',x);    % pseudoinverse

if strcmp(D{1}.transformtype, 'time')
    beta = [];
    % llop through VOIs
    for v = 1:length(con.name)
        spm_progress_bar('Init',D{1}.nchannels)
        spm_progress_bar('Set','xlabel',con.name{v})
        
        cpX = con.x(1,:)*pX;
        % loop through channels
        for c = 1:D{1}.nchannels
%              tmp = ols2(squeeze(Y(:,c,:)),X);
%              beta(v,c,:) = squeeze(tmp(1,:));
            beta(v,c,:) = cpX * squeeze(Y(:,c,:));
            spm_progress_bar('Set', c);
        end
    end
    
elseif strcmp(D{1}.transformtype, 'TF')
    error('TF-GLM not yet implemented')
else
    error('unknown data format')
end

spm_progress_bar('Clear');
spm('FigName','M/EEG GLM: done'); spm('Pointer','Arrow');

%% write to disk
Db = clone(D{1},[job.dir{:} '\con_taft2.mat'], [D{1}.nchannels D{1}.nsamples length(con.name)]);     % channels, timepoints, VOIs
Db(:,:,:) = permute(beta,[2,3,1]);
Db = conditions(Db, ':', con.name);
% Dnew_b = trialonset(Dnew_b, ':', []);
Db = badtrials(Db, ':', 0);
Db = repl(Db, ':', ones(1,D{1}.nchannels));
Db = Db.history(Db,'taft_glm');
save(Db);

