The script is compatible with MATLAB R2021a and newer versions.

**runPipeline_1.m:**
Specify the number of channels and the folders containing multichannel images (each channel must be placed in a separate directory). Define segmentation settings by selecting:
the channel used for segmentation
the channel(s) from which fluorescence values are extracted

**segmentation parameters**

Example — Case 1 (segmentation of nuclei and chloroplasts separately):
Parameters used to achieve optimal segmentation:

Nuclei:
backgroundOffset = 1
adaptiveSensitivity = 0.6
adaptiveNeighbourhood = 11
howround = 4
sizeMin = 5, sizeMax = 10000

Chloroplasts:
backgroundOffset = 1
adaptiveSensitivity = 0.6
adaptiveNeighbourhood = 3
howround = 20
sizeMin = 5, sizeMax = 2000

Cytoplasm:
Defined as the inverse mask of the combined nuclei and chloroplast masks.
backgroundOffset = 1 (for both segmentation channels)
adaptiveSensitivity = 0.6 (both channels)
adaptiveNeighbourhood = 11 (mKO2) and 3 (Venus)
howround = 20 (both channels)
sizeMin = 5, sizeMax = 10000 (both channels)

Example — Case 2 (segmentation of nuclei):
backgroundOffset = 20
adaptiveSensitivity = 0.01
adaptiveNeighbourhood = 11
howround = 20
sizeMin = 25, sizeMax = 200

**runSegmentation.m:**
for segmentation of remaining pixels, uncomment lines 443-446: 
% if segmentation needs to be inverted (0s become 1s and vice versa)
for ii = 1:numel(masks)
    masks{ii} = ~masks{ii};
end
