% noise_std a 1*2 vec with noise std for players 1 and 2
% Dyad_acc:51 (player 1 'ready made increasing mean') * 51
% (player 2 'ready made increasing mean')* 8 (Gaussian increasing mean).

function output = calc_landscape(noise_std, ready_made_conf_dist, stimuli);
conf_mean_vec= 1:.1:6;
Dyad_acc=zeros(length(conf_mean_vec),length(conf_mean_vec),8);
for kk1=1: length(conf_mean_vec)
    conf_dist(1,:)= [ready_made_conf_dist(kk1,end:-1:1) ready_made_conf_dist(kk1,1:end)]/2;
    % calculate criteria for participant
    criteria(1,:)=my_confidence_criteria(conf_dist(1,:), noise_std(1), stimuli); 
    % calculate response probabilities (confidence) for each Gaussian
    responses_by_gaussian(:,:,1)= calc_responses_by_gaussian(criteria(1,:), noise_std(1), stimuli); 
    for kk2=1:length(conf_mean_vec)
        conf_dist(2,:)= [ready_made_conf_dist(kk2, end:-1:1) ready_made_conf_dist(kk2,1:end)]/2;
        criteria(2,:)=my_confidence_criteria(conf_dist(2,:), noise_std(2), stimuli); % calculate criteria for participant
        responses_by_gaussian(:,:,2)= calc_responses_by_gaussian(criteria(2,:), noise_std(2), stimuli);
        for cnf=1:12
            for mm=1:8
                if mm==1
                    % negative gaussians
                    % if player 1 play the conf1=cnf category the dyad will
                    % necessarily be correct when player 2 plays conf2= 1,2,3,...12-cnf.
                    % The dyas will also be correct half of the times that players
                    % conf2= 12-cnf+1;       
                    ind_sure= 1:(12-cnf);
                    ind_maybe= 12-cnf+1;
                elseif mm==5
                    ind_sure= (12-cnf+2):12;
                    ind_maybe= 12-cnf+1;
                end
                Dyad_acc(kk1,kk2,mm)= Dyad_acc(kk1,kk2,mm)+ responses_by_gaussian(mm,cnf,1)*...
                    (squeeze(sum(responses_by_gaussian(mm,ind_sure,2)))+ .5*responses_by_gaussian(mm,ind_maybe,2));
            end
        end
    end
end
Dyad_acc_across_Gaussian= mean(Dyad_acc,3);
output = Dyad_acc_across_Gaussian;
end