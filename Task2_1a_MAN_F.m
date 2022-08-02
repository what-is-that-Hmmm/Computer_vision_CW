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
j=length(mp);
a=zeros(1,j);
b=zeros(1,j);
for i=1:j
    a(i)=1.1148968*fp(i,1)+0.29303497*fp(i,2)-1.9025118e-05-mp(i,1);
    b(i)=-0.39301369*fp(i,1)+1.1039032*fp(i,2)-3.5306584e-05-mp(i,2);
end
x_mse=mse(a(:,1));
y_mse=mse(b(:,2));


figure;
subplot(121);
imshow(orignal_img);
title('The original image');
subplot(122);
imshow(Rectified);
title('From translated image');