%% main.m
% Tyler Glass
% Code for running f19 lobar analysis

%% Initialize Workspace
clear; clc; close all
home = pwd;
addpath('./functions') % Add path for f19 processing functions

%% Select Patient Numbers
normals = [2;3;4;5;15;16;17;19;26;31;37;39;40];
patientNumbers = 5;

%% Selected Image Data
f19_pixel_size = 0.625; % cm
f19_slice_thickness = 1.5; % cm
anatomic_pixel_size = 0.3125; % cm
anatomic_slice_thickness = 1.5; % cm

%% Loop Through all F19 Patients
for i=1:length(patientNumbers)
    
    %% Load F19 Ventilation Data
    cd('./data/f19_ventilation_segmentations')
    filename = strcat('0509-',num2str(patientNumbers(i),'%03d'),'.mat');
    load(filename);
    fixed = imresize(roi,[128,128]); % fixed = f19
    f19 = image;
    ventilation = roi;
    cd(home)

    %% Load Anatomic MRI and Lobar Segmentations
    cd('./data/inspiration_lobar_segmentations')
    filename = strcat('0509-',num2str(patientNumbers(i),'%03d'),'.mat');
    load(filename)
    moving = imresize(WholeLung, [128,128]); % moving = 1h
    moving(:,:,16:18) = 0; % match image size to f19
    
    % load anatomic MRI
    inspirationMRI = MR1;
    inspirationMRI(:,:,16:18) = 0;
    % load lobar segs
    LeftLowerLobeSegs(:,:,:,i) = LeftLowerLobe;
    LeftUpperLobeSegs(:,:,:,i) = LeftUpperLobe;
    RightLowerLobeSegs(:,:,:,i) = RightLowerLobe;
    RightMiddleLobeSegs(:,:,:,i) = RightMiddleLobe;
    RightUpperLobeSegs(:,:,:,i) = RightUpperLobe;
    % match image size to f19
    LeftLowerLobe   = imresize(LeftLowerLobe, [128,128]);
    LeftUpperLobe   = imresize(LeftUpperLobe, [128,128]);
    RightLowerLobe  = imresize(RightLowerLobe, [128,128]);
    RightMiddleLobe = imresize(RightMiddleLobe, [128,128]);
    RightUpperLobe  = imresize(RightUpperLobe, [128,128]);
    % match image size to f19
    LeftLowerLobe(:,:,16:18) = 0;
    LeftUpperLobe(:,:,16:18) = 0;
    RightLowerLobe(:,:,16:18) = 0;
    RightMiddleLobe(:,:,16:18) = 0;
    RightUpperLobe(:,:,16:18) = 0;
    
    cd(home)
    
    %% Compute Registration Transform
    [optimizer, metric] = imregconfig('monomodal');
    tform = imregtform(uint8(moving), uint8(fixed), 'affine', optimizer, metric); % moving = 1h, fixed = f19

    %% Apply transform to 1H data
    inspirationMRI_t = imwarp(inspirationMRI,    tform, 'OutputView', imref3d(size(fixed)));
    WholeLung_t = imwarp(moving,    tform, 'OutputView', imref3d(size(fixed)));
    LLL_t = imwarp(LeftLowerLobe,   tform, 'OutputView', imref3d(size(fixed)));
    LUL_t = imwarp(LeftUpperLobe,   tform, 'OutputView', imref3d(size(fixed)));
    RLL_t = imwarp(RightLowerLobe,  tform, 'OutputView', imref3d(size(fixed)));
    RML_t = imwarp(RightMiddleLobe, tform, 'OutputView', imref3d(size(fixed)));
    RUL_t = imwarp(RightUpperLobe,  tform, 'OutputView', imref3d(size(fixed)));
    
    %% Compute Map of Non-Overlapping Segmentation Areas
    A = fixed; B = WholeLung_t;
    DiffMapPostReg = (A+2*B)-(3*(A.*B));
    
    
    %% Show figure to confirm registration results
    figure(1);clf
    f19_timestep = 5;
    slice1 = 4;
    slice2 = 6;
    slice3 = 8;
    slice4 = 10;
    slice5 = 12;
    
    subplot(5,5,1)
    imshow(fixed(:,:,slice1),[])
    title(strcat('f19 seg - ' , string(patientNumbers(i))))
    subplot(5,5,2)
    imshow(WholeLung_t(:,:,slice1),[])
    title('1h seg')
    subplot(5,5,3)
    imshow(DiffMapPostReg(:,:,slice1),[])
    title('Diff Map')
    subplot(5,5,4)
    imshow(RLL_t(:,:,slice1),[])
    title('RLL seg')
    subplot(5,5,5)
    imshow(LUL_t(:,:,slice1),[])
    title('LUL seg')
    
    subplot(5,5,6)
    imshow(fixed(:,:,slice2),[])
    subplot(5,5,7)
    imshow(WholeLung_t(:,:,slice2),[])
    subplot(5,5,8)
    imshow(DiffMapPostReg(:,:,slice2),[])
    subplot(5,5,9)
    imshow(RLL_t(:,:,slice2),[])
    subplot(5,5,10)
    imshow(LUL_t(:,:,slice2),[])
    
    subplot(5,5,11)
    imshow(fixed(:,:,slice3),[])
    subplot(5,5,12)
    imshow(WholeLung_t(:,:,slice3),[])
    subplot(5,5,13)
    imshow(DiffMapPostReg(:,:,slice3),[])
    subplot(5,5,14)
    imshow(RLL_t(:,:,slice3),[])
    subplot(5,5,15)
    imshow(LUL_t(:,:,slice3),[])
    
    subplot(5,5,16)
    imshow(fixed(:,:,slice4),[])
    subplot(5,5,17)
    imshow(WholeLung_t(:,:,slice4),[])
    subplot(5,5,18)
    imshow(DiffMapPostReg(:,:,slice4),[])
    subplot(5,5,19)
    imshow(RLL_t(:,:,slice4),[])
    subplot(5,5,20)
    imshow(LUL_t(:,:,slice4),[])
    
    subplot(5,5,21)
    imshow(fixed(:,:,slice5),[])
    subplot(5,5,22)
    imshow(WholeLung_t(:,:,slice5),[])
    subplot(5,5,23)
    imshow(DiffMapPostReg(:,:,slice5),[])
    subplot(5,5,24)
    imshow(RLL_t(:,:,slice5),[])
    subplot(5,5,25)
    imshow(LUL_t(:,:,slice5),[])
    
        
    
end