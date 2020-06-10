% conf_criteria: 11 response crietria for the subject (in increasing order)
% noise_std: std of perceptual noise
% responses_by_gaussian: the distribution of responses (confidence) for
% each gaussian. Each row is a gaussian (increasing mean) and each column
% is confidence increasing -6,-5,...-1,1,2...6
function responses_by_gaussian= calc_responses_by_gaussian(conf_criteria, noise_std,stimuli)

% Gaussian centers, std is noise_std
mu= [-1*fliplr(stimuli) stimuli];
MU= repmat(mu',[1 length(conf_criteria)]);
CC= repmat(conf_criteria, [length(mu),1]);
responses= normcdf(CC, MU, noise_std);
responses_by_gaussian=[responses(:,1) diff(responses,1,2) 1-responses(:,end)];