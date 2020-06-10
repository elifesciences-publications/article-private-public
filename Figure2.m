% Bang et al (2020) Private-public mappings in human prefrontal cortex
%
% Reproduces Figure 2
%
% Visualises behavioural data for fMRI session and performs associated 
% regression analyses
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
    if length(task.settings.advo)>4; context_v(5)= 5; end % if hidden partner
    for t= 1:length(data.trial);
        data.context(t)= context_v(data.advcat(t));
    end
        
    % AVERAGE CONFIDENCE BY COHERENCE
    % Loop through partners
    for i_stimulus= 1:4
        % Identify trials
        indx= find(data.cohcat==i_stimulus);
        % Compute statistic
        confidence.stimulus(s,i_stimulus)= mean(data.con(indx)); 
    end
    
    % AVERAGE CONFIDENCE BY CONTEXT
    % Loop through partners
    for i_context= context_v
        % Identify trials
        indx= find(data.context==i_context);
        % Compute statistic
        confidence.context(s,i_context)= mean(data.con(indx)); 
    end
 
    % AVERAGE CONFIDENCE BY COHERENCE X CONTEXT
    data.zcon= zscore(data.con);
    % Loop through coherences
    for i_stimulus= 1:4               
        % Loop through partners
        for i_context= 1:4
            % Identify trials
            indx= find(data.cohcat==i_stimulus & data.context==i_context);
            % Compute statistic
            confidence.stimulusXcontext(i_stimulus,i_context,s)= mean(data.zcon(indx));   
        end  
    end                        

    % Specify data
    indx     = (data.context~=5); % exclude hidden partner
    c_con    = data.con(indx); % confidence
    c_stimulus = zscore(data.cohcat(indx)-2.5); % coherence
    c_context = zscore(data.context(indx)-2.5); % context 
    c_rt1    = zscore(log(data.rt1(indx))); % choice RT
    c_choice    = zscore(data.choice(indx)-.5); % choice
    c_direction    = zscore(data.right(indx)-.5); % direction
    c_marker    = zscore(data.markini(indx).*10-4); % marker start position
    % predictors
    X = [c_stimulus;
         c_context;
         c_stimulus.*c_context;
         c_rt1;
         c_choice;
         c_direction;
         c_marker;
         ]';
    % outcome
    Y = 7-c_con;
    % run regression
    [B,~,STATS] = mnrfit(X,Y,'model','ordinal','link','probit');
    % output
    beta.confidence(s,:) = B(end-size(X,2)+1:end)';
        
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
my_data= confidence.stimulus;
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
set(gca,'XTick',1:4);
set(gca,'YTick',[2:1:6]);
ylim([2 6]);
xlim([0 length(muz)+1]);
set(gca,'FontSize',axisFS,'LineWidth',lw);
xlabel('coherence','FontSize',labelFS);
ylabel('confidence','FontSize',labelFS);
print('-djpeg','-r300',['Figures',filesep,'Figure2A']);

%% FIGURE 2B
% specifications
figure('color',[1 1 1]);
jitter=.5;
ms= 20;
dcol= [0 0 0];
axisFS= 34;
labelFS= 44;
lw= 4;
% statistics
my_data= confidence.context;
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
set(gca,'XTick',1:size(my_data,2),'XTickLabel',{'1','2','3','4','?'});
set(gca,'YTick',[2:1:6]);
ylim([2 6]);
xlim([0 length(muz)+1]);
set(gca,'FontSize',axisFS,'LineWidth',lw);
xlabel('context','FontSize',labelFS);
ylabel('confidence','FontSize',labelFS);
print('-djpeg','-r300',['Figures',filesep,'Figure2B']);

%% FIGURE 2C
% specifications
figure('color',[1 1 1]);
axisFS= 34;
labelFS= 44;
lw= 4;
% statistics
my_data= confidence.stimulusXcontext;
my_data= mean(my_data,3);
tmp= zeros(5,5); % padding / ignore hidden partner
tmp(1:4,1:4)= my_data(1:4,1:4);
p=pcolor(tmp);
set(p,'LineWidth',4);
colormap('parula');
set(gca,'Ydir','normal');
set(gca,'YTick',1.5:4.5,'YTickLabel',{'1','2','3','4'});
set(gca,'XTick',1.5:4.5,'XTickLabel',{'1','2','3','4'});
set(gca,'FontSize',axisFS,'LineWidth',lw);
axis square;
xlabel('coherence','FontSize',labelFS);
ylabel('context','FontSize',labelFS);
print('-djpeg','-r300',['figures',filesep,'Figure2C']);