function smakepos_meanmaps(data_dir,roi_filenm_mask,brain_mask_filenm)

cd(data_dir);
%vdata = spm_vol('brain_mask.img');
vdata = spm_vol(brain_mask_filenm);
v0 = spm_read_vols(vdata);
tseries = zeros(sum(v0(:)>0),1);

for rois=1:length(roi_filenm_mask)
    img = dir(strcat('conn_',roi_filenm_mask{rois},'_dm_g_mn_roi_tc.img'));
    %imgs = {img.name}';
    imgs{rois} = img.name;
end
    
for (iimg = 1:length(roi_filenm_mask))
    iimg;
    v1=spm_vol(imgs{iimg});
    temp{iimg} = spm_read_vols(v1);
    temp{iimg} = temp{iimg}(:);
    roits(:,iimg) = temp{iimg}(v0(:)>0);
    %disp(iimg);
end

for (ivox = 1:size(tseries)) 
    tseries(ivox,1) = mean(roits(ivox,:));
    %disp(ivox);
end

result = v0;
    %result(result~=0) = conn_map;
result(result~=0) = tseries;

%v1 = vdata;
    %conn_PCC_taskneg_dm_g_mn_roi_tc.hdr
v1.fname = strcat('conn_pos_mean_dm_g_mn_roi_tc.img');
v1.private.dat.fname=v1.fname;
v1.dt=[16 0];

spm_write_vol(v1, result);
clear result;clear v1;
%end  

clear temp; clear ts
clear tseries;clear vdata;clear v0;
%cd back to where your scripts are located.
cd();

