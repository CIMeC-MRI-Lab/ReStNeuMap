function runalphascript(SubjectDir, flags); 
%====================================================================================
%====================================================================================
% step 1 default changed to bad slice filter instead of median filter - pkm 2014

%--Identify spm version
[ dummy, spm_ver ] = fileparts(spm('Dir'));

%====================================================================================
%			STEP 0. EXPAND FLAGS STRUCTURE AND CREATE PRPROC_DATA
%====================================================================================

images		= flags.images;
process		= flags.process;
prefix		= flags.prefix;
sliceTime	= flags.sliceTime;
realign		= flags.realign;
smooth		= flags.smooth;
norm		= flags.norm;
purge		= flags.purge;

nsess = size(images,1);

%--Create preproc_data
if ~exist([SubjectDir 'preproc_data/'],'dir')
	mkdir(SubjectDir,'preproc_data')
end

%--Send a copy of a raw image to preproc_data
	copyfile([SubjectDir images(1,:) '4D_00*' ], [SubjectDir 'preproc_data/'])

%====================================================================================
%			STEP 1. BAD SLICE FILTER  (previously was median filter)
%====================================================================================

if process(1)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s:\n',['Starting To Repair Bad Slices (median filter) for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg)
		close(fg);
	end
	alpha_windows(2);


	%--Perform median filter
	realname = [ '^' prefix{1} '.*\.nii$'  ];
	for(i=1:nsess)
		imgFile = spm_select('FPList',[SubjectDir images(1,:) ], realname);
		alpha_art_slice(imgFile, 2);
                %alpha_art_slice(imgFile, 1);   median filter option
	end

	%--Send a copy of a filtered image to preproc_data
	copyfile([SubjectDir images(1,:) 'f' prefix{1} '_00*' ], [SubjectDir 'preproc_data/']);
    %copyfile([SubjectDir images(1,:) 'g' prefix{1} '_010*' ], [SubjectDir 'preproc_data/']);

	%--Close SPM windows
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg),
	close(fg);
	end

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Rapairing Bad Slices (median filter) Done for ' SubjectDir]);                                          
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

else
end

%====================================================================================
%			STEP 2. SLICE TIME CORRECTION
%====================================================================================

if process(2)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Slice Time Correction Starting for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg)
		close(fg);
	end
	alpha_windows(2);

	%--Perform slice time correction
	realname = [ '^' prefix{2} '.*\.nii$'  ];
	for(i=1:nsess)
		imgFile = spm_select('FPList',[SubjectDir images(1,:) ], realname);
		alpha_slicetiming(imgFile, sliceTime.order, sliceTime.interval)
	end

	%--Send a copy of a slice time corrected image to preproc_data
	copyfile([SubjectDir images(1,:) 'a' prefix{2} '_00*' ], [SubjectDir 'preproc_data/']);

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['...Slice Time Correction Done for ' SubjectDir]);                                          
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	
else
end

%====================================================================================
%			STEP 3. REALIGNMENT
%====================================================================================

if process(3)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Realignment Starting for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	alpha_windows(3);

	%--Perform slice time correction
	for(i=1:nsess)
		ImgDir = [SubjectDir images(1,:) ];
		realname = [ '^' prefix{3} '.*\.nii$'];
		imgFile = spm_select('FPList',[SubjectDir images(1,:)], realname);
		% Save the first image, replace with source image for realignment
		realname21 = [ prefix{3} '_00001.nii'];	
		%realname22 = [ prefix{3} '_001.hdr']; 
		%realname23 = [ prefix{3} '_001.mat'];
		copyfile([ImgDir realname21], [ImgDir 'old_' realname21],'f');
		%copyfile([ImgDir realname22], [ImgDir 'old_' realname22],'f');
		%if exist([ImgDir realname 23]) copyfile([ImgDir realname23], [ImgDir  'old_' realname23],'f'); end;
		realname31 = [ prefix{3} '_' realign.source '.nii']; 
		%realname32 = [ prefix{3} '_' realign.source '.hdr']; 
		%realname33 = [ prefix{3} '_' realign.source '.mat'];
		copyfile([ImgDir realname31], [ImgDir  realname21],'f');
		%copyfile([ImgDir realname32], [ImgDir  realname22],'f');
		%if exist([ImgDir realname33]) copyfile([ImgDir  realname33], [ImgDir  realname23],'f'); end;
		alpha_realign(imgFile);
	end

	%--Send realignment graphic and a copy of a realigned image to preproc_data
	copyfile([SubjectDir images(1,:) 'r' prefix{3} '_00*' ], [SubjectDir 'preproc_data/']);
	graphicps = [];
	graphicps = spm_select('FPList',[pwd],'.*\.ps$')
	if graphicps(1,:) == '/'
		fprintf('%-4s\n',['No graphic to save']);
	else
		movefile(graphicps(1,:),[SubjectDir '/preproc_data/realignment.ps'])
	end


	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Realignment and Reslice Done for ' SubjectDir]);                                         
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	
else
end

%====================================================================================
%			STEP 4. ARTIFACT DESPIKE
%====================================================================================

if process(4)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Artifact Despiking Starting for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg),
		close(fg);
	end
	alpha_windows(2);

	%--Perform artifact despike
	realname = [ '^' prefix{4} '.*\.nii$'  ];
	for(i=1:nsess)
		imgFile = spm_select('FPList',[SubjectDir images(1,:) ], realname);
		alpha_art_despike(imgFile, 2, 8);
	end

	%--Send a copy of a despiked image to preproc_data
	copyfile([SubjectDir images(1,:) 'd' prefix{4} '_00*' ], [SubjectDir 'preproc_data/']);

	%--Move art_despike figure to preproc_data and close figure
	if ~isempty(gcf)
		saveas(gcf,'artdespike.jpg');
		movefile('artdespike.jpg', [ SubjectDir 'preproc_data/']);
		close(gcf);
	end

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Artifact Despiking done for ' SubjectDir]);                                         
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

else
end

%====================================================================================
%			STEP 5. SMOOTHING
%====================================================================================

if process(5)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Smoothing Starting for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg),
		close(fg);
	end
	alpha_windows(2);

	%--Perform individual smoothing
	realname = [ '^' prefix{5} '.*\.nii$'  ];
	for(i=1:nsess)
		imgFile = spm_select('FPList',[SubjectDir images(1,:) ], realname);
		alpha_smooth(imgFile,smooth.individualFWHM);
	end

	%--Send a copy of an individual smoothed image to preproc_data
	copyfile([SubjectDir images(1,:) 's' prefix{5} '_00*' ], [SubjectDir 'preproc_data/']);

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Smoothing Done for ' SubjectDir]);                                         
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	
else
end

%====================================================================================
%			STEP 6. MOTION CORRECTION
%====================================================================================

if process(6)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Motion Adjust Starting for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg),
		close(fg);
	end
	alpha_windows(2);

	%--Perform motion correction
	realname = [ '^' prefix{6} '.*\.nii$'  ];
	for(i=1:nsess)
		unrealname = ['^' prefix{6} '.*\.nii$'];
		alpha_motionJ([SubjectDir images(1,:) ],realname,[SubjectDir images(1,:) ],unrealname);
	end

	%--Send a copy of a motion corrected image to preproc_data
	copyfile([SubjectDir images(1,:) 'm' prefix{6} '_00*' ], [SubjectDir 'preproc_data/']);

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Motion Adjust Done for ' SubjectDir]);                                         
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	
else
end

%====================================================================================
%			STEP 7. ARTIFACT DETECTION AND REPAIR
%====================================================================================

if process(7)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n','Artifact Detection and Repair Starting...');                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	alpha_windows(0);

	%--Perform artifact detection and repair
	realname = [ '^' prefix{7} '.*\.nii$'  ];
	for(i=1:nsess)
		imgFile = spm_select('FPList',[SubjectDir  images(1,:) ], realname);
		mvfile = [SubjectDir images(1,:) 'rp_' prefix{3} '_00001.txt'];  % same prefix as realignment.];
		alpha_art_global(imgFile, mvfile, 4,2);
	end

	%--Send copied of results files, mask files, and an repaired image to preproc_data
	copyfile([SubjectDir images(1,:) 'v' prefix{7} '_00*' ], [SubjectDir 'preproc_data/']);
	copyfile([SubjectDir images(1,:) 'Artifact*'], [SubjectDir 'preproc_data/']);
	copyfile([SubjectDir images(1,:) '*.txt'], [SubjectDir 'preproc_data/']);	
	%--Move artglobal.jpg to preproc_data
	movefile('artglobal*', [ SubjectDir 'preproc_data/']);

	%--Close art_repair figure
% 	if ~isempty(gcf)
% 		close(gcf);
% 	end

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n','...Artifact Detection and Repair Done');
    fprintf('%3s\n','...Repaired Files start with prefix v.')
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	
else
end


%====================================================================================
%			STEP 8. COREGISTRATION
%====================================================================================

if process(8)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Coregistration Starting for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg),
		spm_figure('Clear');
	end
	alpha_windows(3);

	%--Perform coregistration
    imgFile = [];
	if norm.method == 2
		anatImg = spm_select('FPList',[SubjectDir norm.method2.anatDir],['^' norm.method2.anatPrefix '.*\.nii$']);
		segmentTemplate.gray = spm_select('FPList',[norm.method2.templateDir],norm.method2.templateFile.gray);
		segmentTemplate.white = spm_select('FPList',[norm.method2.templateDir],norm.method2.templateFile.white);
		segmentTemplate.csf = spm_select('FPList',[norm.method2.templateDir],norm.method2.templateFile.csf);
		alpha_coregprep(anatImg,segmentTemplate);
		coregistrationTemplate = spm_select('FPList',[SubjectDir images(1,:)],'^mean.*\_001.nii');
		source = spm_select('FPList',[SubjectDir norm.method2.anatDir],['^c1' norm.method2.anatPrefix '.*\.nii$']);
		alpha_coreg(coregistrationTemplate,source,imgFile);
		copyfile([SubjectDir norm.method2.anatDir 'c1*'], [SubjectDir 'preproc_data/']);
	
		%--Send coregistration graphic to preproc_data
		graphicps = [];
		graphicps = spm_select('FPList',[pwd],'.*\.ps$')
		if graphicps(1,:) == '/'
			fprintf('%-4s\n',['No graphic to save']);
		else
			movefile(graphicps(1,:),[SubjectDir '/preproc_data/coregistration.ps'])
		end
	end

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Coregistration Done for ' SubjectDir]);                                          
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

else
end

%====================================================================================
%			STEP 9. NORMALIZATION
%====================================================================================

if process(9)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Normalization Starting for ' SubjectDir]);    
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	alpha_windows(3);

	%--Perform normalization
	realname = [ '^' prefix{9} '.*\.nii$'  ];
	imgFile = [];
	for(i=1:nsess)
		imgFile = [imgFile; spm_select('FPList',[SubjectDir images(1,:) ], realname)];
	end
	if norm.method == 1
		template_file = spm_select('FPList',[norm.method1.templateDir],norm.method1.templateFile);
		sourceFile = spm_select('FPList',[SubjectDir images(1,:)],'^mean.*\.nii');
		alpha_normalize1(template_file,sourceFile,norm.method);
		paramFile = spm_select('FPList',[SubjectDir images(1,:)],'^mean.*\_sn.mat');
		alpha_normalize2(norm.method,paramFile,imgFile);
	elseif norm.method == 2
		template_file = spm_select('FPList',[norm.method2.templateDir],norm.method2.templateFile.gray);
		sourceFile = spm_select('FPList',[SubjectDir norm.method2.anatDir],['^c1' norm.method2.anatPrefix '.*\.nii$']);
		alpha_normalize1(template_file,sourceFile,norm.method);
		paramFile = spm_select('FPList',[SubjectDir norm.method2.anatDir],['^c1' norm.method2.anatPrefix '.*\_sn.mat$']);
		alpha_normalize2(norm.method,paramFile,imgFile);
		copyfile([SubjectDir norm.method2.anatDir '*.mat'], [SubjectDir 'preproc_data/']);
		copyfile([SubjectDir norm.method2.anatDir 'wc1*'], [SubjectDir 'preproc_data/']);
	end

	%--Send normalization graphic and a copy of anormalized image to preproc_data
	copyfile([SubjectDir images(1,:) 'w' prefix{9} '_010*' ], [SubjectDir 'preproc_data/']);
	graphicps = [];
	graphicps = spm_select('FPList',[pwd],'.*\.ps$')
	if graphicps(1,:) == '/'
		fprintf('%-4s\n',['No graphic to save']);
	else
		movefile(graphicps(1,:),[SubjectDir '/preproc_data/normalization.ps'])
	end

	%--Clean up anatomical directory
	if norm.method == 2
		mkdir([SubjectDir 'xtemp123'])
		try	copyfile([SubjectDir norm.method2.anatDir norm.method2.anatPrefix '*'], [SubjectDir 'xtemp123/']);
		catch
		end
		try rmdir([SubjectDir norm.method2.anatDir],'s');
		catch
		end
		movefile([SubjectDir 'xtemp123/'], [SubjectDir norm.method2.anatDir]);
	end

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Normalization Done for ' SubjectDir]);                                         
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	
else
end

%====================================================================================
%			STEP 10. GROUP SMOOTHING
%====================================================================================

if process(10)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Group Smoothing Starting for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	%--Check that the appropriate SPM windows are present
	alpha_windows(2);

	%--Perform group smoothing
	realname = [ '^' prefix{10} '.*\.nii$'  ];
	for(i=1:nsess)
		imgFile = spm_select('FPList',[SubjectDir images(1,:) ], realname);
		alpha_smooth(imgFile,smooth.groupFWHM);
	end

	%--Send a copy of group smoothed image to preproc_data
	copyfile([SubjectDir images(1,:) 's' prefix{10} '_010*' ], [SubjectDir 'preproc_data/']);

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Group Smoothing Done for ' SubjectDir]);                                         
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	
else
end

%====================================================================================
%			STEP 11. PURGE INTERMEDIATE FILES
%====================================================================================

if process(11)==1

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%-4s\n',['Deleting intermediate files for ' SubjectDir]);                                  
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

	alpha_deletefiles(SubjectDir,images,purge)

	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%3s\n',['Finished deleting files for ' SubjectDir]);                                         
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');
	fprintf('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n');

end
