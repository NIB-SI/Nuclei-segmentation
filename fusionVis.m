% fusionVis.m
%
% visualization of the images on top of each other
% you need to run dataLoad.m first

% fusing the images, depending on the number of channels
switch numCH
    
    case 2
        
        for jj = 1:numFiles
            
            % reading the images and converting them to grayscale
            image_original_CH00 = imread(strcat(FilesCH00(jj).folder,'\',FilesCH00(jj).name));
            image_gray_CH00 = im2gray(image_original_CH00);
            image_gray_CH00= imadjust(image_gray_CH00);
            % figure
            % imshow(image_gray_CH00)
            image_original_CH01 = imread(strcat(FilesCH01(jj).folder,'\',FilesCH01(jj).name));
            image_gray_CH01 = im2gray(image_original_CH01);
            image_gray_CH01= imadjust(image_gray_CH01);
            % figure
            % imshow(image_gray_CH01)
            
            % impose the images on top of each other
            C = imfuse(image_gray_CH00,image_gray_CH01,...
                'falsecolor','Scaling','independent','ColorChannels',[1 2 0]);
            % figure
            % imshow(C)
            
            % save the images into the fusion directory
            FigH = figure('Position', get(0, 'Screensize'));
            set(FigH, 'Visible', 'off');
            imshow(C)
            title('Fuse: CH00 (red) CH01 (green)')
            iResolution = 300;
            set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
            F    = getframe(FigH);
            imwrite(F.cdata, strcat(pathFusion, FilesCH00(jj).name, '.jpeg'), 'jpeg')
        end
        
    case 3
        
        for jj = 1:numFiles
            
            % reading the images and converting them to grayscale
            image_original_CH00 = imread(strcat(FilesCH00(jj).folder,'\',FilesCH00(jj).name));
            image_gray_CH00 = im2gray(image_original_CH00);
            image_gray_CH00= imadjust(image_gray_CH00);

            image_original_CH01 = imread(strcat(FilesCH01(jj).folder,'\',FilesCH01(jj).name));
            image_gray_CH01 = im2gray(image_original_CH01);
            image_gray_CH01= imadjust(image_gray_CH01);
            
            image_original_CH02 = imread(strcat(FilesCH02(jj).folder,'\',FilesCH02(jj).name));
            image_gray_CH02 = im2gray(image_original_CH02);
            image_gray_CH02= imadjust(image_gray_CH02);
            
            % impose the images on top of each other 
            C1 = imfuse(image_gray_CH00,image_gray_CH01,...
                'falsecolor','Scaling','independent','ColorChannels',[2 0 1]);
            C2 = imfuse(image_gray_CH00,image_gray_CH02,...
                'falsecolor','Scaling','independent','ColorChannels',[0 2 1]);
            C3 = imfuse(image_gray_CH01,image_gray_CH02,...
                'falsecolor','Scaling','independent','ColorChannels',[1 2 0]);
            overlay_im = cat(3, image_gray_CH01, image_gray_CH02, image_gray_CH00);
            
            FigH = figure('Position', get(0, 'Screensize'));
            set(FigH, 'Visible', 'off');
            subplot(2,2,2)
            imshow(C1)
            title('Fuse: CH00 (blue) CH01 (red)')
            subplot(2,2,4)
            imshow(C2)
            title('Fuse: CH00 (blue) CH02 (green)')
            subplot(2,2,3)
            imshow(C3)
            title('Fuse: CH01 (red) CH02 (green)')
            subplot(2,2,1)
            imshow(overlay_im)
            title('Fuse: CH00 (blue) CH01 (red) CH02 (green)')
            iResolution = 300;
            set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
            F    = getframe(FigH);
            imwrite(F.cdata, strcat(pathFusion, FilesCH00(jj).name, '.jpeg'), 'jpeg')
        end
        
    case 4
        
        % as i find fused images in four channels super difficult to read,
        % here there are only going to be the pairs and the threefold
        % composites
        for jj = 1:numFiles
            
            image_original_CH00 = imread(strcat(FilesCH00(jj).folder,'\',FilesCH00(jj).name));
            image_gray_CH00 = im2gray(image_original_CH00);
            image_gray_CH00= imadjust(image_gray_CH00);
            image_original_CH01 = imread(strcat(FilesCH01(jj).folder,'\',FilesCH01(jj).name));
            image_gray_CH01 = im2gray(image_original_CH01);
            image_gray_CH01= imadjust(image_gray_CH01);
            image_original_CH02 = imread(strcat(FilesCH02(jj).folder,'\',FilesCH02(jj).name));
            image_gray_CH02 = im2gray(image_original_CH02);
            image_gray_CH02= imadjust(image_gray_CH02);
            image_original_CH03 = imread(strcat(FilesCH03(jj).folder,'\',FilesCH03(jj).name));
            image_gray_CH03 = im2gray(image_original_CH03);
            image_gray_CH03= imadjust(image_gray_CH03);
            
            overlay1 = cat(3, image_gray_CH00, image_gray_CH01, image_gray_CH02);
            overlay2 = cat(3, image_gray_CH00, image_gray_CH01, image_gray_CH03);
            overlay3 = cat(3, image_gray_CH00, image_gray_CH02, image_gray_CH03);
            overlay4 = cat(3, image_gray_CH01, image_gray_CH02, image_gray_CH03);

            
            FigH = figure('Position', get(0, 'Screensize'));
            set(FigH, 'Visible', 'off');
            subplot(2,2,1)
            imshow(overlay1)
            title('Fuse: CH00 (red) CH01 (green) CH02 (blue)')
            subplot(2,2,2)
            imshow(overlay2)
            title('Fuse: CH00 (red) CH01 (green) CH03 (blue)')
            subplot(2,2,3)
            imshow(overlay3)
            title('Fuse: CH00 (red) CH01 (green) CH03 (blue)')
            subplot(2,2,4)
            imshow(overlay4)
            title('Fuse: CH01 (red) CH02 (green) CH03 (blue)')
            iResolution = 300;
            set(gcf, 'PaperPositionMode', 'auto', 'color', 'w');
            F    = getframe(FigH);
            imwrite(F.cdata, strcat(pathFusion, FilesCH00(jj).name, '.jpeg'), 'jpeg')
        end
        
end


