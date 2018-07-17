function imgSeq2Video

imgPath = 'imgAlign';
fileExt = 'tif';

imgDir = dir(fullfile(imgPath, ['*.', fileExt]));

numImg = length(imgDir);
aviobj = avifile('morphing.avi','compression','None', 'quality', 100);

 
fig = figure(1);
for i = 1 : numImg
    imgName = imgDir(i).name;
    img = imread(fullfile(imgPath, imgName));
    [imgH, imgW, ch] = size(img);
    xCrop = imgW/8;
    yCropL = imgH/20;
    yCropU = imgH/6;
    img = img(yCropL:end-yCropU, xCrop:end-xCrop,:);
    figure(1), imshow(img);
    F = getframe(fig);
    aviobj = addframe(aviobj,F);
end

close(fig);
aviobj = close(aviobj);

end