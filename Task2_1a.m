clear
clc

%% For task 2a - manual operation

orignal_img = imread('HG20.jpg');
zoom_rot_img = imread('HG21.jpg');

[mp, fp] = cpselect(zoom_rot_img, orignal_img, 'Wait', true);
% Find the transformation matrix
tform = fitgeotrans(mp,fp,'projective');    

Rfixed = imref2d(size(orignal_img));
Rectified = imwarp(zoom_rot_img,tform,'OutputView',Rfixed);

figure;
subplot(121);
imshow(orignal_img);
title('The original image');
subplot(122);
imshow(Rectified);
title('From translated image');