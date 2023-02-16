function mn_roi = sroi_dm_tc(data_dir,roi_dir, ...
    data_filenm_mask,roi_filenm_mask,brain_mask_file,global_flag)
%Function to create mean ROI timecourse given an ROI (mask/seed) and the
%dataset
%Usage
%   mn_roi_tc = roi_mn_tc(data_dir,roi_dir,data_filenm_mask, ...
%       roi_filename_mask,brain_mask_file)
%   data_dir - directory containing the preprocessed data files (3D nifti)
%   roi_dir  - directory containing the ROI masks
%   data_filenm_mask - string containing the common substring for the
%       preprocessed files (typically 'fswa' or 'swa')
%   roi_filenm_mask - string containing the common substring for the ROI
%       files (typically {'RSN','ACC'})
%   brain_mask_file - string with brain mask filename

% by Suresh E Joel - modified July, 2009; modified Sep 16,2009

if(nargin<4),
    error('Not enough arguements');
end;

%% Get orientation of data file (to match all masks to the same orientation)
files=dir(fullfile(data_dir,[data_filenm_mask,'*.img']));
so=get_orient(fullfile(data_dir,files(1).name));
clear files;

%% Read brain mask is specified
if(nargin>4)
    V=spm_vol(brain_mask_file);
    bM=spm_read_vols(V);
end;

%% Read the ROI mask files
disp('Reading Mask Files');
% if(ischar(roi_filenm_mask)), roi_filenm_mask{1}=roi_filenm_mask; end;
n=1;
nrois = length(roi_filenm_mask);
for i_rmask=1:nrois,
    if exist(fullfile(roi_dir,[roi_filenm_mask{i_rmask},'.img']))
        %     files=dir(fullfile(roi_dir,[roi_filenm_mask{i_rmask},'*.img']));
        files=dir(fullfile(roi_dir,[roi_filenm_mask{i_rmask},'*.img']));
        filetype=1;
    else
        %     files=dir(fullfile(roi_dir,[roi_filenm_mask{i_rmask},'*.nii']));
        files=dir(fullfile(roi_dir,[roi_filenm_mask{i_rmask},'*.nii']));
        filetype = 2;
    end
    %sM=zeros(V.dim(1),V.dim(2),V.dim(3),length(files));
    for i_roi=1:length(files),
        %         P{n}=fullfile(roi_dir,files(i_roi).name,',1'); %#ok
        P{n}=[fullfile(roi_dir,files(i_roi).name),',1']; %#ok
        %         if(~strcmp(get_orient(P{n}),so)),
        %             change_orient(P{n},so);
        %         end;
        if filetype==1
            mn_roi.name{n}=strrep(files(i_roi).name,'.img','');
        elseif filetype==2
            mn_roi.name{n}=strrep(files(i_roi).name,'.nii','');
        end
        n=n+1;
    end;
    clear files;
end;
P=strvcat(P); %#ok

%warning off;%#ok
V=spm_vol(P);
sM=spm_read_vols(V);
%reshape sM to be voxels X rois
sM = reshape(sM, [numel(sM(:, :, :, 1)), numel(sM(1, 1, 1, :))]);

% Load functional data
disp('Reading & computing ROI mean timecourse');
clear files V P;
files=dir(fullfile(data_dir,[data_filenm_mask,'*.img']));
fdata = {files.name}';
fdata = fullfile(data_dir, strcat(fdata, ', 1'));
V=spm_vol(strvcat(fdata));
Y = spm_read_vols(V);
%reshape Y to be voxels X timepoints
Y = reshape(Y, [numel(Y(:, :, :, 1)), numel(Y(1, 1, 1, :))]);
clear V;

%initialize mn_roi.tcs
mn_roi.tc=zeros(nrois,length(files));

%multiply data by roi distribution, divide by column sums to get average
mn_roi.tcs = ((Y'*sM)./ repmat(sum(sM, 1), size(Y, 2), 1))';

%% Save the timecourses
for iroi=1:length(mn_roi.name),
    tc=mn_roi.tcs(iroi,:);%#ok
    if(~global_flag)
        save(fullfile(data_dir,[mn_roi.name{iroi},'_dm_mn_roi_tc.mat']),'tc');
    else
        save(fullfile(data_dir,[mn_roi.name{iroi},'_dm_g_mn_roi_tc.mat']),'tc');
    end;
end;