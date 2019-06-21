function alpha_windows(n);



if n == 1 || n == 3
	fg = spm_figure('FindWin','Graphics');
	if ~isempty(fg),
	else
		Fgraph = spm_figure('Create','Graphics','Graphics','off');
		set([Fgraph],'Visible','on');
	end
end

if n == 2 || n == 3
	fg = spm_figure('FindWin','Interactive');
	if ~isempty(fg),
	else
		Finter = spm('CreateIntWin','off');        
		spm_figure('WaterMark',Finter,spm('Ver'),'',45);
		set([Finter],'Visible','on');
	end
end

return;

