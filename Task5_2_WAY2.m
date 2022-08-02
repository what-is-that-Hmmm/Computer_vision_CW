
% %% way 2
% %   read images and generate features
% org_gray = rgb2gray(first_img);
% tran_gray = rgb2gray(second_img);
% p_org = detectSURFFeatures(org_gray);   % detect the feature points on the 
%                                         % on the original image.
% p_org = selectStrongest(p_org, 100);    % select the strongest 100 points
% 
% p_tran = detectSURFFeatures(tran_gray); % detect the feature points on the 
%                                         % translated image. 
% p_tran = selectStrongest(p_tran, 100);  % select the strongest 100 points
% % Extracting and transfering into discriptor
% [features1, validPoints1] = extractFeatures(org_gray, p_org);
% [features2, validPoints2] = extractFeatures(tran_gray, p_tran);
% indexPairs = matchFeatures(features1, features2);
% matchedPoints1 = validPoints1(indexPairs(:, 1), :); 
% matchedPoints2 = validPoints2(indexPairs(:, 2), :);
% [fLMedS, inliers] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'NumTrials',2000);
% 
% % Create the point tracker
% tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);
% 
% % Initialize the point tracker
% imagePoints1 = matchedPoints1.Location;
% initialize(tracker, imagePoints1, first_img);
% 
% % Track the points
% [imagePoints2, validIdx] = step(tracker, second_img);
% matchedPoints11 = imagePoints1(validIdx, :);
% matchedPoints22 = imagePoints2(validIdx, :);
% 
% % Visualize correspondences
% figure
% showMatchedFeatures(first_img, second_img, matchedPoints11, matchedPoints22);
% title('Tracked Features');

% %% Reconstruction
% 
% % Estimate the fundamental matrix
% [E, epipolarInliers] = estimateEssentialMatrix(...
%     matchedPoints1, matchedPoints2, iPhone11Cam, 'Confidence', 99.99);
% 
% % Find epipolar inliers
% inlierPoints1 = matchedPoints1(epipolarInliers, :);
% inlierPoints2 = matchedPoints2(epipolarInliers, :);
% 
% % Display inlier matches
% figure
% showMatchedFeatures(first_img, second_img, inlierPoints1, inlierPoints2);
% title('Epipolar Inliers');
% 
% [orient, loc] = relativeCameraPose(E, iPhone11Cam, inlierPoints1, inlierPoints2);
% 
% % Detect dense feature points. Use an ROI to exclude points close to the
% % image edges.
% roi = [30, 30, size(first_img, 2) - 30, size(first_img, 1) - 30];
% imagePoints1 = detectMinEigenFeatures(im2gray(first_img), 'ROI', roi, ...
%     'MinQuality', 0.001);
% 
% % Create the point tracker
% tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);
% 
% % Initialize the point tracker
% imagePoints1 = imagePoints1.Location;
% initialize(tracker, imagePoints1, first_img);
% 
% % Track the points
% [imagePoints2, validIdx] = step(tracker, second_img);
% matchedPoints1 = imagePoints1(validIdx, :);
% matchedPoints2 = imagePoints2(validIdx, :);
% 
% % Compute the camera matrices for each position of the camera
% % The first camera is at the origin looking along the Z-axis. Thus, its
% % transformation is identity.
% tform1 = rigid3d;
% camMatrix1 = cameraMatrix(iPhone11Cam, tform1.Rotation, tform1.Translation);
% 
% % Compute extrinsics of the second camera
% cameraPose = rigid3d(orient, loc);
% tform2 = cameraPoseToExtrinsics(cameraPose);
% camMatrix2 = cameraMatrix(iPhone11Cam, tform2.Rotation, tform2.Translation);
% 
% % Compute the 3-D points
% points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);
% 
% % Get the color of each reconstructed point
% numPixels = size(first_img, 1) * size(first_img, 2);
% allColors = reshape(first_img, [numPixels, 3]);
% colorIdx = sub2ind([size(first_img, 1), size(first_img, 2)], round(matchedPoints1(:,2)), ...
%     round(matchedPoints1(:, 1)));
% color = allColors(colorIdx, :);
% 
% % Create the point cloud
% ptCloud = pointCloud(points3D, 'Color', color);
% 
% 
% 
% % Visualize the camera locations and orientations
% cameraSize = 0.3;
% figure
% plotCamera('Size', cameraSize, 'Color', 'r', 'Label', '1', 'Opacity', 0);
% hold on
% grid on
% plotCamera('Location', loc, 'Orientation', orient, 'Size', cameraSize, ...
%     'Color', 'b', 'Label', '2', 'Opacity', 0);
% 
% % Visualize the point cloud
% pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', ...
%     'MarkerSize', 45);
% 
% % Rotate and zoom the plot
% camorbit(0, -30);
% camzoom(1.5);
% 
% % Label the axes
% xlabel('x-axis');
% ylabel('y-axis');
% zlabel('z-axis')
% 
% title('Up to Scale Reconstruction of the Scene');