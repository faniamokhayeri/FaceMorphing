function  imgOut = imTrans(imgIn, T)

    [imgHeight, imgWidth, channel] = size(imgIn);
    imgInR = imgIn(:,:,1);
%     imgInG = imgIn(:,:,2);
%     imgInB = imgIn(:,:,3);
    imgOutR = imgInR;
%     imgOutG = imgInG;
%     imgOutB = imgInB;
   
    idxMat = ones(imgHeight, imgWidth);
    [rows, cols] = find(idxMat);

    b = [cols'; rows'; ones(1,size(cols,1))];
    x = round(T\b);
    validInd = (x(1,:)>0 & x(1,:)<=imgWidth & x(2,:)>0 & x(2,:)<=imgHeight);
    x = x(:,validInd);
    b = b(:,validInd);
    indTargetPt = sub2ind([imgHeight, imgWidth], x(2,:),x(1,:));
    indSourcePt = sub2ind([imgHeight, imgWidth], b(2,:),b(1,:));
    
    imgOutR(indSourcePt) = imgInR(indTargetPt);
%     imgOutG(indSourcePt) = imgInG(indTargetPt);
%     imgOutB(indSourcePt) = imgInB(indTargetPt);
%   
    imgOut = cat(3, imgOutR);
  
end