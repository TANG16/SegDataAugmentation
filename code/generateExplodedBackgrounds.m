outputFolder = fullfile('../data/', 'caltech101/train');
rootFolderImages = fullfile(outputFolder, '101_ObjectCategories');
rootFolderAnnotations = fullfile(outputFolder, 'Annotations');

folderNamesI = dir(rootFolderImages);
%folderNamesI = folderNamesI(~ismember({folderNamesI.name},{'.','..','.DS_Store','BACKGROUND_Google'}));
folderNamesI  = folderNamesI(ismember({folderNamesI.name},{'anchor','butterfly','platypus','chair','crayfish','lobster'}));

folderNamesA = dir(rootFolderAnnotations);
%folderNamesA = folderNamesA(~ismember({folderNamesA.name},{'.','..','.DS_Store','BACKGROUND_Google'}));
folderNamesA = folderNamesA(ismember({folderNamesA.name},{'anchor','butterfly','platypus','chair','crayfish','lobster'}));

imageClassNames = {};
annotationClassNames = {};

for index = 1:numel(folderNamesI)
    imageClassNames{end+1} = folderNamesI(index).name; 
end

for index = 1:numel(folderNamesA)
    annotationClassNames{end+1} = folderNamesA(index).name; 
end
   

alexNetSize = [227 227];
for fIndex =  1:length(imageClassNames)
    imageClassName = imageClassNames{fIndex};
    annotationIndex = find(strcmp(annotationClassNames, imageClassName));
    
    %no annotation exists for this class, so skip
    if length(annotationIndex) == 0
        continue;
    end
    annotationClassName = annotationClassNames{annotationIndex};
    
    assert(strcmp(annotationClassName,imageClassName),'this should not happen');
    imagePaths = dir(strcat(folderNamesI(fIndex).folder,'/',imageClassName));
    annotationPaths = dir(strcat(folderNamesA(annotationIndex).folder,'/',imageClassName));
    
    imagePaths = imagePaths(~ismember({imagePaths.name},{'.','..','.DS_Store'}));
    annotationPaths = annotationPaths(~ismember({annotationPaths.name},{'.','..','.DS_Store'}));

    if(length(annotationPaths) == 0 )
        continue;
    end
    
    destinationFolderBg = strcat(outputFolder,'/masks/class_bg/',imageClassName);
    if ~exist(destinationFolderBg, 'dir')
        mkdir(destinationFolderBg);
    end
    
    destinationFolder = strcat(outputFolder,'/masks/class_bg_masks/',imageClassName);
    if ~exist(destinationFolder, 'dir')
        mkdir(destinationFolder);
    end

    for iIndex = 1:length(imagePaths)
        iPath = strcat(imagePaths(iIndex).folder,'/',imagePaths(iIndex).name);
        aPath = strcat(annotationPaths(iIndex).folder,'/',annotationPaths(iIndex).name);
        backgroundMask = segmentBackground(iPath,aPath);
        backgroundImage = imread(iPath);
        bgImage = bsxfun(@times, backgroundImage, cast(backgroundMask,class(backgroundImage)));
        
        backgroundMask = double(imresize(backgroundMask,alexNetSize));
        bgImage  = double(imresize(bgImage,alexNetSize));
        iName = imagePaths(iIndex).name;
        iNameSplit = strsplit(iName,{'_','.'});
        
        bgMaskFname = strcat(destinationFolder,'/','mask_',iNameSplit(2),'.mat');
        bgFname = strcat(destinationFolderBg,'/','background_',iNameSplit(2),'.mat');
        save(bgMaskFname{1},'backgroundMask');
        save(bgFname{1},'bgImage');
        
    end
    
end
