imgPath = 'faces/';

imgLabel = ['efros_points.jpg'];
imgLabelNum = ['efros_point_numbers.jpg'];
imMe = [imgPath, 'gugi.jpg'];

numPt = 66;
numPt = 22;

pts = zeros(numPt, 2);

for indPt = 1: numPt
   figure(1)
   subplot(1,3,1), imshow(imgLabel);
   subplot(1,3,2), imshow(imgLabelNum);
   subplot(1,3,3),imshow(imMe);
   title([num2str(indPt),'/66']);
   pts(indPt,:) = ginput(1);

end

save -ascii ./gugi.txt pts;