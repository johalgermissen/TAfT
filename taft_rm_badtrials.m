function [Dout,badtrls] = taft_rm_badtrials(D)


% get trials
badtrls = D.badtrials;
goodtrls = setdiff(1:D.ntrials,badtrls);

if isempty(badtrls)
    fprintf('no bad trials found - not removing any bad trials.\n');
    Dout = D;
    
else
    % write to terminal
    fprintf('removing these trials:\n');
    for b = 1:length(badtrls)
        fprintf([int2str(badtrls(b)) '\n'])
    end
    
    % remove data
    Dout = D;
    [p, f, x] = fileparts(fnamedat(Dout));
    Dout = clone(Dout, fullfile(p, ['p' f x]), [Dout.nchannels Dout.nsamples numel(goodtrls)]);
    Dout(1:Dout.nchannels, 1:Dout.nsamples, 1:numel(goodtrls)) =  D(:,:,goodtrls);
    
    % adjust trial info
    S = struct(Dout);
    Sorg = struct(D);
    S.trials = Sorg.trials;
    S.trials(badtrls) = [];
    Dout = meeg(S);
    
    fprintf('done.\n')
    
    
end