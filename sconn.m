function sconn(data_dir,data_filenm_mask,roi_filenm_mask,brain_mask_filenm)
cd(data_dir);

%subpath = 
% roi_conn(fullfile(newpath,all{ipid}),'fsdmwa', ...
%          {'FEF_taskpos','IPS_taskpos','MT+_taskpos','LP_taskneg','MPF_taskneg','PCC_taskneg'}, ...
%          roipath,'brain_mask');

% imgs = fullfile(data_dir,'Functionals',dir(strcat(data_filenm_mask,'*.img')));

%create a list of filenames
imgs = dir(strcat(data_filenm_mask,'*.img'));
imgs = {imgs.name}';
%read in the brain mask file
vdata = spm_vol(brain_mask_filenm);
v0 = spm_read_vols(vdata);
%create a list of zeros based on the number of values > 0 in the brain mask
%essentially create a matrix of zeros based of the number of values > 0 in
%the brain mask to fill in values
tseries = zeros(sum(v0(:)>0), length(imgs));

%fill in values from the image data where value is > 0 in the brain mask
for iimg = 1:size(imgs,1) 
    temp = spm_read_vols(spm_vol(imgs{iimg}));
    temp = temp(:);
    tseries(:, iimg) = temp(v0(:)>0);
end

%compute correlations
hw=waitbar(0,'Computing correlations');
%load time course data from each seed
for rois=1:length(roi_filenm_mask)
    roi1 = load(strcat(roi_filenm_mask{rois},'_dm_mn_roi_tc.mat'));
    roi = roi1.tc';
%
for ivox=1:size(tseries,1)
    waitbar(ivox/size(tseries,1),hw);    
    cc=corrcoef(roi',tseries(ivox,:));
    Yo(ivox,1)=cc(1,2);
    Yo(ivox,1)=fisher_r2z(Yo(ivox,:));
end;        
    result = v0;
    result(result~=0) = Yo;
    v1 = vdata;
    v1.fname = strcat('conn_',roi_filenm_mask{rois},'_dm_g_mn_roi_tc.img');
    v1.private.dat.fname=v1.fname;
    v1.dt=[16 0];
    % 2     4     8    16    64   256   512   768
%     0  UNKNOWN   
%    1  BINARY    
%    2  UINT8     
%    4  INT16     
%    8  INT32     
%   16  FLOAT32   
%   32  COMPLEX64 
%   64  FLOAT64   
%  128  RGB24     
%  256  INT8      
%  512  UINT16    
%  768  UINT32    
% 1024  INT64     
% 1280  UINT64    
% 1536  FLOAT128  
% 1792  COMPLEX128
% 2048  COMPLEX256
%    v1.private.dat.dtype='double';
    spm_write_vol(v1, result);
   clear Yo;clear result;clear v1; 

end
waitbar(1,hw);
close(hw);
clear temp; clear tseries;clear vdata;clear v0;clear xt;clear ms; clear sds;
% cd back to where your scripts are located.
cd();


