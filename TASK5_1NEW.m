xclear
clc

load("iPhone11_Cam.mat")
% image 1 for the first image
first_img = imread('FD01.JPG');
[first_img, first_Origin] = undistortImage(first_img, iPhone11Cam);
% image 2 for the second image
second_img = imread('FD03.JPG');
[second_img, second_Origin] = undistortImage(second_img, iPhone11Cam);

%   read images and generate features
org_gray = rgb2gray(first_img);
tran_gray = rgb2gray(second_img);

p_org = detectSURFFeatures(org_gray);   % detect the feature points on the 
                                        % on the original image.
p_org = selectStrongest(p_org, 100);    % select the strongest 100 points

p_tran = detectSURFFeatures(tran_gray); % detect the feature points on the 
                                        % translated image. 
p_tran = selectStrongest(p_tran, 100);  % select the strongest 100 points

% Extracting and transfering into discriptor
[features1, validPoints1] = extractFeatures(org_gray, p_org);
[features2, validPoints2] = extractFeatures(tran_gray, p_tran);
indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validPoints1(indexPairs(:, 1), :); 
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

[fLMedS, inliers] = estimateFundamentalMatrix(matchedPoints1,...
    matchedPoints2,'Method','RANSAC','NumTrials',2000);

[t1, t2] = estimateUncalibratedRectification(fLMedS,matchedPoints1(inliers,:),...
    matchedPoints2(inliers,:),size(first_img));

[I1Rect,I2Rect] = rectifyStereoImages(first_img,second_img,t1,t2);

figure;
imshow(stereoAnaglyph(I1Rect,I2Rect));

%% epipolar lines

org_gray = rgb2gray(I1Rect);
tran_gray = rgb2gray(I2Rect);

p_org = detectSURFFeatures(org_gray);   % detect the feature points on the 
                                        % on the original image.
p_org = selectStrongest(p_org, 100);    % select the strongest 100 points

p_tran = detectSURFFeatures(tran_gray); % detect the feature points on the 
                                        % translated image. 
p_tran = selectStrongest(p_tran, 100);  % select the strongest 100 points

% Extracting and transfering into discriptor
[features1, validPoints1] = extractFeatures(org_gray, p_org);
[features2, validPoints2] = extractFeatures(tran_gray, p_tran);
indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validPoints1(indexPairs(:, 1), :); 
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

%   results
fLMedS = estimateFundamentalMatrix(matchedPoints1(inliers,:),...
    matchedPoints2(inliers,:),'NumTrials',2000);
figure; 
subplot(1,2,1);
imshow(I1Rect); 
title('Inliers and Epipolar Lines in First Image'); 
hold on;
plot(matchedPoints1.Location(inliers,1),matchedPoints1.Location(inliers,2),...
    'y*')   % ploting epipoles
epiLines = epipolarLine(fLMedS,matchedPoints1.Location(inliers,:));
points = lineToBorderPoints(epiLines,size(I1Rect));
line(points(:,[1,3])',points(:,[2,4])');

subplot(1,2,2); 
imshow(I2Rect);
title('Inliers and Epipolar Lines in Second Image'); hold on;
plot(matchedPoints2.Location(inliers,1),matchedPoints2.Location(inliers,2),...
    'g*')   % ploting epipoles
epiLines = epipolarLine(fLMedS,matchedPoints2.Location(inliers,:));
points = lineToBorderPoints(epiLines,size(I2Rect));
line(points(:,[1,3])',points(:,[2,4])');

%% Depth map

figure;
imshow(stereoAnaglyph(I2Rect, I1Rect));
title('Rectified Frames');

frameLeftGray  = rgb2gray(I2Rect);
frameRightGray = rgb2gray(I1Rect);
    
disparityMap = disparitySGM(frameLeftGray, frameRightGray);
figure;
imshow(disparityMap, [13.3, 37.3]);
title('Disparity Map');
colormap jet
a=colorbar;
ylabel(a,'Depth (cm)','FontSize',10,'Rotation',90);
