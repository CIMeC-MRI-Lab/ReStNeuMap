function alpha_deletefiles(SubjectDir,images,purge)


%--Perform file cleanup on images directory
if purge.images == 1 || purge.images == 2
	mkdir([SubjectDir 'xxtemp123'])
	try	copyfile([SubjectDir images(1,:) 'I_*'], [SubjectDir 'xxtemp123/']);
	catch
	end
end
if purge.images == 1
	try copyfile([SubjectDir images(1,:) 'sw*'], [SubjectDir 'xxtemp123/']);
	catch
	end
	try copyfile([SubjectDir images(1,:) 'mean*'], [SubjectDir 'xxtemp123/']);
	catch
	end
	try copyfile([SubjectDir images(1,:) 'vms*'], [SubjectDir 'xxtemp123/']);
	catch
		try copyfile([SubjectDir images(1,:) 'msd*'], [SubjectDir 'xxtemp123/']);
		catch
		end
	end
	try copyfile([SubjectDir images(1,:) 'art_*'], [SubjectDir 'xxtemp123/']);
	catch
	end
end
if purge.images == 1 || purge.images == 2
	try rmdir([SubjectDir images(1,:)],'s');
	catch
	end
	movefile([SubjectDir 'xxtemp123/'], [SubjectDir images(1,:)]);
end

%--Perform file cleanup on preproc_data folder
if purge.preproc_data == 1
	try rmdir([SubjectDir 'preproc_data/'],'s');
	catch
	end
end

