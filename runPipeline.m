% runPipeline.m
% run the whole analysis script, delete any parts of the script that are
% not necessary
% !!!!! all the scripts need to be present in the folder you are working in
% !!!!!
%% clear everything before beginning
clear all
close all
% load the colormap
load('MyColormap_red.mat')
%% defining all paths

% select the absolute paths to the microscopic images that need analysing (Matlab is bad with relative paths)
% IMPORTANT: the images need to be in tif format 
% IMPORTANT: the images need to have the same names, except for the last
% four letter (channel number)
% ***** How many different channels do you have? (currently the code works
% for between 2 and 4 channels)
numCH = 4;
% ***** INPUT: here absolute paths to the microscopy images are defined
% ***** add and delete channel folders as necessary
pathCH00 = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\ch00_EGFP\';
%pathCH00 = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\ch01_Venus\';
pathCH02 = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\ch02_mKO2\';
pathCH01 = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\Segmentation\ch02_mKO2\'
pathCH03 = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\Segmentation\ch01_Venus\';
FilesCH00 = dir(strcat(pathCH00,'*.tif'));
FilesCH01 = dir(strcat(pathCH01,'*.tif'));
FilesCH02 = dir(strcat(pathCH02,'*.tif'));
FilesCH03 = dir(strcat(pathCH03,'*.tif'));

% ***** define path to save the overlayed images
mkdir Fusion1
pathFusion = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\Fusion_0_1';

% ***** DEFINE SEGMENTATION RESULTS path
mkdir Segmented1
pathSegmented = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\Segmented_0_1';


% ***** DEFINE STATS ANALYSIS FOLDER RESULTS
mkdir Results1
pathResults = 'M:\confocal_Stellaris_5\Valentina\Unmixing\Channel_unmixing\Results_0_1';

%% LOADING THE DATA
% load the data
dataLoad

%% defining all parameters for the analysis

% ***** DEFINE SEGMENTATION OPTIONS
% the choice of which channels will be used for segmentation
    % either one of two channels can be chosen
%segmentFrom = {FilesCH03};
segmentFrom = {FilesCH01, FilesCH03};
% if two channels are used for segmentation, during the image processing
% the 'intersection' or the 'union'logical operation can be used: 
    % intersection - the segmented object present in both channels
    % union . the segmented object present in at least one channel
    % if a single channel is used for segmentation, this factor is ignored
segmentLogical = 'union';
% do we want to filter out non-round objects
    % 1 - yes, filter out nonround
    % 0 - no, do not filter out non-round
% the choice of which channels will be used for fluorescence magnitude
% analysis
    % either one of two channels can be chosen
    % if two channels are chosen, a ratio is calculated and the first
    % channel is divided by the second channel
%fluorescenceFrom = {FilesCH01, FilesCH00};
fluorescenceFrom = {FilesCH02};
nonround = 1;


% ***** DEFINE SEGMENTATION PARAMETERS
% backgroundThreshold - deletes everything to the left of the histogram peak + some offset
    % normally, values between 0 and 10 makes sense, trial and error
%backgroundOffset = 1;
    % if two channels are used, then two values need to be given
backgroundOffset_2 = [1,1];
% adaptiveSensitivity - how much local noise stays in the image, higher
% number means more noise remains
    % values around 0.6 generally work
%adaptiveSensitivity = 0.6;
    % if two channels are used, then two values need to be given
adaptiveSensitivity_2 = [0.6,0.6];
% adaptiveNeighbourhood - size of the neighbourhood for local adaptive 
% filter, large number means larger areas, lower numbers allow better
% separation between small objects
    % values between 11 and 21 generally work well, but this depends on the
    % object and magnification used
%adaptiveNeighbourhood = 3;
    % if two channels are used, then two values need to be given
adaptiveNeighbourhood_2 = [11,3];
% if filtering round nonround objects, this is the threshold for the filter
% values between 1-4 generally work well
howround = 20;
% size filtering of objects allows elimination of all objects that are
% either too small of too large to be the object of interest. The choice
% should be made after visual observation of the objects in the microscopy
% images.
sizeMin = 5;
sizeMax = 10000;
    
%% run the rest of the scripts for the pipeline

% fusion image visualization
fusionVis
% run the segmentation
runSegmentation
% calculate the statistics
runStats
