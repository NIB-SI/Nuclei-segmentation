% runSegmentation.m
%
% to run the segmentation, you need to first load the data (see loadData.m)

% This code runs the segmentation of small round objects from microscopic
% images. These small round objects can (currently) be either chloroplasts
% or nuclei, depending on where the sensor signals is present. 

switch numel(segmentFrom)
    
    % one channel chosen
    case 1
        
        % loop over all files
        for jj = 1:numFiles
            jj
            % read in each image and convert to grayscale
            image_original_1 = imread(strcat(segmentFrom{1}(jj).folder,'\',segmentFrom{1}(jj).name));
            image_gray_1 = im2gray(image_original_1);
            
            % Background noise removal. 
            % Finds the peak of the histogram and deletes 
            % everything to the left of the peak + backgroundOffset
            [counts,x] = imhist(image_gray_1);
            [i,whereMax] = max(counts);
            image_gray_1(image_gray_1<whereMax+backgroundOffset)=0;
            image_adjust_1 = imadjust(image_gray_1);
            %     figure(1)
            %     imshow(image_gray)
            
            % Adaptive thresholding. the point is to do local thresholding, which
            % can take into account different backgrund in the image. Removal of
            % noise is therefore based on local information.
            %   sensitivity = 0.6 (higher sensitivity means more noise gets in,
            %   lower means less signal, you need to find a good compromise). This
            %   needs to be tested for each batch of images.
            %   neighbourhood size = 11 (lower values separate better between small objects)
            % ***** (try playing with settings a bit for each new microscope dataset)
            T = adaptthresh(image_adjust_1, adaptiveSensitivity,'NeighborhoodSize',adaptiveNeighbourhood, 'Statistic', 'Gaussian');
            % after thresholding, binarization of the signal
            image_binary_1 = imbinarize(image_adjust_1, T);
            %     figure(2)
            %     imshow(image_binary_1)
            
            % first median filtering to get rid of some additional noise
            % good results, regardless of image quality
            image_filtered_1 = medfilt2(image_binary_1);
            %     figure(3)
            %     imshow(image_filtered_1)
            
            % then some opening to get nicer shapes
            se = strel('disk', 2); % ***** other shapes and sizes can be tried for the morphological structure element
            image_open_1 = imopen(image_filtered_1,se);
            image_close_1 = imclose(image_open_1,se);
            % 	figure(4)
            %   imshow(image_close)
            
            if nonround
                % FILTERING OUR NON-ROUND OBJECTS (
                objectdImage = bwlabel(image_close_1);
                st=regionprops(objectdImage,'area','Perimeter');
                % Get areas and perimeters of all the regions into single arrays.
                allAreas = [st.Area];
                allPerimeters = [st.Perimeter];
                % Compute circularities.
                circularities = allPerimeters.^2 ./ (4*pi*allAreas);
                % Find objects that have "round" values of circularities.
                roundObjects = find(circularities < howround); % Whatever value you want
                image_round_1 = ismember(objectdImage, roundObjects) > 0;
%                     figure(5)
%                     imshow(image_round)
                image_close_1 = image_round_1;
            end
            
            % size filtering of objects
            image_sized_1 = bwareafilt(image_round_1, [sizeMin,sizeMax]);
%                 figure(6)
%                 imshow(image_sized)
            
            
            % OUTPUT: final mask for objects in this image:
            masks{jj} = image_sized_1;
            
            % calculate total object area in the image (area of mask)
            objectArea{jj} = bwarea(image_sized_1);
            
            % NORMALIZATION
            % calculate mean fluorescence of objects
            %   - change image to double * 255
            %   - then multiply with mask, now you have 0s where no mask and gray
            %       values where there is a mask
            %   - mean(mean*image_temp)) now gives the average value of the whole
            %       image (and not only mask), so it needs to be normalized
            %       
            image_temp = im2double(image_gray_1).*255;
            image_temp = image_temp.*image_sized_1;
            meanObjectFluorescence{jj} = numel(image_temp)*mean(mean(image_temp))/objectArea{jj};
           
            
            % get the individual nuclei or clusters of nuclei
            % where it-s difficult to divide them into individual ones.
            % object_pixels.PixelldxList - indexes where the pixels belonging to
            %   objects are (careful, matlab indexes by rows!!!)
            % object_pixels{jj}.NumObjects / number of objects identified
            % OUTPUT - pixel indexes belonging to individual objects
            object_pixels{jj} = bwconncomp(image_sized_1);
            numObjectElements(jj) = object_pixels{jj}.NumObjects;
            
            % prepare for visualization of individual object
            labeledObjects = labelmatrix(object_pixels{jj});
            RGB_label = label2rgb(labeledObjects,'spring','c','shuffle');
            
            % regionprops measures properties for each connected object in output
            % of bwconncomp. Here, it-s the Area and centroid for each
            % objects and the MeanIntensity
            grayscaleStats = regionprops(object_pixels{jj},image_gray_1,{'Area','Centroid', 'MeanIntensity'});
            % OUTPUT here the stats per individual object are saved
            objectStats{jj} = grayscaleStats;
            
            % put all figure stats into a single table
            figureStats(jj,1) = jj;
            figureStats(jj,2) = numObjectElements(jj);
            figureStats(jj,3) = objectArea{jj};
            figureStats(jj,4) = meanObjectFluorescence{jj};
            
            % PLOTTING
            % a single figure that illustrates the image analysis process
            % ***** uncomment this if you want the figures of the individual steps of object recognition saved
            FigH = figure('Position', get(0, 'Screensize'));
            set(FigH, 'Visible', 'off');
            subplot(3,2,1)
            imshow(image_original_1)
            title('Original image')
            subplot(3,2,2)
            imshow(image_adjust_1)
            % ***** the top value here depends on the intensity of the images,
            % choose a value high enough (close to max intensity of all images)
            caxis([0 40])
            title('Grayscale Image Scaled')
            subplot(3,2,3)
            imshow(image_binary_1)
            title('After binarization')
            subplot(3,2,4)
            imshow(image_round_1)
            title('after adaptive and shape filtering')
            subplot(3,2,5)
            imshow(image_sized_1)
            title('After size filtering')
            subplot(3,2,6)
            imshow(RGB_label)
            title('Mean fluorescence of each connected object');
            hold on
            for kk = 1 : numObjectElements(jj)
                text(grayscaleStats(kk).Centroid(1),grayscaleStats(kk).Centroid(2), ...
                    sprintf('%2.1f', grayscaleStats(kk).MeanIntensity), ...
                    'EdgeColor','b','Color','k');
            end
            hold off
            % to show the figure
            % figure(FigH)
            
            % select path and save
            % we select the printing resolution
            iResolution = 300;
            % we select to crop or not the figure
            set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
            % saving full screen size
            F    = getframe(FigH);
            imwrite(F.cdata, strcat(pathSegmented, FilesCH00(jj).name, '.jpeg'), 'jpeg')
        end
        
        % two channels chosen
    case 2
     
        for jj = 1:numFiles
            jj
            
            % from first channel until image
            % read in each image and convert to grayscale
            image_original_1 = imread(strcat(segmentFrom{1}(jj).folder,'\',segmentFrom{1}(jj).name));
            image_gray_1 = im2gray(image_original_1);
            
            % Background noise removal. 
            % Finds the peak of the histogram and deletes 
            % everything to the left of the peak + backgroundOffset
            [counts,x] = imhist(image_gray_1);
            [i,whereMax] = max(counts);
            image_gray_1(image_gray_1<whereMax+backgroundOffset_2(1))=0;
            image_adjust_1 = imadjust(image_gray_1);
            %     figure(1)
            %     imshow(image_adjust_1)
            
            % Adaptive thresholding. the point is to do local thresholding, which
            % can take into account different backgrund in the image. Removal of
            % noise is therefore based on local information.
            %   sensitivity = 0.6 (higher sensitivity means more noise gets in,
            %   lower means less signal, you need to find a good compromise). This
            %   needs to be tested for each batch of images.
            %   neighbourhood size = 11 (lower values separate better between small objects)
            % ***** (try playing with settings a bit for each new microscope dataset)
            T = adaptthresh(image_adjust_1, adaptiveSensitivity_2(1),'NeighborhoodSize',adaptiveNeighbourhood_2(1), 'Statistic', 'Gaussian');
            % after thresholding, binarization of the signal
            image_binary_1 = imbinarize(image_adjust_1, T);
            %     figure(2)
            %     imshow(image_binary_1)
            
            % first median filtering to get rid of some additional noise
            % good results, regardless of image quality
            image_filtered_1 = medfilt2(image_binary_1);
            %     figure(3)
            %     imshow(image_filtered_1)
            
            % then some opening to get nicer shapes
            se = strel('disk', 2); % ***** other shapes and sizes can be tried for the morphological structure element
            image_open_1 = imopen(image_filtered_1,se);
            image_close_1 = imclose(image_open_1,se);
            % 	figure(4)
            %   imshow(image_close)
            
            if nonround
                % FILTERING OUR NON-ROUND OBJECTS (
                objectdImage = bwlabel(image_close_1);
                st=regionprops(objectdImage,'area','Perimeter');
                % Get areas and perimeters of all the regions into single arrays.
                allAreas = [st.Area];
                allPerimeters = [st.Perimeter];
                % Compute circularities.
                circularities = allPerimeters.^2 ./ (4*pi*allAreas);
                % Find objects that have "round" values of circularities.
                roundObjects = find(circularities < howround); % Whatever value you want
                image_round_1 = ismember(objectdImage, roundObjects) > 0;
%                     figure(5)
%                     imshow(image_round_1)
                image_close_1 = image_round_1;
            end
            
            % size filtering of objects
            image_sized_1 = bwareafilt(image_round_1, [sizeMin,sizeMax]);
%                 figure(6)
%                 imshow(image_sized_1)



            % adding info for the second channel
            % read in each image and convert to grayscale
            image_original_2 = imread(strcat(segmentFrom{2}(jj).folder,'\',segmentFrom{2}(jj).name));
            image_gray_2 = im2gray(image_original_2);
            
            % Background noise removal. 
            % Finds the peak of the histogram and deletes 
            % everything to the left of the peak + backgroundOffset
            [counts,x] = imhist(image_gray_2);
            [i,whereMax] = max(counts);
            image_gray_2(image_gray_2<whereMax+backgroundOffset_2(2))=0;
            image_adjust_2 = imadjust(image_gray_2);
            %     figure(7)
            %     imshow(image_adjust_2)
            
            % Adaptive thresholding. the point is to do local thresholding, which
            % can take into account different backgrund in the image. Removal of
            % noise is therefore based on local information.
            %   sensitivity = 0.6 (higher sensitivity means more noise gets in,
            %   lower means less signal, you need to find a good compromise). This
            %   needs to be tested for each batch of images.
            %   neighbourhood size = 11 (lower values separate better between small objects)
            % ***** (try playing with settings a bit for each new microscope dataset)
            T = adaptthresh(image_adjust_2, adaptiveSensitivity_2(2),'NeighborhoodSize',adaptiveNeighbourhood_2(2), 'Statistic', 'Gaussian');
            % after thresholding, binarization of the signal
            image_binary_2 = imbinarize(image_adjust_2, T);
            %     figure(8)
            %     imshow(image_binary_2)
            
            % first median filtering to get rid of some additional noise
            % good results, regardless of image quality
            image_filtered_2 = medfilt2(image_binary_2);
            %     figure(9)
            %     imshow(image_filtered_2)
            
            % then some opening to get nicer shapes
            se = strel('disk', 2); % ***** other shapes and sizes can be tried for the morphological structure element
            image_open_2 = imopen(image_filtered_2,se);
            image_close_2 = imclose(image_open_2,se);
            % 	figure(10)
            %   imshow(image_close_2)
            
            if nonround
                % FILTERING OUR NON-ROUND OBJECTS (
                objectdImage = bwlabel(image_close_2);
                st=regionprops(objectdImage,'area','Perimeter');
                % Get areas and perimeters of all the regions into single arrays.
                allAreas = [st.Area];
                allPerimeters = [st.Perimeter];
                % Compute circularities.
                circularities = allPerimeters.^2 ./ (4*pi*allAreas);
                % Find objects that have "round" values of circularities.
                roundObjects = find(circularities < howround); % Whatever value you want
                image_round_2 = ismember(objectdImage, roundObjects) > 0;
%                     figure(11)
%                     imshow(image_round_2)
                image_close_2 = image_round_2;
            end
            
            % size filtering of objects
            image_sized_2 = bwareafilt(image_round_2, [sizeMin,sizeMax]);
%                 figure(12)
%                 imshow(image_sized_2)


            % logical operation, either taking both segmentations as unions
            % or as intersections
            if strcmp(segmentLogical,'union') 
                image_final = image_sized_1|image_sized_2;
            elseif strcmp(segmentLogical,'intersection')
                image_final = image_sized_1&image_sized_2;
            end


            % OUTPUTS PER IMAGE
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % final mask for objects in this image (0s where no object, 1s
            % where object)
            masks{jj} = image_final;
            
            % total object area in the image (area of mask)
            objectArea{jj} = bwarea(image_final);
            
            % NORMALIZATION
            % mean fluorescence of all objects (for the channel
            % that is used for segmentation)
            %   - change image to double * 255 gives the same values as in image_gray
            %   - then multiply with mask, now you have 0s where no mask and gray
            %       values where there is a mask
            %   - mean(mean*image_temp)) now gives the average value of the whole
            %       image (and not only mask), so it needs to be normalized
            %  !!!!! currently, it's calculating the mean fluorescence based on
            %  the first channel of the two
            image_temp = im2double(image_gray_1).*255;
            image_temp = image_temp.*image_final;
            meanObjectFluorescence{jj} = numel(image_temp)*mean(mean(image_temp))/objectArea{jj};
            
            
            % OUTPUTS PER OBJECT
            % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % get the individual objects or clusters of objects (if it's 
                % difficult to divide them into individual ones)
            % object_pixels.PixelldxList - indexes where the pixels belonging to
            %   objects are (careful, matlab indexes by rows!!!)
            % object_pixels{jj}.NumObjects / number of objects identified
            % OUTPUT - pixel indexes belonging to individual objects
            object_pixels{jj} = bwconncomp(image_final);
            numObjectElements(jj) = object_pixels{jj}.NumObjects;
            
            % prepare for visualization of individual object
            labeledObjects = labelmatrix(object_pixels{jj});
            RGB_label = label2rgb(labeledObjects,'spring','c','shuffle');
            
            % regionprops measures properties for each connected object in output
            % of bwconncomp. Here, it-s the Area and centroid for each
            % objects and the MeanIntensity
            grayscaleStats = regionprops(object_pixels{jj},image_gray_1,{'Area','Centroid', 'MeanIntensity'});
            % OUTPUT here the stats per individual object are saved
            objectStats{jj} = grayscaleStats;
            
            % put all figure stats into a single table
            figureStats(jj,1) = jj;
            figureStats(jj,2) = numObjectElements(jj);
            figureStats(jj,3) = objectArea{jj};
            figureStats(jj,4) = meanObjectFluorescence{jj};
            
            
            
            % PLOTTING
            % a single figure that illustrates the image analysis process
            % ***** uncomment this if you want the figures of the individual steps of nucleus recognition saved
            FigH = figure('Position', get(0, 'Screensize'));
            set(FigH, 'Visible', 'off');
            subplot(3,5,1)
            imshow(image_original_1)
            title('Original image')
            subplot(3,5,6)
            imshow(image_adjust_1)
            % ***** the top value here depends on the intensity of the images,
            % choose a value high enough (close to max intensity of all images)
            caxis([0 40])
            title(strcat('Grayscale Image Scaled 1st channel'))
            
            subplot(3,5,11)
            imshow(image_adjust_2)
            % ***** the top value here depends on the intensity of the images,
            % choose a value high enough (close to max intensity of all images)
            caxis([0 40])
            title('Grayscale Image Scaled 2nd channel')
            
            
            subplot(3,5,7)
            imshow(image_binary_1)
            title('After binarization 1st channel')
            subplot(3,5,12)
            imshow(image_binary_2)
            title('After binarization 2nd channel')
            subplot(3,5,8)
            imshow(image_close_1)
            title('After adaptive and shape 1st channel')
            subplot(3,5,13)
            imshow(image_close_2)
            title('After adaptive and shape 2nd channel')
            subplot(3,5,9)
            imshow(image_sized_1)
            title('After size filtering 1st channel')
            subplot(3,5,14)
            imshow(image_sized_2)
            title('After size filtering 2nd channel')
             
            subplot(3,5,10)
            imshow(image_final)
            title('After logical operation')
            subplot(3,5,15)
            imshow(RGB_label)
            title('Mean fluorescence of each connected nucleus');
            hold on
            for kk = 1 : numObjectElements(jj)
                text(grayscaleStats(kk).Centroid(1),grayscaleStats(kk).Centroid(2), ...
                    sprintf('%2.1f', grayscaleStats(kk).MeanIntensity), ...
                    'EdgeColor','b','Color','k');
            end
            hold off
            % to show the figure
            % figure(FigH)
            
            % select path and save
            % we select the printing resolution
            iResolution = 300;
            % we select to crop or not the figure
            set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
            % saving full screen size
            F    = getframe(FigH);
            imwrite(F.cdata, strcat(pathSegmented, FilesCH00(jj).name, '.jpeg'), 'jpeg')
        end
        
end

% if segmentation needs to be inverted (0s become 1s and vice versa)
for ii = 1:numel(masks)
    masks{ii} = ~masks{ii};
end



% OUTPUT here are all the stats of the individual figures
figureStats = array2table(figureStats, 'VariableNames', {'figureNumber', 'NumberObjects', 'AreaObjects','meanObjectFluorescence'});

% saving the important results
savefile = strcat(pathSegmented,'analyzedObjects.mat');
% here we define all OUTPUTs to save
save(savefile, 'masks','object_pixels','objectStats', 'figureStats');

% saving to excel files
% SAVING the most important OUTPUTS as excel files
% figure_stats
writetable(figureStats,'figureStats.xlsx','Sheet',1,'Range','A1','WriteVariableNames', true)
% object_stats
for ii = 1:numel(objectStats)
    ii
    filename = strcat('objectStats', num2str(ii),'.xlsx');
    temp = [];
    for jj = 1: numel(objectStats{1,ii})
        temp = [temp; objectStats{1,ii}(jj).Area,objectStats{1,ii}(jj).Centroid,objectStats{1,ii}(jj).MeanIntensity];
    end
    headerNames = {'Area', 'Centroid_x', 'Centroid_y', 'MeanIntensity'};
    C = [headerNames; num2cell(temp)];
    writecell(C,filename)
end

