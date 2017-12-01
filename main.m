%% main.m
% Tyler Glass
% Code for running f19 lobar analysis

%% Initialize Workspace
clear; clc; close all
home = pwd;
addpath('./functions') % Add path for f19 processing functions

%% Data for First and Last PFP Times
patientNumbers = [2; 3; 4; 5; 7; 8; 9; 10; 11; 12; 13; 14; 15; 16; 17; 18; 19; 20; 21; 22; 24; 25];
first_PFP      = [2; 1; 2; 2; 1; 2; 2;  2;  2;  2;  2;  2;  2;  2;  2;  2;  2;  2;  2;  2;  2;  2];
last_PFP       = [7; 5; 7; 7; 7; 7; 6;  6;  6;  7;  6;  5;  7;  6;  6;  7;  6;  6;  6;  6;  4;  6]; % updated 11/11/2017

all = [2;3;4;5;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;24;25];
normals = [2;3;4;5;11;15;16;17;19;21];
mild = [9;10;13;18;20;24;25];
moderate = [7;8;12;14;22];

%% Selected Image Data
f19_pixel_size = 0.625; % cm
f19_slice_thickness = 1.5; % cm
anatomic_pixel_size = 0.3125; % cm
anatomic_slice_thickness = 1.5; % cm

%% Loop Through all F19 Patients
tic

patientNumbers = [2]; % edit this

for i=1:length(patientNumbers)
    %% Load F19 Ventilation Data
    cd('G:\2017-Glass\mim\f19_ventilation_segmentations')
    filename = strcat('0509-',num2str(patientNumbers(i),'%03d'),'.mat');
    load(filename);
    moving = imresize(roi,[128,128]); % f19 is moving
    f19 = image;
    ventilation = roi;
    cd(home)

    %% Load Anatomic MRI and Lobar Segmentations
    cd('G:\2017-Glass\mim\inspiration_lobar_segmentations')
    filename = strcat('0509-',num2str(patientNumbers(i),'%03d'),'.mat');
    load(filename)
    fixed = imresize(WholeLung, [128,128]); % anat is fixed
    fixed(:,:,16:18) = 0; % make fixed the same size as moving functional
    inspirationMRI = MR1;
    LeftLowerLobeSegs(:,:,:,i) = LeftLowerLobe;
    LeftUpperLobeSegs(:,:,:,i) = LeftUpperLobe;
    RightLowerLobeSegs(:,:,:,i) = RightLowerLobe;
    RightMiddleLobeSegs(:,:,:,i) = RightMiddleLobe;
    RightUpperLobeSegs(:,:,:,i) = RightUpperLobe;
    cd(home)
    
    %% Stretch F19 Ventilation Segmentation for ApexBase and PosteriorAnterior Changes
    movingABstretch = Stretch_F19_ApexBase(moving,fixed);
    
    %% Register F19 Moving to Inspiration 1H Fixed
    [optimizer, metric] = imregconfig('monomodal');
    f19_MOVING = imregister(uint8(moving), uint8(fixed), 'affine', optimizer, metric);
      
    %% Plot Registered Results
    figure(1);clf
    plot_title = sprintf('Subject %i', patientNumbers(i));

    subplot(4,4,1)
    imshowpair(fixed(:,:,2), f19_MOVING(:,:,2),'Scaling','joint');
    title(plot_title)
    subplot(4,4,2)    
    imshowpair(fixed(:,:,3), f19_MOVING(:,:,3),'Scaling','joint');
    subplot(4,4,3)    
    imshowpair(fixed(:,:,4), f19_MOVING(:,:,4),'Scaling','joint');
    subplot(4,4,4)
    imshowpair(fixed(:,:,5), f19_MOVING(:,:,5),'Scaling','joint');
    subplot(4,4,5)
    imshowpair(fixed(:,:,6), f19_MOVING(:,:,6),'Scaling','joint');
    subplot(4,4,6)
    imshowpair(fixed(:,:,7), f19_MOVING(:,:,7),'Scaling','joint');
    subplot(4,4,7)
    imshowpair(fixed(:,:,8), f19_MOVING(:,:,8),'Scaling','joint');
    subplot(4,4,8)
    imshowpair(fixed(:,:,9), f19_MOVING(:,:,9),'Scaling','joint');
    subplot(4,4,9)
    imshowpair(fixed(:,:,10), f19_MOVING(:,:,10),'Scaling','joint');
    subplot(4,4,10)
    imshowpair(fixed(:,:,11), f19_MOVING(:,:,11),'Scaling','joint');
    subplot(4,4,11)
    imshowpair(fixed(:,:,12), f19_MOVING(:,:,12),'Scaling','joint');
    subplot(4,4,12)
    imshowpair(fixed(:,:,13), f19_MOVING(:,:,13),'Scaling','joint');
    subplot(4,4,13)
    imshowpair(fixed(:,:,14), f19_MOVING(:,:,14),'Scaling','joint');
    subplot(4,4,14)
    imshowpair(fixed(:,:,15), f19_MOVING(:,:,15),'Scaling','joint');
    subplot(4,4,15)
    imshowpair(fixed(:,:,16), f19_MOVING(:,:,16),'Scaling','joint');
    subplot(4,4,16)
    imshowpair(fixed(:,:,17), f19_MOVING(:,:,17),'Scaling','joint'); 
    
end

%% Print Elapsed Processing Time
toc