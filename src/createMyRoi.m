%use binarised and threshold the maps
%create ROIs
%change the subjects and their peak coordinates
clear

run '../lib/CPP_SPM/initCppSpm.m'

%use for referecing to an image, better to use a single subject for creating Rois now
opt.subject={'sub-005'};

opt.roi = {'lhMT','rhMT','lS1','lPC', 'rPC', 'lMTt', 'rMTt'};

%list of all the binarised/thresholded neurosynth masks 
opt.maskName = {fullfile(pwd,'inputs','space-MNI_label-neurosynthVisualMotion_mask.nii'), fullfile(pwd,'inputs','space-MNI_label-neurosynthVisualMotion_mask.nii'),...
    fullfile(pwd,'inputs','space-MNI_label-neurosynthTactile_mask.nii'),...
    fullfile(pwd,'inputs','space-MNI_label-neurosynthParietal_mask.nii'),fullfile(pwd,'inputs','space-MNI_label-neurosynthParietal_mask.nii'),...
    fullfile(pwd,'inputs','space-MNI_label-neurosynthVisualMotion_mask.nii'), fullfile(pwd,'inputs','space-MNI_label-neurosynthVisualMotion_mask.nii')};

%peak coordinates of the 7 rois for each subject observed manually in SPM
%by applying the mask
opt.sphere.location = {[-49.40,-62.60, 0.20],[52,-67.80,5.40],[-44.2,-23.6, 65.20],[-26,-41.8,62.60], [32.18,-41.51,66.11], [-46.8,-65.2,10.60],[41.60,-57.40,8.00]};

opt.sphere.radius = 4; % starting radius
opt.sphere.maxNbVoxels = 500; % number of voxels in the new masks

opt.roiName={strcat(opt.subject,'_hemi-L_space-MNI_label-hMT_desc-visual_mask.nii'), strcat(opt.subject,'_hemi-R_space-MNI_label-hMT_desc-visual_mask.nii'),...
    strcat(opt.subject,'_hemi-L_space-MNI_label-S1_desc-tactile_mask.nii'),...
    strcat(opt.subject,'_hemi-L_space-MNI_label-PC_desc-tactile_mask.nii'), strcat(opt.subject,'_hemi-R_space-MNI_label-PC_desc-tactile_mask.nii'),...
    strcat(opt.subject,'_hemi-L_space-MNI_label-MTt_desc-tactile_mask.nii'),strcat(opt.subject,'_hemi-R_space-MNI_label-MTt_desc-tactile_mask.nii')};

opt.save.roi = true;
opt.outputDir = (fullfile(pwd,'outputMasks', char(opt.subject))); % if this is empty new masks are saved in the current directory.

%used for referencing 
% dataImage = fullfile('/Users/shahzad/Files/fMRI/visTacMotionDir/derivatives/cpp_spm-stats',char(opt.subject), 'stats/task-mainExperiment2_space-MNI_FWHM-0', 'beta_0001.nii');
dataImage = fullfile('/Users/shahzad/Files/fMRI/visTacMotionDir/derivatives/cpp_spm-stats','sub-004', 'stats/task-mainExperiment2_space-MNI_FWHM-0', 'beta_0001.nii');



%for 
for iSub = 1:length(opt.subject)
    for iRoi = 1:length(opt.roi)
        
        % to create new names for rois for the renameMyRoi function
        subName=char(opt.subject(iSub));
        roiName = char(opt.roi(iRoi));
        voxelNb= num2str(opt.sphere.maxNbVoxels);
        
        %this creates the new Rois by expansion. expansion srarts from the
        %given peak coordinate
        maskName=char(opt.maskName(iRoi));
        sphere.location=cell2mat(opt.sphere.location(iRoi));
        sphere.radius = opt.sphere.radius;
        sphere.maxNbVoxels=opt.sphere.maxNbVoxels;
        
        specification  = struct( ...
                          'mask1', maskName, ...
                          'mask2', sphere);

        mask = createRoi('expand', specification, dataImage, opt.outputDir, opt.save.roi);
        
        %this function renames the saved rois
        renameMyRoi(subName, roiName,'.nii',voxelNb)
        renameMyRoi(subName, roiName,'.json',voxelNb)


        data_expand = spm_summarise(dataImage, mask.roi.XYZmm);
           
    end
end



%% function

function renameMyRoi(subName, roiName,fileFormat,voxelNb)

    switch roiName
        case 'lhMT'
            hemi='L';
            label='lhMT';
        case 'rhMT'
            hemi='R';
            label='rhMT';
        case'lS1'
            hemi='L';
            label='lS1';
        case'lPC'
            hemi='L';
            label='lPC';
        case 'rPC'
            hemi='R';
            label='rPC';
        case'lMTt'
            hemi='L';
            label='lMTt';
        case 'rMTt'
            hemi='R';
            label='rMTt';
    end 
    
    switch fileFormat
        case '.nii'
            ext='*mask.nii';
        case '.json'
            ext='*mask.json';
    end
    
    subName=char(subName);
    
    fileInfo = dir(fullfile(pwd,'outputMasks', subName, ext) );
    oldName = fileInfo.name;
    newName = strcat(subName,'_','hemi-',hemi,'_','space-MNI', '_','label-',label,'_', 'vox-',voxelNb,fileFormat);
    movefile( fullfile(pwd,'outputMasks', subName, oldName), char(fullfile(pwd,'outputMasks', subName, newName) ));
    disp(hemi)
    disp(label)
    disp(oldName)
    disp(newName)
    
end