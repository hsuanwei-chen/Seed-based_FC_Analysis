function smakeNaN_meanmaps(data_dir,roi_filenm_mask,brain_mask_filenm)

cd(data_dir);

%for rois=1:length(roi_filenm_mask)
    img = dir(strcat('conn_',roi_filenm_mask{1},'_dm_g_mn_roi_tc.img'));
    %imgs{rois} = img.name;
    imgs = [img.name];
%end
    %vdata = spm_vol('brain_mask.img');
    vdata = spm_vol(brain_mask_filenm);
%vtemp = spm_vol('wa825_rs_001.img');
%v0 = spm_read_vols(spm_vol('brain_mask.img'));

    v0 = spm_read_vols(vdata);
    tseries = zeros(sum(v0(:)>0),1);
for (iimg = 1:size(imgs,1)) 
    temp = spm_read_vols(spm_vol(imgs));
    temp = temp(:);
    tseries(:, iimg) = temp(v0(:)>0);
    %disp(iimg);
end

for (ivox = 1:size(tseries, 1)) 
    tseries(ivox, :) = (tseries(ivox, :));
    %disp(ivox);
end

result = v0;
    %result(result~=0) = conn_map;
result(result~=0) = tseries;
result(result==0) = NaN;

v1 = vdata;
    %conn_PCC_taskneg_dm_g_mn_roi_tc.hdr
v1.fname = strcat(strcat('conn_NaN_',roi_filenm_mask{1},'_dm_g_mn_roi_tc.img'));
v1.private.dat.fname=v1.fname;
v1.dt=[16 0];

spm_write_vol(v1, result);
clear result;clear v1;
%end  

clear temp; clear ts
clear tseries;clear vdata;clear v0;
%cd back to where your scripts are located.
cd();
