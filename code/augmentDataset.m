outputFolder = fullfile('../data/', 'caltech101/train');
rootFolderImages = fullfile(outputFolder, '101_ObjectCategories');
rootFolderMasks = fullfile(outputFolder, 'masks/class_bg_masks');
rootFolderBackgrounds = fullfile(outputFolder, 'masks/mean_background');
rootFolderAugmented = fullfile(outputFolder, '101_ObjectCategoriesAugmented');

folderNamesI = dir(rootFolderImages);
%folderNamesI = folderNamesI(~ismember({folderNamesI.name},{'.','..','.DS_Store','BACKGROUND_Google'}));
folderNamesI =  folderNamesI(ismember({folderNamesI.name},{'anchor','butterfly','platypus','chair','crayfish','lobster'}));

folderNamesM = dir(rootFolderMasks);
%folderNamesM = folderNamesM(~ismember({folderNamesM.name},{'.','..','.DS_Store','BACKGROUND_Google'}));
folderNamesM = folderNamesM(ismember({folderNamesM.name},{'anchor','butterfly','platypus','chair','crayfish','lobster'}));
imageClassNames = {};
maskClassNames = {};

for index = 1:numel(folderNamesI)
    imageClassNames{end+1} = folderNamesI(index).name; 
end

for index = 1:numel(folderNamesM)
    maskClassNames{end+1} = folderNamesM(index).name; 
end

destinationFolderAugmented = strcat(rootFolderAugmented,'/Data_Augmented');
if ~exist(destinationFolderAugmented, 'dir')
    mkdir(destinationFolderAugmented);
end

for fIndex =  1:length(imageClassNames)
    imageClassName = imageClassNames{fIndex};
    maskIndex = find(strcmp(maskClassNames, imageClassName));
    if length(maskIndex) == 0
        continue;
    end
    maskClassName = maskClassNames{maskIndex};
    
    assert(strcmp(maskClassName,imageClassName),'no mask found for image');
    imagePaths = dir(strcat(folderNamesI(fIndex).folder,'/',imageClassName));
    maskPaths = dir(strcat(folderNamesM(maskIndex).folder,'/',imageClassName));
    

    
    imagePaths = imagePaths(~ismember({imagePaths.name},{'.','..','.DS_Store'}));
    maskPaths = maskPaths(~ismember({maskPaths.name},{'.','..','.DS_Store'}));
    
    if(length(maskPaths)==0)
        continue;
    end
    destinationFolder = strcat(destinationFolderAugmented,'/',imageClassName);
    if ~exist(destinationFolder, 'dir')
        mkdir(destinationFolder);
    end
    
    meanPath = strcat(rootFolderBackgrounds, '/', imageClassName, '.mat');
    for iIndex = 1:length(imagePaths)
        iPath = strcat(imagePaths(iIndex).folder,'/',imagePaths(iIndex).name);
        mPath = strcat(maskPaths(iIndex).folder,'/',maskPaths(iIndex).name);
        
        
        augmentedImage = replaceBackground(iPath,mPath, meanPath);
        actualImage = imread(iPath);
        imageFname = strcat(destinationFolder,'/',imagePaths(iIndex).name);
        imwrite(actualImage, imageFname);
        
        iName = imagePaths(iIndex).name;
        iNameSplit = strsplit(iName,'.');
        augmentedFname = strcat(destinationFolder,'/',iNameSplit(1), '_augmented.jpg');
        imwrite(augmentedImage, augmentedFname{1});
        
    end
end
