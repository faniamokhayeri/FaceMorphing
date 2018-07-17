function varargout = morphing_main(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @morphing_main_OpeningFcn, ...
                   'gui_OutputFcn',  @morphing_main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function morphing_main_OpeningFcn(hObject, eventdata, handles, varargin)

addpath(genpath('./tool/'));
 
handles.imgPath = 'TestImage/';
handles.labelPath = 'faces/';
handles.resultsPath = 'Results/';

fileExt = '.tif';
handles.fileExt = fileExt;

handles.imgDir = dir([handles.imgPath,'*.tif']);
numImg = length(handles.imgDir);
imgNameString = [];
for i = 1:numImg
    imgNameTemp = handles.imgDir(i).name;
    imgNameString{i} = imgNameTemp(1:end-4);
end
set(handles.listboxImage1, 'String', imgNameString);
set(handles.listboxImage2, 'String', imgNameString);

handles.displayMode = get(handles.listboxDisplayMode, 'Value');
set(handles.pushbuttonPlay,'UserData',0);
handles.siftFlowMorph = 0; 
handles.indCurrImg = 30;
handles.forwardInd =1;
% handles.siftFlowMorph = get(handles.siftFlowMorph, 'Value');

im_pts_avg = zeros(66,2);
numValidImg = 0;
for indImg = 1: numImg
    im_pts = load([handles.imgPath, imgNameString{indImg},'.txt'] , '-ascii');
    if(size(im_pts,1)==66)
        numValidImg = numValidImg+1;
        im_pts_avg = im_pts_avg + im_pts;
    end
end
handles.im_pts_avg = im_pts_avg/numValidImg;

handles.imgName1 = imgNameString{1};
handles.imgName2 = imgNameString{2};

handles.im1_pts = load([handles.imgPath, imgNameString{1},'.txt'] , '-ascii');
handles.im2_pts = load([handles.imgPath, imgNameString{2},'.txt'] , '-ascii');

handles.img1 = imread([handles.imgPath, imgNameString{1},fileExt]);
handles.img2 = imread([handles.imgPath, imgNameString{2},fileExt]);

handles.autoAlignFlag = 1; 
if(handles.autoAlignFlag)
    avgEyePts = handles.im_pts_avg(26:27, :);
    T1 = computeSimilarityT(handles.im1_pts(26:27, :), avgEyePts);
    T2 = computeSimilarityT(handles.im2_pts(26:27, :), avgEyePts);
    
    img1PtsTransformed = T1*[handles.im1_pts'; ones(1, size(handles.im1_pts,1))];
    img2PtsTransformed = T2*[handles.im2_pts'; ones(1, size(handles.im2_pts,1))];
    
    handles.im1_pts = img1PtsTransformed(1:2,:)';
    handles.im2_pts = img2PtsTransformed(1:2,:)';
    
    handles.img1 = imTrans(handles.img1, T1);
    handles.img2 = imTrans(handles.img2, T2);
end 
    
[imgHeight, imgWidth, channel] = size(handles.img1);
handles.corrPts = [1 ,1 ; 1, imgHeight; imgWidth, 1; imgWidth, imgHeight];
handles.im1_pts = [handles.im1_pts; handles.corrPts];
handles.im2_pts = [handles.im2_pts; handles.corrPts];


handles.img_mean_pts = 0.5*(handles.im1_pts + handles.im2_pts);
handles.tri = DelaunayTri((handles.img_mean_pts(:,1)), (handles.img_mean_pts(:,2)));

handles.warp_frac = get(handles.sliderMorphFraction,'Value');
handles.dissolve_frac = get(handles.sliderMorphFraction,'Value');
 
[handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img2, handles.im1_pts, handles.im2_pts, handles.tri, handles.warp_frac, handles.dissolve_frac);

if(handles.displayMode==1)
    axes(handles.axesImg1);
    imshow(handles.img1);

    axes(handles.axesImg2);
    imshow(handles.img2);

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im);
elseif(handles.displayMode==2)
    axes(handles.axesImg1);
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2));

    axes(handles.axesImg2);
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2));

    axes(handles.axesImgMorph);
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
else
    axes(handles.axesImg1);
    imshow(handles.img1); hold on;
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2)); hold off;

    axes(handles.axesImg2);
    imshow(handles.img2); hold on;
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2)); hold off;

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im); hold on;
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
end


handles.output = hObject;

guidata(hObject, handles);

function varargout = morphing_main_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function checkbox1_Callback(hObject, eventdata, handles)

function listboxImage1_Callback(hObject, eventdata, handles)
contents = cellstr(get(hObject,'String'));
handles.imgName1 = contents{get(hObject,'Value')};

handles.img1 = imread([handles.imgPath, handles.imgName1, handles.fileExt]);
if(handles.siftFlowMorph==0)
handles.im1_pts = load([handles.imgPath, handles.imgName1,'.txt'] , '-ascii');
end
handles.autoAlignFlag = get(handles.autoAlign, 'Value');
if(handles.autoAlignFlag && size(handles.im2_pts,1)==66)
    avgEyePts = handles.im_pts_avg(26:27, :);
    T1 = computeSimilarityT(handles.im1_pts(26:27, :), avgEyePts);
    
    img1PtsTransformed = T1*[handles.im1_pts'; ones(1, size(handles.im1_pts,1))];
    
    handles.im1_pts = img1PtsTransformed(1:2,:)';
    
    handles.img1 = imTrans(handles.img1, T1);
end

handles.im1_pts = [handles.im1_pts; handles.corrPts];

if(handles.displayMode==1)
    axes(handles.axesImg1);
    imshow(handles.img1);

    axes(handles.axesImg2);
    imshow(handles.img2);

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im);
elseif(handles.displayMode==2)
    axes(handles.axesImg1);
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2));

    axes(handles.axesImg2);
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2));

    axes(handles.axesImgMorph);
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
else
    axes(handles.axesImg1);
    imshow(handles.img1); hold on;
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2)); hold off;

    axes(handles.axesImg2);
    imshow(handles.img2); hold on;
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2)); hold off;

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im); hold on;
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
    
end
guidata(hObject, handles);

function listboxImage1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function listboxImage2_Callback(hObject, eventdata, handles)


contents = cellstr(get(hObject,'String'));
handles.imgName2 = contents{get(hObject,'Value')};

handles.img2 = imread([handles.imgPath, handles.imgName2, handles.fileExt]);
if(handles.siftFlowMorph==0)
handles.im2_pts = load([handles.imgPath, handles.imgName2,'.txt'] , '-ascii');
end
handles.autoAlignFlag = get(handles.autoAlign, 'Value');
if(handles.autoAlignFlag && size(handles.im2_pts,1)==66)
    avgEyePts = handles.im_pts_avg(26:27, :);
    T2 = computeSimilarityT(handles.im2_pts(26:27, :), avgEyePts);
    
    img2PtsTransformed = T2*[handles.im2_pts'; ones(1, size(handles.im2_pts,1))];
    
    handles.im2_pts = img2PtsTransformed(1:2,:)';
    
    handles.img2 = imTrans(handles.img2, T2);
end 


handles.im2_pts = [handles.im2_pts; handles.corrPts];

if(handles.displayMode==1)
    axes(handles.axesImg1);
    imshow(handles.img1);

    axes(handles.axesImg2);
    imshow(handles.img2);

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im);
elseif(handles.displayMode==2)
    axes(handles.axesImg1);
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2));

    axes(handles.axesImg2);
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2));

    axes(handles.axesImgMorph);
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
else
    axes(handles.axesImg1);
    imshow(handles.img1); hold on;
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2)); hold off;

    axes(handles.axesImg2);
    imshow(handles.img2); hold on;
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2)); hold off;

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im); hold on;
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
end
guidata(hObject, handles);


function listboxImage2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function autoAlign_Callback(hObject, eventdata, handles)

handles.autoAlignFlag = get(handles.autoAlign, 'Value');
guidata(hObject, handles);

function checkbox5_Callback(hObject, eventdata, handles)

function siftFlowMorph_Callback(hObject, eventdata, handles)

handles.siftFlowMorph = get(hObject, 'Value'); 
guidata(hObject, handles);

function pushbuttonPlay_Callback(hObject, eventdata, handles)

if(get(handles.pushbuttonPlay,'UserData') == 0)
    set(handles.pushbuttonPlay,'UserData', 1);
    set(handles.pushbuttonPlay,'String','Pause');
    if(handles.siftFlowMorph==1)
        [handles.vx, handles.vy] = computeSIFTFlow(handles.img1, handles.img2);
    end
else
    set(handles.pushbuttonPlay,'UserData', 0);
    set(handles.pushbuttonPlay,'String','Play');
end

while((get(handles.pushbuttonPlay,'UserData') ==1))
    
    handles.warp_frac = handles.indCurrImg/60;
    handles.dissolve_frac= handles.indCurrImg/60;

    set(handles.sliderMorphFraction, 'Value', handles.warp_frac);
    if(handles.siftFlowMorph==0)
        handles.img_mean_pts = 0.5*(handles.im1_pts + handles.im2_pts);
        handles.tri = DelaunayTri((handles.img_mean_pts(:,1)), (handles.img_mean_pts(:,2)));

        [handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img2, handles.im1_pts, handles.im2_pts, handles.tri, handles.warp_frac, handles.dissolve_frac);
    else 
%         [vx, vy] = computeSIFTFlow(handles.img1, handles.img2);
        handles.morphed_im = siftFlowMorph(handles.img1, handles.img2, handles.vx, handles.vy, handles.warp_frac, handles.dissolve_frac);
    end 
    
    if(handles.indCurrImg<10)
        resultImgName = ['morph_',handles.imgName1,'_',handles.imgName2,'_0',num2str(handles.indCurrImg),handles.fileExt];
    else
        resultImgName = ['morph_',handles.imgName1,'_',handles.imgName2,'_',num2str(handles.indCurrImg),handles.fileExt];
    end
    imwrite(handles.morphed_im, [handles.resultsPath , resultImgName]);
    
    if(handles.displayMode==1)
        axes(handles.axesImgMorph);
        imshow(handles.morphed_im);
    elseif(handles.displayMode==2)
        axes(handles.axesImgMorph);
        triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
    else
        axes(handles.axesImgMorph);
        imshow(handles.morphed_im); hold on;
        triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
    end
    if(handles.indCurrImg == 60)
        handles.forwardInd =0;
    elseif(handles.indCurrImg == 0)
        handles.forwardInd =1;
    end
    
    if(handles.forwardInd==1) 
        handles.indCurrImg = handles.indCurrImg + 1;
    else
        handles.indCurrImg = handles.indCurrImg - 1;
    end
    guidata(hObject, handles);
end


function pushbuttonFF_Callback(hObject, eventdata, handles)

if(get(handles.pushbuttonPlay,'UserData') == 0)
    handles.indCurrImg = handles.indCurrImg + 1;
    if(handles.indCurrImg>60)
       handles.indCurrImg = 60; 
    end
    handles.warp_frac = handles.indCurrImg/60;
    handles.dissolve_frac= handles.indCurrImg/60;
    set(handles.sliderMorphFraction, 'Value', handles.warp_frac);
    
    [handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img2, handles.im1_pts, handles.im2_pts, handles.tri, handles.warp_frac, handles.dissolve_frac);

    if(handles.displayMode==1)
        axes(handles.axesImgMorph);
        imshow(handles.morphed_im);
    elseif(handles.displayMode==2)
        axes(handles.axesImgMorph);
        triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
    else
        axes(handles.axesImgMorph);
        imshow(handles.morphed_im); hold on;
        triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
    end
end

guidata(hObject, handles);


function pushbuttonFB_Callback(hObject, eventdata, handles)

if(get(handles.pushbuttonPlay,'UserData') == 0)
    handles.indCurrImg = handles.indCurrImg - 1;
    if(handles.indCurrImg<0)
       handles.indCurrImg = 0; 
    end
    handles.warp_frac = handles.indCurrImg/60;
    handles.dissolve_frac= handles.indCurrImg/60;
    set(handles.sliderMorphFraction, 'Value', handles.warp_frac);
    
    [handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img2, handles.im1_pts, handles.im2_pts, handles.tri, handles.warp_frac, handles.dissolve_frac);

    if(handles.displayMode==1)
        axes(handles.axesImgMorph);
        imshow(handles.morphed_im);
    elseif(handles.displayMode==2)
        axes(handles.axesImgMorph);
        triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
    else
        axes(handles.axesImgMorph);
        imshow(handles.morphed_im); hold on;
        triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
    end
end

guidata(hObject, handles);


function pushbuttonBegin_Callback(hObject, eventdata, handles)

handles.indCurrImg = 0;
handles.warp_frac = handles.indCurrImg/60;
handles.dissolve_frac= handles.indCurrImg/60;
set(handles.sliderMorphFraction, 'Value', handles.warp_frac);
 
[handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img2, handles.im1_pts, handles.im2_pts, handles.tri, handles.warp_frac, handles.dissolve_frac);

if(handles.displayMode==1)
    axes(handles.axesImgMorph);
    imshow(handles.morphed_im);
elseif(handles.displayMode==2)
    axes(handles.axesImgMorph);
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
else
    axes(handles.axesImgMorph);
    imshow(handles.morphed_im); hold on;
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
end
guidata(hObject, handles);

function pushbuttonEnd_Callback(hObject, eventdata, handles)

handles.indCurrImg = 60;
handles.warp_frac = handles.indCurrImg/60;
handles.dissolve_frac= handles.indCurrImg/60;
set(handles.sliderMorphFraction, 'Value', handles.warp_frac);
 
[handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img2, handles.im1_pts, handles.im2_pts, handles.tri, handles.warp_frac, handles.dissolve_frac);

if(handles.displayMode==1)
    axes(handles.axesImgMorph);
    imshow(handles.morphed_im);
elseif(handles.displayMode==2)
    axes(handles.axesImgMorph);
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
else
    axes(handles.axesImgMorph);
    imshow(handles.morphed_im); hold on;
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
end
guidata(hObject, handles);

function sliderMorphFraction_Callback(hObject, eventdata, handles)

handles.warp_frac= get(hObject,'Value');
handles.dissolve_frac= get(hObject,'Value');


guidata(hObject, handles);

function sliderMorphFraction_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function checkbox2_Callback(hObject, eventdata, handles)

function processAll_Callback(hObject, eventdata, handles)

imgNameString = get(handles.listboxImage1, 'String');
numImg = length(imgNameString);

handles.displayMode = get(handles.listboxDisplayMode, 'Value');
set(handles.pushbuttonPlay,'UserData',0);

for indImg = 1: numImg-1
    handles.imgName1 = imgNameString{indImg};
    handles.imgName2 = imgNameString{indImg+1};

    handles.im1_pts = load([handles.imgPath, imgNameString{indImg},'.txt'] , '-ascii');
    handles.im2_pts = load([handles.imgPath, imgNameString{indImg+1},'.txt'] , '-ascii');
    
    handles.img1 = imread([handles.imgPath, imgNameString{indImg},handles.fileExt]);
    handles.img2 = imread([handles.imgPath, imgNameString{indImg+1},handles.fileExt]);
    
    handles.autoAlignFlag = get(handles.autoAlign, 'Value');
    if(handles.autoAlignFlag) 
      avgEyePts = handles.im_pts_avg(26:27, :);
      T1 = computeSimilarityT(handles.im1_pts(26:27, :), avgEyePts);
      T2 = computeSimilarityT(handles.im2_pts(26:27, :), avgEyePts);
    
      img1PtsTransformed = T1*[handles.im1_pts'; ones(1, size(handles.im1_pts,1))];
      img2PtsTransformed = T2*[handles.im2_pts'; ones(1, size(handles.im2_pts,1))];
    
      handles.im1_pts = img1PtsTransformed(1:2,:)';
      handles.im2_pts = img2PtsTransformed(1:2,:)';
    
      handles.img1 = imTrans(handles.img1, T1);
      handles.img2 = imTrans(handles.img2, T2);
    end 
    
    [imgHeight, imgWidth, channel] = size(handles.img1);
    handles.corrPts = [1 ,1 ; 1, imgHeight; imgWidth, 1; imgWidth, imgHeight];
    handles.im1_pts = [handles.im1_pts; handles.corrPts];
    handles.im2_pts = [handles.im2_pts; handles.corrPts];
    
    handles.img_mean_pts = 0.5*(handles.im1_pts + handles.im2_pts);
    handles.tri = DelaunayTri((handles.img_mean_pts(:,1)), (handles.img_mean_pts(:,2)));

    for indMorph = 0: 60
        handles.warp_frac = indMorph/60;
        handles.dissolve_frac = indMorph/60;
        [handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img2, handles.im1_pts, handles.im2_pts, handles.tri, handles.warp_frac, handles.dissolve_frac);
        
        if(indMorph<10)
            resultImgName = ['morph_',handles.imgName1,'_',handles.imgName2,'_0',num2str(indMorph),handles.fileExt];
        else
            resultImgName = ['morph_',handles.imgName1,'_',handles.imgName2,'_',num2str(indMorph),handles.fileExt];
        end
        imwrite(handles.morphed_im, [handles.resultsPath , resultImgName]);

        if(handles.displayMode==1)
            axes(handles.axesImg1);
            imshow(handles.img1);
            
            axes(handles.axesImg2);
            imshow(handles.img2);
            
            axes(handles.axesImgMorph);
            imshow(handles.morphed_im);
        elseif(handles.displayMode==2)
            axes(handles.axesImg1);
            triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2));

            axes(handles.axesImg2);
            triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2));

            axes(handles.axesImgMorph);
            triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));
        else
            axes(handles.axesImg1);
            imshow(handles.img1); hold on;
            triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2)); hold off;

            axes(handles.axesImg2);
            imshow(handles.img2); hold on;
            triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2)); hold off;

            axes(handles.axesImgMorph);
            imshow(handles.morphed_im); hold on;
            triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
        end
    end
    
end


guidata(hObject, handles);


function checkbox7_Callback(hObject, eventdata, handles)

function listboxDisplayMode_Callback(hObject, eventdata, handles)

handles.displayMode = get(hObject,'Value');


if(handles.displayMode==1)
    axes(handles.axesImg1);
    imshow(handles.img1);

    axes(handles.axesImg2);
    imshow(handles.img2);

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im);
elseif(handles.displayMode==2)
    axes(handles.axesImg1);
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2));

    axes(handles.axesImg2);
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2));

    axes(handles.axesImgMorph);
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2));   
else
    axes(handles.axesImg1);
    imshow(handles.img1); hold on;
    triplot(handles.tri, handles.im1_pts(:,1),handles.im1_pts(:,2)); hold off;

    axes(handles.axesImg2);
    imshow(handles.img2); hold on;
    triplot(handles.tri, handles.im2_pts(:,1),handles.im2_pts(:,2)); hold off;

    axes(handles.axesImgMorph);
    imshow(handles.morphed_im); hold on;
    triplot(handles.tri, handles.imMorph_pts(:,1),handles.imMorph_pts(:,2)); hold off;
end
guidata(hObject, handles);


function listboxDisplayMode_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function meanFace_Callback(hObject, eventdata, handles)

imgNameString = get(handles.listboxImage1, 'String');
numImg = length(imgNameString);

handles.displayMode = get(handles.listboxDisplayMode, 'Value');

im_pts_avg = zeros(66,2);
numValidImg = 0;
for indImg = 1: numImg
    im_pts = load([handles.imgPath, imgNameString{indImg},'.txt'] , '-ascii');
    handles.autoAlignFlag = get(handles.autoAlign, 'Value');
    if(handles.autoAlignFlag && size(im_pts,1)==66)
        numValidImg = numValidImg +1;
        avgEyePts = handles.im_pts_avg(26:27, :);
        T = computeSimilarityT(im_pts(26:27, :), avgEyePts);
        imgPtsTransformed = T*[im_pts'; ones(1, size(im_pts,1))];
        im_pts = imgPtsTransformed(1:2,:)';
    end
    im_pts_avg = im_pts_avg + im_pts;
end
im_pts_avg = im_pts_avg/numValidImg;
im_pts_avg = [im_pts_avg; handles.corrPts];
handles.tri = DelaunayTri((im_pts_avg(:,1)), (im_pts_avg(:,2)));

% imgAvg = zeros(handles.corrPts(4,2), handles.corrPts(4,1),3);

imgAvg = zeros(800, 580,3);

for indImg = 1: numImg
    img = imread([handles.imgPath, imgNameString{indImg},handles.fileExt]);
    im_pts = load([handles.imgPath, imgNameString{indImg},'.txt'] , '-ascii');
    handles.autoAlignFlag = get(handles.autoAlign, 'Value');
    if(handles.autoAlignFlag)
        avgEyePts = handles.im_pts_avg(26:27, :);
        T = computeSimilarityT(handles.im1_pts(26:27, :), avgEyePts);
        imgPtsTransformed = T*[im_pts'; ones(1, size(im_pts,1))];
        im1_pts = imgPtsTransformed(1:2,:)';
        img = imTrans(img, T);
    end
   
    im_pts = [im_pts; handles.corrPts];   
    
    [handles.morphed_im, handles.imMorph_pts] = morph(img, img, im_pts, im_pts_avg, handles.tri, 1, 0);

    imgW = 580;
    handles.morphed_im = handles.morphed_im(:,1:imgW,:);
    
    imgAvg = imgAvg + double(handles.morphed_im);
end
imgAvg = imgAvg/numImg;
imgAvg = uint8(imgAvg);

imwrite(imgAvg, [handles.resultsPath, 'mean_face.tif']);

guidata(hObject, handles);


function caricatureNormal_Callback(hObject, eventdata, handles)

contents = cellstr(get(handles.listboxImage1,'String'));
handles.imgName1 = contents{get(handles.listboxImage1,'Value')};

handles.img1 = imread([handles.imgPath, handles.imgName1, handles.fileExt]);
handles.im1_pts = load([handles.imgPath, handles.imgName1,'.txt'] , '-ascii');
handles.autoAlignFlag = get(handles.autoAlign, 'Value');
if(handles.autoAlignFlag)
    avgEyePts = handles.im_pts_avg(26:27, :);
    T1 = computeSimilarityT(handles.im1_pts(26:27, :), avgEyePts);
    
    img1PtsTransformed = T1*[handles.im1_pts'; ones(1, size(handles.im1_pts,1))];
    
    handles.im1_pts = img1PtsTransformed(1:2,:)';
    
    handles.img1 = imTrans(handles.img1, T1);
end 

im1_pts_r = handles.im1_pts - handles.im_pts_avg;

for i = 0.0:0.5:2
%     i = 0.25*ind;
    im1_pts_new = im1_pts_r*i + handles.im_pts_avg;
    im1_pts_new = [im1_pts_new; handles.corrPts];
    im1_pts_old = [handles.im1_pts; handles.corrPts];
    handles.tri = delaunay((im1_pts_new(:,1)), (im1_pts_new(:,2)));
    
    [handles.morphed_im, handles.imMorph_pts] = morph(handles.img1, handles.img1, im1_pts_old, im1_pts_new, handles.tri, 1, 0);
    imgName = ['cari_normal_', handles.imgName1, num2str(i),handles.fileExt];
    morphedImg = imresize(handles.morphed_im, 0.25);
    imwrite(morphedImg, [handles.resultsPath, imgName]);
end

function pushbutton9_Callback(hObject, eventdata, handles)


