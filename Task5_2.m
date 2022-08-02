clear
clc

%% Task 5 - 2
load("iPhone11_Cam.mat")
% image 1 for the right image
image1 = imread('FDX2.JPG');%('FD01.JPG');
[first_img, org_Origin] = undistortImage(image1, iPhone11Cam);
% image 2 for the left image
image2 = imread('FDX1.JPG');%image2 = imread('FD03.JPG');
[second_img, trans_Origin] = undistortImage(image2, iPhone11Cam);

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

figure;
imshow(stereoAnaglyph(second_img, first_img));
title('Rectified Frames');

frameLeftGray  = rgb2gray(second_img);
frameRightGray = rgb2gray(first_img);
    
disparityMap = disparitySGM(frameLeftGray, frameRightGray);
figure;
imshow(disparityMap, [0, 100]);
title('Disparity Map');
colormap jet
colorbar
