clear matlabbatch
%Save path to where 4D files are stored
newpath='';

%Create cell array for all IDs and date of scan
all = {};
dos = {};

%Loop through all the IDs
for ipid = 1:length(all)
    ID = all{ipid};
    DOS = dos{ipid};
    func = fullfile(newpath, ID, DOS, 'func', 'run-01');
    
    %Search for preporcessed data file
    filewanted = dir(fullfile(func,'fsnwc50*.img'));
    filewanted = strcat(func,'\',filewanted(1).name,',1');
    matlabbatch{ipid}.spm.util.split.vol = {filewanted};
    matlabbatch{ipid}.spm.util.split.outdir = {''};
end
spm('defaults','fmri');
spm_jobman('initcfg');

spm_jobman('run',matlabbatch);