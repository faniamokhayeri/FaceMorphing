imgPath = 'imgCropped';

imgLabel = ['efros_points.jpg'];
imgLabelNum = ['efros_point_numbers.jpg'];

imgDir = dir(fullfile(imgPath, '*.tif'));

numImg = length(imgDir);

figure(1), imshow(imgLabel);
figure(2), imshow(imgLabelNum);
numPt = 66;
for i = 1: numImg
    imgName = imgDir(i).name;  
    img = imread(fullfile(imgPath, imgName));
    figure(3), imshow(img);    hold on;
    pts = zeros(numPt, 2);

    for indPt = 1 : numPt
        disp(['Image ', num2str(i),' Label point ', num2str(indPt)]);
        pts(indPt,:) = ginput(1);
        hold on, plot(pts(1:indPt,1), pts(1:indPt,2), '-.b*');
    end
    ptName = [imgName(1:end-4),'.txt'];
    save(fullfile(imgPath, ptName), 'pts', '-ASCII');
end


