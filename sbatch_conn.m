clear; clc
%Add path to where seed-based processing scripts are stored
addpath ''
%Save path to where 4D files are stored
newpath='';
%Set directory for where the seeds regions are located
roidir='';
%All pre-processed files have tshe following prefix
data_filenm_mask='fsnwc50';
%Create cell array for all IDs and date of scan
all = {};
dos = {};
%Add file path pointing to brain mask
brain_mask_filenm = '';

%% Loop through pipeline
for ipid = 1:length(all)
    ID = all{ipid};
    DOS = dos{ipid};
    data_dir = fullfile(newpath, ID, DOS, 'func', 'run-01');
    
    fprintf('========== Creating DMN & DAN Connectivity maps for %s %s ==========\n', ID, DOS);
    sroi_dm_tc(data_dir,roidir,data_filenm_mask, ...
        {'FEF_taskpos','IPS_taskpos','MT+_taskpos','LP_taskneg','MPF_taskneg','PCC_taskneg'}, brain_mask_filenm,0);
    fprintf('sroi_dm_tc Done!\n');
    
    sconn(data_dir,data_filenm_mask, ...
        {'FEF_taskpos','IPS_taskpos','MT+_taskpos','LP_taskneg','MPF_taskneg','PCC_taskneg'}, brain_mask_filenm);
    fprintf('sconn Done!\n');
    
    smakepos_meanmaps(data_dir, ...
        {'FEF_taskpos','IPS_taskpos','MT+_taskpos'}, brain_mask_filenm);
    fprintf('smakepos_meanmaps Done!\n');
    
    smakeneg_meanmaps(data_dir, ...
        {'LP_taskneg','MPF_taskneg','PCC_taskneg'}, brain_mask_filenm);
    fprintf('smakeneg_meanmaps Done!\n');
    
    smakeNaN_meanmaps(data_dir, {'pos_mean'}, brain_mask_filenm);
    fprintf('smakeNaN_meanmaps for pos_mean Done!\n');
    
    smakeNaN_meanmaps(data_dir, {'neg_mean'}, brain_mask_filenm);
    fprintf('smakeNaN_meanmaps for neg_mean Done!\n');
end
    