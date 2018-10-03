function alpha_realign(imgFile)
%====================================================================================
%====================================================================================
% Same as function m_realign(realfiles)
% But this one reslices the images to create images starting with r..
% Compatible with SPM5 and SPM2

spm_defaults;
global defaults
defs = defaults.realign;
modality = 'fmri';

realfiles = imgFile;

%SPMid                   = spm('FnBanner',mfilename,'2.10');
%[Finter,Fgraph,CmdLine] = spm('FnUIsetup','Realign');
%spm_help('!ContextHelp',mfilename);

flagsC = struct('quality',defs.estimate.quality,'fwhm',5,'rtm',0);
FlagsR = struct('interp',defs.write.interp,...
	'wrap',defs.write.wrap,...
	'mask',defs.write.mask,...
	'which',2,'mean',1);

%spm('Pointer','Watch');
%spm('FigName',['Realigning subj ' num2str(i)],Finter,CmdLine);
spm_realign(realfiles,flagsC);
%spm('FigName',['Reslicing subj ' num2str(i)],Finter,CmdLine);
spm_reslice(realfiles,FlagsR);
%spm('FigName','Realign: done',Finter,CmdLine);
%spm('Pointer');
return;
