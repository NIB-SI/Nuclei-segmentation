% runStats.m
%
% calculating fluorescence statistics on whole images and on the segmented
% objects in each image

%% run the analysis

switch numel(fluorescenceFrom)
    case 1
        for jj = 1:numFiles
            jj
            % same for sensor channel
            image_1 = imread(strcat(fluorescenceFrom{1}(jj).folder,'\',fluorescenceFrom{1}(jj).name));
            image_gray_1 = im2gray(image_1);
            % convert to double so that multiplying with mask is possible
            image_double_1 = im2double(image_gray_1).*255;
            image_fluorescence = image_double_1.*masks{jj};
            
            % NORMALIZATION/OUTPUT
            % here the mean ratios per figure are saved
            % calculate the mean ratio, again we need to normalize only to the part
            % of the image that is the segmented object
            normalizedFluorescence{jj} = numel(image_double_1)*mean(mean(image_fluorescence))/figureStats.AreaObjects(jj);
            allValues_fluorescence = image_fluorescence(image_fluorescence ~= 0);
            histogramFluorescence{jj} = histcounts(allValues_fluorescence,[-0.5:1:255.5]);
            
            
            % PLOTTING
            % series of images to illustrate, what was done
            % ***** uncomment this if you want plotting and saving the images
            FigH = figure('Position', get(0, 'Screensize'));
            set(FigH, 'Visible', 'off');
            subplot(2,1,1)
            imshow(image_double_1)
            caxis([0 30])
            title('Scaled image')
            subplot(2,1,2)
            image(image_fluorescence,'CDataMapping','scaled')
            axis equal
            colormap(mymap_red)
            colorbar
            % ***** check the histogram and then define the color axis
            % hist(image_double_1(:),100)
            caxis([0 30])
            title('scale image in segmented object')
            % to show the figure
            %     figure(FigH)
            
            % select path and save
            % we select the printing resolution
            iResolution = 300;
            % we select to crop or not the figure
            set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
            % saving full screen size
            F    = getframe(FigH);
            imwrite(F.cdata, strcat(pathResults, FilesCH00(jj).name, '_fluorescence','.jpeg'), 'jpeg')
            
            % PER OBJECT
            % OUTPUT
            % her the ratio per all nuclei per each figure are saved
            grayscaleObjects = regionprops(masks{jj},image_fluorescence,{'Centroid', 'MeanIntensity'});
            objectFluorescence{jj} = grayscaleObjects;
            
        end
    case 2
        for jj = 1:numFiles
            jj
            % read in the image and convert to grayscale for the normalization
            % channel
            image_1 = imread(strcat(fluorescenceFrom{1}(jj).folder,'\',fluorescenceFrom{1}(jj).name));
            image_gray_1 = im2gray(image_1);
            % convert to double so that multiplying with mask is possible
            image_double_1 = im2double(image_gray_1).*255;
            
            image_2 = imread(strcat(fluorescenceFrom{2}(jj).folder,'\',fluorescenceFrom{2}(jj).name));
            image_gray_2 = im2gray(image_2);
            % convert to double so that multiplying with mask is possible
            image_double_2 = im2double(image_gray_2).*255;
            
            % calculate the ratio between the images
            % division comes first, then the application of mask
            image_rat = image_double_1./image_double_2;
            image_ratio = image_rat.*masks{jj};
            % OPTIONAL image: to show what the ratio looks like
            %     figure(1)
            %     imshow(image_ratio)
            
            % NORMALIZATION/OUTPUT
            % here the mean ratios per figure are saved
            % calculate the mean ratio, we need to normalize only to the part
            % of the image that is the obejcts
            normalizedFluorescence{jj} = numel(image_double_1)*mean(mean(image_ratio))/figureStats.AreaObjects(jj);
            allValues_fluorescence = image_fluorescence(image_fluorescence ~= 0);
            histogramFluorescence{jj} = histcounts(allValues_fluorescence,[-0.5:1:255.5]);           
            
            % PLOTTING
            % series of images to illustrate, what was done
            % ***** uncomment this if you want plotting and saving the images
            FigH = figure('Position', get(0, 'Screensize'));
            set(FigH, 'Visible', 'off');
            subplot(2,2,1)
            imshow(image_gray_1)
            caxis([0 30])
            title('Scaled 1st Channel')
            subplot(2,2,2)
            imshow(image_gray_2)
            caxis([0 30])
            title('Scaled 2nd Channel')
            subplot(2,2,3)
            image(image_rat,'CDataMapping','scaled')
            axis equal
            colormap(gray)
            % ***** check the histogram and then define the color axis
            % hist(image_rat(:),100)
            caxis([0 1])
            title('RATIO')
            subplot(2,2,4)
            image(image_ratio,'CDataMapping','scaled')
            axis equal
            colormap(mymap_red)
            colorbar
            % ***** check the histogram and then define the color axis
            % hist(image_ratio(:),100)
            caxis([0 1])
            title('RATIO in objects')
            % to show the figure
            %     figure(FigH)
            
            % select path and save
            % we select the printing resolution
            iResolution = 300;
            % we select to crop or not the figure
            set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
            % saving full screen size
            F    = getframe(FigH);
            imwrite(F.cdata, strcat(pathResults, FilesCH00(jj).name, '_ratio','.jpeg'), 'jpeg')
            
            % PER segmented object
            % OUTPUT
            % here the ratio per all segmented objects per each figure are saved
            grayscaleObjects = regionprops(masks{jj},image_ratio,{'Centroid', 'MeanIntensity'});
            objectFluorescence{jj} = grayscaleObjects;
            
        end   
end

savefile = strcat(pathResults,'analysisResults.mat');
% here we define all OUTPUTs to save
save(savefile, 'objectFluorescence', 'normalizedFluorescence');


%% PLOTTING

% PLOTTING the results PER FIGURE
% it is very important that the figures that are analyzed are in a sensible
% order, because the points on the plot are in the same order as the
% figures that were analyzed! 
normFluo = cell2mat(normalizedFluorescence);
FigH = figure('Position', get(0, 'Screensize'));
set(FigH, 'Visible', 'off');
plot(normFluo,'o', 'MarkerSize', 20,'MarkerFaceColor', 'b')
set(gca,'FontSize',20)
ylim([0 max(normFluo)+1])
iResolution = 300;
% we select to crop or not the figure
set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
% saving full screen size
F    = getframe(FigH);
imwrite(F.cdata, strcat(pathResults, 'perFigure','.jpeg'), 'jpeg')


% PLOTTING the results PER OBJECT
% plot without ordering, plot a distribution over all segmented objects as
% boxplots
FigH = figure('Position', get(0, 'Screensize'));
set(FigH, 'Visible', 'off');
hold on
maxValue = 0;
for jj = 1:numFiles
    jj
    tempy = [objectFluorescence{jj}.MeanIntensity];
    tempx = ones(numel(tempy))*jj;
    scatter(tempx, tempy, 100,'k', 'filled')
    if numel(tempy) > 0
        maxValue(jj) = max(tempy);
    end
end
set(gca,'FontSize',20)
ylim([0 max(maxValue)+1])
hold off
iResolution = 300;
% we select to crop or not the figure
set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
% saving full screen size
F    = getframe(FigH);
imwrite(F.cdata, strcat(pathResults, 'perObject','.jpeg'), 'jpeg')

% saving the histograms 
dataForExcel = cell2mat(histogramFluorescence');
excelFilename = 'histogramFluorescence.xlsx';
writematrix(dataForExcel, excelFilename);




