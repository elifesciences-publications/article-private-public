% Bang et al (2020) Private-public mappings in human prefrontal cortex
%
% Reproduces Figure 3-figure supplement 1
%
% Visualises ROI condition estimates (obtained from GLM2 used for RSA) 
% and compares full and reduced models of ROI activity (group-average or
% mixed-effects approach)
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
scanDir= [repoBase,fs,'Data',fs,'fMRI',fs,'ROI_ConditionEstimates'];

% Add customn functions
addpath('Functions');

% ROIs
my_ROIs= {'dACC','pgACC','FPl'};

%% -----------------------------------------------------------------------
%% VISUALISE ROI CONDITION ESTIMATES
% Loop through ROIs
for i_roi= 1:3;
    % Specification
    figure('color',[1 1 1]);
    jitter=.5;
    ms= 14;
    dcol= [0 0 0];
    axisFS= 34;
    labelFS= 44;
    titleFS= 44;
    barFS= 30;
    lw= 4;
    % Load ROI data
    load([scanDir,fs,my_ROIs{i_roi},'_ConditionEstimates.mat']);
    my_data= condEstimate;
    % Average across subjects
    for i_sbj= 1:n_subjects;
        tmp= my_data(:,:,i_sbj);
        my_data(:,:,i_sbj)= (tmp-mean(tmp(:)))./std(tmp(:));
    end
    my_data= mean(my_data,3);
    % Prepare data for plotting
    tmp= zeros(5,5); % padding / ignore hidden partner
    tmp(1:4,1:4)= my_data(1:4,1:4);
    % Plot data
    p=pcolor(tmp);
    set(p,'LineWidth',lw);
    colormap('parula');
    set(gca,'Ydir','normal');
    set(gca,'YTick',1.5:4.5,'YTickLabel',{'1','2','3','4'});
    set(gca,'XTick',1.5:4.5,'XTickLabel',{'1','2','3','4'});
    set(gca,'FontSize',axisFS,'LineWidth',lw);
    axis square;
    xlabel('coherence','FontSize',labelFS);
    ylabel('context','FontSize',labelFS);
    title(my_ROIs{i_roi},'FontWeight','normal');
    c=colorbar;
    set(c,'YTick',-.3:.1:.3,'LineWidth',lw,'FontSize',barFS);
    caxis([-.3 .3]);
    print('-djpeg','-r300',['Figures',filesep,'Figure3_S1A_',my_ROIs{i_roi}]);
end


%% -----------------------------------------------------------------------
%% ESTIMATE GROUP-AGGREGATE MODEL
% Create predictors
for i_p= 1:4
    for i_c= 1:4
        % coherence
        k1_mat(i_p,i_c)= (i_c-2.5);
        k2_mat(i_p,i_c)= (i_c-2.5).^2;
        % contex
        c1_mat(i_p,i_c)= (i_p-2.5);
        c2_mat(i_p,i_c)= (i_p-2.5).^2;
    end
end
k1= zscore(k1_mat(:));
k2= zscore(k2_mat(:));
c1= zscore(c1_mat(:));
c2= zscore(c2_mat(:));
% Perform analysis for each ROI
for i_roi= 1:3;
    % Load ROI data
    load([scanDir,fs,my_ROIs{i_roi},'_ConditionEstimates.mat']);
    my_data= condEstimate;
    % Average across subjects
    for i_sbj= 1:n_subjects;
        tmp= my_data(:,:,i_sbj);
        my_data(:,:,i_sbj)= (tmp-mean(tmp(:)))./std(tmp(:));
    end
    my_data= mean(my_data,3);
    % Perform analysis (F: full model; R: reduced model);
    y= my_data(:);
    xF= [k1 k2 c1 c2];
    xR= [k1 c1];
    mdlF= fitlm(xF,y);
    mdlR= fitlm(xR,y);
    betaF(i_roi,:)= mdlF.Coefficients.Estimate(2:end);
    sigzF(i_roi,:)= mdlF.Coefficients.pValue(2:end);
    R2AF(i_roi,:)= mdlF.Rsquared.Adjusted;
    R2AR(i_roi,:)= mdlR.Rsquared.Adjusted;
end

%% -----------------------------------------------------------------------
%% VISUALISE GROUP-AGGREGATE COEFFICENTS -- FOR REPOSITORY
% Specification
figure('color',[1 1 1]);
jitter=.5;
ms= 14;
dcol= [0 0 0];
axisFS= 34;
labelFS= 44;
titleFS= 44;
barFS= 26;
lw= 4;
% Prepare data for plotting
tmp= zeros(4,5); % padding / ignore hidden partner
tmp(1:3,1:4)= flipud(betaF(1:3,1:4));
% Plot data
p=pcolor(tmp);
set(p,'LineWidth',lw);
colormap('parula');
% set(gca,'Ydir','normal');
set(gca,'XTick',1.5:1:4.5,'XTickLabel',{'K','K2','C','C2'});
set(gca,'YTick',1.5:1:3.5,'YTickLabel',{'FPl','pgACC','dACC'});
set(gca,'FontSize',axisFS,'LineWidth',lw);
c=colorbar;
set(c,'YTick',-.05:.05:.2,'LineWidth',lw,'FontSize',barFS);
caxis([-.05 .2]);
print('-djpeg','-r300',['Figures',filesep,'Figure3_S1B1']);

%% -----------------------------------------------------------------------
%% VISUALISE GROUP-AGGREGATE MODEL COMPARISON -- FOR REPOSITORY
% Specification
figure('color',[1 1 1]);
jitter=.5;
ms= 14;
dcol= [0 0 0];
axisFS= 44;
labelFS= 44;
titleFS= 44;
barFS= 30;
lw= 4;
% Prepare data for plotting
my_data= R2AF-R2AR;
my_data= flipud(my_data);
% Plot data
hold on;
plot([0 0],[0 4],'k-','LineWidth',lw);
for i_roi= 1:3;
    plot([-.25 .45],[i_roi i_roi],'k--','LineWidth',lw/2);
    plot(my_data(i_roi),i_roi,'ko','MarkerFaceColor','m','MarkerSize',20)
end
set(gca,'YTick',1:3,'YTickLabel',{'FPl','pgACC','dACC'});
set(gca,'XTick',-.2:.2:.4);
set(gca,'FontSize',axisFS,'LineWidth',lw);
xlim([-.25 .45]);
ylim([.5 3.5]);
xlabel('full-reduced [adj. R2]','FontSize',labelFS);
print('-djpeg','-r300',['Figures',filesep,'Figure3_S1B2']);

%% -----------------------------------------------------------------------
%% ESTIMATE MIXED-EFFECTS MODEL
% Create predictors
for i_p= 1:4
    for i_c= 1:4
        % coherence
        k1_mat(i_p,i_c)= (i_c-2.5);
        k2_mat(i_p,i_c)= (i_c-2.5).^2;
        % contex
        c1_mat(i_p,i_c)= (i_p-2.5);
        c2_mat(i_p,i_c)= (i_p-2.5).^2;
    end
end
k1= zscore(k1_mat(:));
k2= zscore(k2_mat(:));
c1= zscore(c1_mat(:));
c2= zscore(c2_mat(:));
clear mdlF mdlR;
% Perform analysis for each ROI
for i_roi= 1:3;
    % Load ROI data
    load([scanDir,fs,my_ROIs{i_roi},'_ConditionEstimates.mat']);
    my_data= condEstimate;
    % Prepare variables
    v_roi= [];
    v_s= [];
    v_k1= [];
    v_k2= [];
    v_c1= [];
    v_c2= [];
    % Collate data across subjects
    for i_sbj= 1:n_subjects;
        tmp= my_data(:,:,i_sbj);
        tmp= (tmp-mean(tmp(:)))./std(tmp(:));
        v_roi= [v_roi; tmp(:)];
        v_s= [v_s; ones(16,1).*i_sbj];
        v_k1= [v_k1; k1];
        v_k2= [v_k2; k2];
        v_c1= [v_c1; c1];
        v_c2= [v_c2; c2];      
    end
    % transform to table
    datanames   = {'subject','ROI','k1','k2','c1','c2'};
    datatab     = table(categorical(v_s),v_roi,v_k1,v_k2,v_c1,v_c2,'VariableNames',datanames);
    % specify formulas
    formulaR    = ['ROI ~ 1 + k1 + c1 + (1 + k1 + c1 | subject)'];
    formulaF    = ['ROI ~ 1 + k1 + k2 + c1 + c2 + (1 + k1 + k2 + c1 + c2 | subject)'];
    % fit model
    mdlF        = fitlme(datatab,formulaF);
    mdlR        = fitlme(datatab,formulaR);
    betaF(i_roi,:)= mdlF.Coefficients.Estimate(2:end);
    sigzF(i_roi,:)= mdlF.Coefficients.pValue(2:end);
    R2AF(i_roi,:)= mdlF.Rsquared.Adjusted;
    R2AR(i_roi,:)= mdlR.Rsquared.Adjusted;
end

%% -----------------------------------------------------------------------
%% VISUALISE MIXED-EFFECTS COEFFICENTS -- FOR REPOSITORY
% Specification
figure('color',[1 1 1]);
jitter=.5;
ms= 14;
dcol= [0 0 0];
axisFS= 34;
labelFS= 44;
titleFS= 44;
barFS= 26;
lw= 4;
% Prepare data for plotting
tmp= zeros(4,5); % padding / ignore hidden partner
tmp(1:3,1:4)= flipud(betaF(1:3,1:4));
% Plot data
p=pcolor(tmp);
set(p,'LineWidth',lw);
colormap('parula');
% set(gca,'Ydir','normal');
set(gca,'XTick',1.5:1:4.5,'XTickLabel',{'K','K2','C','C2'});
set(gca,'YTick',1.5:1:3.5,'YTickLabel',{'FPl','pgACC','dACC'});
set(gca,'FontSize',axisFS,'LineWidth',lw);
c=colorbar;
set(c,'YTick',-.05:.05:.2,'LineWidth',lw,'FontSize',barFS);
caxis([-.05 .2]);
print('-djpeg','-r300',['Figures',filesep,'Figure3_S1C1']);

%% -----------------------------------------------------------------------
%% VISUALISE GROUP-AGGREGATE MODEL COMPARISON -- FOR REPOSITORY
% Specification
figure('color',[1 1 1]);
jitter=.5;
ms= 14;
dcol= [0 0 0];
axisFS= 44;
labelFS= 44;
titleFS= 44;
barFS= 30;
lw= 4;
% Prepare data for plotting
my_data= R2AF-R2AR;
my_data= flipud(my_data);
% Plot data
hold on;
plot([0 0],[0 4],'k-','LineWidth',lw);
for i_roi= 1:3;
    plot([-.25 .45],[i_roi i_roi],'k--','LineWidth',lw/2);
    plot(my_data(i_roi),i_roi,'ko','MarkerFaceColor','m','MarkerSize',20)
end
set(gca,'YTick',1:3,'YTickLabel',{'FPl','pgACC','dACC'});
set(gca,'XTick',.01:.02:.05);
set(gca,'FontSize',axisFS,'LineWidth',lw);
xlim([.005 .055]);
ylim([.5 3.5]);
xlabel('full-reduced [adj. R2]','FontSize',labelFS);
print('-djpeg','-r300',['Figures',filesep,'Figure3_S1C2']);