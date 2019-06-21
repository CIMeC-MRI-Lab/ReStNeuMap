% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'\\cimec-storage3\MUMI\Domenico_Zaca\clinicalRSdata\september15analysis_scripts\DataperAbstracrt\RSfMRI_SAB_04_78\PA0\ST0\SE1\ProcessDir\AbstractData\icacommand\coreg_rstoT1_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
