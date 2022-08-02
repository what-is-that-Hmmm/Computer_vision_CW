clear
clc

%% Task 4 - 2a
load("iPhone11_Cam.mat")
% image 1 for the original image
image1 = imread('FD01.JPG');
[first_img, first_Origin] = undistortImage(image1, iPhone11Cam);
% image 2 for the translated image
image2 = imread('FD03.JPG');
[second_img, second_Origin] = undistortImage(image2, iPhone11Cam);


% Plot original image
subplot(2,2,1)
imshow(image1);
title('original first image');
subplot(2,2,2)
imshow(first_img);
title('rectified first image');
subplot(2,2,3)
imshow(image2);
title('original second');
subplot(2,2,4)
imshow(second_img)
title('rectified second image');

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

% Use the Least Median of Squares Method to Find Inliers
[fLMedS, inliers] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'NumTrials',2000);
% fLMeds is the fundamental matrix, but no accurate
figure; % Present the image that with matched inliers 
showMatchedFeatures(first_img,second_img, matchedPoints1(inliers,:),...
    matchedPoints2(inliers,:),'montage','PlotOptions',{'ro','go','y--'});
title('Point matches after outliers were removed');

%% Calculating Fundamation matrix
fun_matrix = estimateFundamentalMatrix(matchedPoints1(inliers,:),...
    matchedPoints2(inliers,:),'Method','RANSAC',...
    'NumTrials',2000,'DistanceThreshold',1e-4); % the application of inliner here is filtering

%% Task 5a Showing keypoints and epiplolar lines
figure; 
subplot(1,2,1);
imshow(first_img); 
title('Inliers and Epipolar Lines in First Image'); 
hold on;
plot(matchedPoints1.Location(inliers,1),matchedPoints1.Location(inliers,2),...
    'y*')   % ploting epiples
epiLines = epipolarLine(fun_matrix,matchedPoints1.Location(inliers,:));
points = lineToBorderPoints(epiLines,size(first_img));
line(points(:,[1,3])',points(:,[2,4])');

subplot(1,2,2); 
imshow(second_img);
title('Inliers and Epipolar Lines in Second Image'); hold on;
plot(matchedPoints2.Location(inliers,1),matchedPoints2.Location(inliers,2),...
    'g*')   % ploting epiples
epiLines = epipolarLine(fun_matrix,matchedPoints2.Location(inliers,:));
points = lineToBorderPoints(epiLines,size(first_img));
line(points(:,[1,3])',points(:,[2,4])');
