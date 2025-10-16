% dataLoad.m
% USER IMPORTANT INFORMATION: 5 stars ***** means that the code needs adjustment:

% checking that the number of files is the same in all input folders
if numCH == 2
    if isequal(numel(FilesCH00),numel(FilesCH01))
        numFiles = numel(FilesCH00);
    else
        error("different number of files found in the input folders")
    end
elseif numCH == 3
    if isequal(numel(FilesCH00),numel(FilesCH01),numel(FilesCH02))
        numFiles = numel(FilesCH00);
    else
        error("different number of files found in the input folders")
    end
elseif numCH == 4
    if isequal(numel(FilesCH00),numel(FilesCH01),numel(FilesCH02),numel(FilesCH03))
        numFiles = numel(FilesCH00);
    else
        error("different number of files found in the input folders")
    end
end


   