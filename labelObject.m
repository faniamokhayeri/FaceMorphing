imgPath = 'faces/';

imName1 = [imgPath, 'old_car.jpg'];
imName2 = [imgPath, 'new_car.jpg'];

im1 = imread(imName1);
im2 = imread(imName2);


pts1 = [];
pts2 = [];

figure(1)
   subplot(1,2,1), imshow(im1);
   subplot(1,2,2), imshow(im2);
   indPt = 1;
while 1
   figure(1)
   pts1(indPt,:) = ginput(1);
   hold on, plot(pts1(indPt,1), pts1(indPt,2), '*-');
   
   [x, y, b] = ginput(1);
   pts2(indPt,:) = [x, y];
   hold on, plot(pts2(indPt,1), pts2(indPt,2), '*-');
   if b=='q'
        break;
   end
   indPt = indPt +1;
end

save -ascii ./old_car.txt pts1;
save -ascii ./new_car.txt pts2;