clear
clc

%% for task 2 - 1b Harris
I1 = rgb2gray(imread('HG21.jpg'));
I2 = rgb2gray(imread('HG20.jpg'));
points1=detectSIFTFeatures(I1);
points2=detectSIFTFeatures(I2);
[features1,valid_points1]=extractFeatures(I1,points1);
[features2,valid_points2]=extractFeatures(I2,points2);
figure;imshow(I1);hold on
plot(valid_points1);
indexPairs=matchFeatures(features1,features2);
matchedPoints1=valid_points1(indexPairs(:,1),:);
matchedPoints2=valid_points2(indexPairs(:,2),:);
figure;
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);
[tform,inlierpoints1,inlierpoints2]= estimateGeometricTransform(matchedPoints1,matchedPoints2,'projective');
H=tform.T;
pointsimg1=inlierpoints1.Location;
pointsimg2=inlierpoints2.Location;
z_axis=ones(length(pointsimg2(:,1)),1);
pn2=[pointsimg2 z_axis];
pn1=[pointsimg1 z_axis];
pn1_tr=pn1.';
H2=H.';
projectI1toI2=zeros(length(z_axis),3);
for c=1:length(z_axis)
    projectI1toI2(c,1)=H2(1,:)*pn1_tr(:,c);
    projectI1toI2(c,2)=H2(2,:)*pn1_tr(:,c);
    projectI1toI2(c,3)=H2(3,:)*pn1_tr(:,c);
end
MSE=immse(double(pn2),projectI1toI2);
