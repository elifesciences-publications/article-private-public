% conf_dist: confidence response probabilities for -6,-5,...,-1,1,2,..,6
% (those probabilioties must sum to 1)
% noise_std: std of noise.
% criteria: the 11 confidence criterions that account for the confidence
% distribution given the noist

function criteria=my_confidence_criteria(conf_dist, noise_std,stimuli)

% conf_dist must sum to 1!!!
conf_dist=conf_dist/sum(conf_dist);

% Gaussian centers, std is noise_std
mu= [-1*fliplr(stimuli) stimuli];

cs_conf= cumsum(conf_dist); % cumulative confidence distributions.

% this is the cdf of the gaussian mixtures @ point x minus some (objective
% value) c
f = @(x,c) mean(normcdf(x, mu, noise_std))- c;

for cc= 1: length(cs_conf)-1
    c= cs_conf(cc); % This is the value the cdf should achieve.
    if c==0
        criteria(cc)=min(mu)- 100*noise_std;
        exitflag(cc)=1;
    elseif c==1
        criteria(cc)=max(mu)+ 100*noise_std;
        exitflag(cc)=1;
    else
        [criteria(cc),fval(cc),exitflag(cc),output(cc)] = fzero(@(x)f(x,c), [min(mu)- 10*noise_std, max(mu)+ 10*noise_std]);
    end
end

if any(~exitflag)
    save('Bug error report');
    error('Problem!')
end