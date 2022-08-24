%binarise and threshold the maps
clear

run '../lib/CPP_SPM/initCppSpm.m'

%use for referecing to an image
opt.subjects={'sub-004'}; 

%lit of all the neurosynth masks 
neurosynthMaskName={'tactile_association-test_z_FDR_0.01.nii',...
    'parietal_association-test_z_FDR_0.01.nii',...
    'visual motion_association-test_z_FDR_0.01.nii'};

%for each mask, you binarise them ny thresholding them
for iNeurosynthMaskName = 1: length(neurosynthMaskName)
    zMap = fullfile(pwd, 'inputs', char(neurosynthMaskName(iNeurosynthMaskName)));
    % dataImage = fullfile(pwd, 'inputs', 'TStatistic.nii');
    dataImage = fullfile('/Users/shahzad/Files/fMRI/visTacMotionDir/derivatives/cpp_spm-stats',char(opt.subjects), 'stats/task-mainExperiment2_space-MNI_FWHM-0', 'beta_0001.nii');

    opt.unzip.do = true;
    opt.save.roi = true;
    opt.outputDir = []; % if this is empty new masks are saved in the current directory.
    if opt.save.roi
      opt.reslice.do = true;
    else
      opt.reslice.do = false;
    end
    [roiName, zMap] = prepareDataAndROI(opt, dataImage, zMap);
end


%% Functions
function [roiName, zMap] = prepareDataAndROI(opt, dataImage, zMap)

  if opt.unzip.do
    gunzip(fullfile('inputs', '*.gz'));
  end

  % give the neurosynth map a name that is more bids friendly
  %
  % space-MNI_label-neurosynthKeyWordsUsed_probseg.nii
  %
  zMap = renameNeuroSynth(zMap);

  if opt.reslice.do
    % If needed reslice probability map to have same resolution as the data image
    %
    % resliceImg won't do anything if the 2 images have the same resolution
    %
    % if you read the data with spm_summarise,
    % then the 2 images do not need the same resolution.
    zMap = resliceRoiImages(dataImage, zMap);
  end

  % Threshold probability map into a binary mask
  % to keep only values above a certain threshold
  threshold = 3; 
  roiName = thresholdToMask(zMap, threshold);
  roiName = removeSpmPrefix(roiName, spm_get_defaults('realign.write.prefix'));

end
