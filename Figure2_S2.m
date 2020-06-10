% Bang et al (2020) Private-public mappings in human prefrontal cortex
%
% Reproduces Figure 2-figure supplement 2
%
% Visualises behavioural data for fMRI session split by partner identity
%
% Statistical tests can be reproduced by applying one-sample t-tests to
% regression betas: e.g. [H,P,CI,STATS]= ttest(beta.confidence,0)
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
prescanDir= [repoBase,fs,'Data',fs,'Behaviour',fs,'Prescan'];
scanDir= [repoBase,fs,'Data',fs,'Behaviour',fs,'Scan'];

% Add customn functions
addpath('Functions');

%% -----------------------------------------------------------------------
%% ANALYSIS

% Loop through subjects
for s= 1:n_subjects;
        
    % Load stimulus and context specifications
    load([prescanDir,fs,'s',num2str(s),'_stimulus.mat']);
    load([prescanDir,fs,'s',num2str(s),'_context.mat']);
    
    % Collate data from scan runs
    for i_r= 1:4;       
        % Load file
        load([scanDir,fs,'s',num2str(s),'_social_run',num2str(i_r),'.mat']);    
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
        identity_v= context.nam; % name for partners 1-4;
        if length(task.settings.advo)>4; context_v(5)= 5; end % if hidden partner
        if length(task.settings.advo)>4; identity_v(5)= 5; end % if hidden partner
        for t= 1:length(data.trial);
            data.context(t)= context_v(data.advcat(t));
            data.identity(t)= identity_v(data.advcat(t));
        end

        % AVERAGE CONFIDENCE BY IDENTITY
        % Loop through partners
        for i_identity= 1:4
            % Identify trials
            indx= find(data.identity==i_identity);
            % Compute statistic
            confidence.identity(s,i_identity)= mean(data.con(indx)); 
        end
        
end

%% -----------------------------------------------------------------------
%% VISUALISATION

%% FIGURE 2A
% specifications
figure('color',[1 1 1]);
jitter=.5;
ms= 20;
dcol= [0 0 0];
axisFS= 34;
labelFS= 44;
lw= 4;
% statistics
my_data= confidence.identity;
muz= mean(my_data);
sem= std(my_data)/sqrt(n_subjects);
% plot bars
hold on;
bar(muz,'FaceColor',[1 1 0],'FaceAlpha',.2,'LineWidth',lw); hold on;
for i= 1:numel(muz); plot([i i],[muz(i)-sem(i) muz(i)+sem(i)],'k-','LineWidth',lw); end
% add subjects
for i=1:size(my_data,2);
    y= my_data(:,i);
    x= violaPoints(i,y,jitter);
    scatter(x,y,ms,dcol,'filled','MarkerFaceAlpha',.6);
end
% tidy up
set(gca,'XTick',1:4,'XTickLabel',{'H','M','S','J'});
set(gca,'YTick',[2:1:6]);
ylim([2 6]);
xlim([0 length(muz)+1]);
set(gca,'FontSize',axisFS,'LineWidth',lw);
xlabel('identity','FontSize',labelFS);
ylabel('confidence','FontSize',labelFS);
print('-djpeg','-r300',['Figures',filesep,'Figure2_S2']);