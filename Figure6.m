% Bang et al (2020) Private-public mappings in human prefrontal cortex
%
% Reproduces Figure 6B
%
% Visualises ROI EDIs and performs associated statistical tests
%
% Data also contains split-data RDMs (sdRDMs) underlying EDI calculation
% as well as run-specific EDIs and sdRDMs
%
% Statistical tests can be reproduced by applying one-tailed sign-rank test
% to EDIs: e.g. [SIGNIFICANCE]= signrank(EDIs{roi}(:,space),0,'tail','right')
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
dataDir= [repoBase,fs,'Data',fs,'Behaviour',fs,'Scan'];
scanDir= [repoBase,fs,'Data',fs,'fMRI',fs,'ROI_RSA'];

% Add customn functions
addpath('Functions');

% ROIs
my_ROIs= {'dACC','pgACC','FPl'};

%% -----------------------------------------------------------------------
%% ANALYSIS

% Loop through subjects
for s= 1:n_subjects;
    % Loop through ROIs
    for i_roi= 1:length(my_ROIs);
        % Load stimulus EDI
        load([scanDir,fs,'s',num2str(s),'_',my_ROIs{i_roi},'_EDI_coherence.mat']);
        EDIs{i_roi}(s,1)= EDI;
        % Load context EDI
        load([scanDir,fs,'s',num2str(s),'_',my_ROIs{i_roi},'_EDI_context.mat']);
        EDIs{i_roi}(s,2)= EDI;
        % Load full task space EDI
        load([scanDir,fs,'s',num2str(s),'_',my_ROIs{i_roi},'_EDI_full.mat']);
        EDIs{i_roi}(s,3)= EDI;
    end
end

%% -----------------------------------------------------------------------
%% VISUALISATION

% Loop through ROIs
for i_roi= 1:length(my_ROIs);
    % Specification
    figure('color',[1 1 1]);
    jitter=.5;
    ms= 14;
    dcol= [0 0 0];
    axisFS= 34;
    labelFS= 44;
    lw= 4;
    % statistics
    my_data= EDIs{i_roi};
    muz= mean(my_data);
    sem= std(my_data)/sqrt(n_subjects);
    % plot bars
    hold on;
    bar(muz,'FaceColor',[1 1 0],'FaceAlpha',.2,'LineWidth',lw); hold on;
    for i= 1:numel(muz); plot([i i],[muz(i)-sem(i) muz(i)+sem(i)],'k-','LineWidth',lw); end
    plot([0 length(muz)+1],[0 0],'k-','LineWidth',lw);
    % tidy up
    ylim([-0.15 0.45]); 
    set(gca,'YTick',-.1:.1:.4);
    xlim([0 length(muz)+1]);
    set(gca,'Xtick',1:length(muz),'XTickLabel',{'K','C','KxC'});
    set(gca,'FontSize',axisFS,'LineWidth',4);
    xlabel('space','FontSize',labelFS);
    ylabel('EDI','FontSize',labelFS);
    title(my_ROIs{i_roi},'FontSize',labelFS,'FontWeight','normal');
    box('off');
    axis square;
    print('-djpeg','-r300',['Figures',filesep,'Figure6B_',my_ROIs{i_roi}]);
end