% Bang et al (2020) Private-public mappings in human prefrontal cortex
%
% Implements confidence model illustrated in Figure 4A 
% and reproduces Figure 4B
%
% "Private confidence" is computed by training multinomial regression on
% data from prescan session and then applying weights to data from fMRI
% session while setting context weights to zero
%
% Visualises encoding of private confidence and public confidence
% (empirically obseved reports) in ROI timeseries and performs associated
% statistical tests
%
% Dan Bang danbang.db@gmail.com 2020

%% -----------------------------------------------------------------------
%% PREPARATION

% fresh memory
clear; close all;

% Subjects
n_subjects= 28;

% Paths [change 'repoBase' according to local setup]
fs= filesep;
repoBase= [getDropbox(1),fs,'Ego',fs,'Matlab',fs,'ucl',fs,'social_learn',fs,'Repository',fs,'GitHub'];
prescanBDir= [repoBase,fs,'Data',fs,'Behaviour',fs,'Prescan'];
scanBDir= [repoBase,fs,'Data',fs,'Behaviour',fs,'Scan'];
scanFDir= [repoBase,fs,'Data',fs,'fMRI',fs,'ROI_TimeSeries'];

% Add customn functions
addpath('Functions');

% ROIs
my_ROIs= {'dACC','pgACC','FPl'};

%% -----------------------------------------------------------------------
%% COMPUTE PRIVATE CONFIDENCE

% Loop through subjects
for s= 1:n_subjects;
    
    % Load stimulus and context specifications
    load([prescanBDir,fs,'s',num2str(s),'_stimulus.mat']);
    load([prescanBDir,fs,'s',num2str(s),'_context.mat']);
    
    %% FIRST FIT MODEL USING PRESCAN DATA PHASE 3 (SAME SETUP AS IN FMRI)

    % Load file
    load([prescanBDir,fs,'s',num2str(s),'_social3.mat']);    

    % Translate miliseconds to seconds
    data.rt1= data.rt1/1000;
    data.rt2= data.rt2/1000;

    % Link confidence profile to partner identity
    context_v= context.con; % profile for partners 1-4;
    if length(task.settings.advo)>4; context_v(5)= 5; end % if hidden partner
    for t= 1:length(data.trial);
        data.context(t)= context_v(data.advcat(t));
    end
  
    % Fit multinomial regression
    % Load variables
    confidence= data.con;
    coherence= data.cohcat-2.5;
    reactiontime= log(data.rt1);
    context1= data.context==1;
    context2= data.context==2;
    context3= data.context==3;
    context4= data.context==4;
    context5= data.context==5;
    % Predictors
    X= [coherence; reactiontime; ...
        context1; context2; context3; context4]';
    % Outcome
    Y= 7-confidence;
    % Fit and save predictor weights
    [B,~,STATS] = mnrfit(X,Y,'model','ordinal','link','probit');
    betas{s}= B;
        
    %% THEN USE FITTED MODEL TO DERIVE ESTIMATES FOR SCAN DATA

    % Collate data from scan runs
    for i_r= 1:4;       
        % Load file
        load([scanBDir,fs,'s',num2str(s),'_social_run',num2str(i_r),'.mat']);    
        % Get data field names
        fn = fieldnames(data);
        % If first block, then initialise temporary storage structure
        if i_r == 1; 
            for i_field = 1:length(fn); 
                eval(['tmp.',fn{i_field},'=[];']); 
            end; 
        end
        % Add data to temporary storage structure
        for i_field = 1:length(fn)
            eval(['tmp.',fn{i_field},'=[tmp.',fn{i_field},' data.',fn{i_field},'];']);
        end               
    end
    
    % Rename collated data
    data=tmp;
            
    % Translate miliseconds to seconds
    data.rt1= data.rt1/1000;
    data.rt2= data.rt2/1000;

    % Link confidence profile to partner identity
    context_v= context.con; % profile for partners 1-4;
    if length(task.settings.advo)>4; context_v(5)= 5; end % if hidden partner
    for t= 1:length(data.trial);
        data.context(t)= context_v(data.advcat(t));
    end
    
    % Apply multinomial regression    
    % Load variables
    confidence= data.con;
    coherence= data.cohcat-2.5;
    reactiontime= log(data.rt1);
    context1= data.context==1;
    context2= data.context==2;
    context3= data.context==3;
    context4= data.context==4;
    context5= data.context==5;
    % Predictors
    X= [coherence; reactiontime; ...
        context1*0; context2*0; context3*0; context4*0;]';
    % Apply fitted weights
    Yhat= mnrval(betas{s},X,'model','ordinal','link','logit');
    % Save prediction (i.e. expectation under fitted weights)
    model.private{s}= 7-sum(repmat([1:6],size(Yhat,1),1).*Yhat,2);
     
end

%% -----------------------------------------------------------------------
%% QUANTIFY ROI ENCODING OF PRIVATE AND PUBLIC CONFIDENCE

% Loopthrough ROIs
for i_roi= 1:length(my_ROIs)
    % Loop through subjects
    for s= 1:n_subjects;

        % Load ROI data
        load([scanFDir,fs,'s',num2str(s),'_',my_ROIs{i_roi},'_','TimeSeries.mat']);    
        roi_ts = timeSeries;
        
        % Load stimulus and context specifications
        load([prescanBDir,fs,'s',num2str(s),'_stimulus.mat']);
        load([prescanBDir,fs,'s',num2str(s),'_context.mat']);
        
        % Collate data from scan runs
        for i_r= 1:4;       
            % Load file
            load([scanBDir,fs,'s',num2str(s),'_social_run',num2str(i_r),'.mat']);    
            % Get data field names
            fn = fieldnames(data);
            % If first block, then initialise temporary storage structure
            if i_r == 1; 
                for i_field = 1:length(fn); 
                    eval(['tmp.',fn{i_field},'=[];']); 
                end; 
            end
            % Add data to temporary storage structure
            for i_field = 1:length(fn)
                eval(['tmp.',fn{i_field},'=[tmp.',fn{i_field},' data.',fn{i_field},'];']);
            end               
        end

        % Rename collated data
        data=tmp;

        % Translate miliseconds to seconds
        data.rt1= data.rt1/1000;
        data.rt2= data.rt2/1000;

        % Link confidence profile to partner identity
        context_v= context.con; % profile for partners 1-4;
        if length(task.settings.advo)>4; context_v(5)= 5; end % if hidden partner
        for t= 1:length(data.trial);
            data.context(t)= context_v(data.advcat(t));
        end
        
        % Include trials based on deviation from grand mean
        rt1= log(data.rt1./1000);
        centre= mean(rt1);
        stdval= std(rt1)*2.5;
        include= (rt1>(centre-stdval))&(rt1<(centre+stdval));

        % Include trials where final time-point estimate is ~NaN
        for i= 1:size(roi_ts,1); if isnan(roi_ts(i,end)); include(i)=0; end; end;

        % Include explicit trials
        for i= 1:length(data.context); if data.context(i)==5; include(i)=0; end; end;
    
        % UP-SAMPLED GLM
        roi_Zts = zscore(roi_ts(include,:));
        private= zscore(model.private{s}(include)');
        public= zscore(data.con(include));
        t= 0;
        for j= 1:size(roi_ts,2)
            t= t+1;
            x= [private; public]';
            y= roi_Zts(:,j);
            beta= glmfit(x,y,'normal');
            beta_ts{i_roi}.private(s,t)= beta(end-1);
            beta_ts{i_roi}.public(s,t)= beta(end);
        end
    
    end
end

%% -----------------------------------------------------------------------
%% VISUALISE ROI ENCODING OF PRIVATE AND PUBLIC CONFIDENCE

%% FIGURE 4B
% specifications
max_t = 85;
srate = .144;
lw=4;
ms= 8;
axisFS= 34;
labelFS= 44;
% Loop through ROIs
for i_roi= 1:length(my_ROIs);
figure('color',[1 1 1]);
plot([0 max_t+20],[0 0],'k-','LineWidth',lw); hold on
plot([2/srate 2/srate],[-1 +1],'k--','LineWidth',lw/2); hold on
private= beta_ts{i_roi}.private;
public= beta_ts{i_roi}.public;
privateP= ttest(private,0);
for t= 1:length(privateP); if privateP(t)==1; plot(t,-.12,'s','color','m','MarkerFaceColor','m','MarkerSize',ms); end; end;
publicP= ttest(public,0);
for t= 1:length(publicP); if publicP(t)==1; plot(t,-.11,'s','color','c','MarkerFaceColor','c','MarkerSize',ms); end; end;
fillsteplotm(private,lw);
fillsteplotc(public,lw);
ylim([-.14 .14]); 
xlim([0 max_t]);
xlabel('time [seconds]','FontSize',labelFS,'FontWeight','normal');
ylabel('beta [a.u.]','FontSize',labelFS,'FontWeight','normal');
set(gca,'YTick',[-.12:.04:.12]);
set(gca,'XTick',0:14:max_t-2)
set(gca,'XTickLabel',{'-2','0','2','4','6','8'})
box('off')
set(gca,'FontSize',axisFS,'LineWidth',lw);
title(my_ROIs{i_roi},'FontSize',labelFS,'FontWeight','normal');
axis square;
print('-djpeg','-r300',['Figures',filesep,'Figure4B_',my_ROIs{i_roi}]);
end