clear;
clc;

%% Task 4 - 1a
load("iPhone11_Cam.mat")
% image 1 for the original image
image1 = imread('HG20.JPG');
[org_img, org_Origin] = undistortImage(image1, iPhone11Cam);
% image 2 for the translated image
image2 = imread('HG21.JPG');
[trans_img, trans_Origin] = undistortImage(image2, iPhone11Cam);

subplot(2,2,1)
imshow(image1);
title('original raw from cam');
subplot(2,2,2)
imshow(org_img);
title('rectified original image');
subplot(2,2,3)
imshow(image2);
title('translated raw from cam');
subplot(2,2,4)
imshow(trans_img)
title('rectified translated image');

%   read images 
org_gray = rgb2gray(org_img);
tran_gray = rgb2gray(trans_img);

p_org = detectSURFFeatures(org_gray);   % detect the feature points on the 
                                        % on the original image.
p_org = selectStrongest(p_org, 100);    % select the strongest 100 points

p_tran = detectSURFFeatures(tran_gray); % detect the feature points on the 
                                        % translated image. 
p_tran = selectStrongest(p_tran, 100);  % select the strongest 100 points

% Extracting and matching
[features1, validPoints1] = extractFeatures(org_gray, p_org);
[features2, validPoints2] = extractFeatures(tran_gray, p_tran);
indexPairs = matchFeatures(features1, features2);
matchedPoints1 = validPoints1(indexPairs(:, 1), :);
matchedPoints2 = validPoints2(indexPairs(:, 2), :);

% Plotting the matching result
figure;
showMatchedFeatures(org_gray, tran_gray, matchedPoints1, matchedPoints2, 'montage');
tform = estimateGeometricTransform(matchedPoints1.Location,...
matchedPoints2.Location, 'projective');
% in 'tform' the transform matrix can be checked

% Calculating homography matrix
Homo_matrix = tform.T;

% Plotting the rectified result
rectified = imwarp(trans_img, tform);
figure;
subplot(1,2,1);
imshow(org_img);
subplot(1,2,2);
imshow(rectified);