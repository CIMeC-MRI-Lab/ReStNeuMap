%This script automatically extracts the motor, language and primary visual network
%by determining the component with highest spatial overlap with
%corresponding network template (https://findlab.stanford.edu/functional_ROIs.html)

function [] = extractcomponent_auto_0_1_4(exitstatus)

% HARD-CODED PATIENT FOR CONNECTBRAIN:
patient = 'case\_2';

vis=spm_read_vols(spm_vol('rwprim_Visual.nii'));
vis_comp(1,:)=[10,20,30,1000];

lang=spm_read_vols(spm_vol('rwLanguage.nii'));
lang_comp=zeros(3,4);
lang_comp(1,:)=[10,20,30,1000];

motor=spm_read_vols(spm_vol('rwSensorimotor.nii'));
motor_comp=zeros(3,4);
motor_comp(1,:)=[10,20,30,1000];


if exitstatus.comp10
    gunzip ('vmasksm4D_mask.ica/melodic_IC.nii.gz');
    ICmaps10=spm_read_vols(spm_vol('vmasksm4D_mask.ica/melodic_IC.nii'));
else
    ICmaps10 = 0;
    
end

if exitstatus.comp20
    gunzip ('vmasksm4D_mask.ica+/melodic_IC.nii.gz');
    ICmaps20=spm_read_vols(spm_vol('vmasksm4D_mask.ica+/melodic_IC.nii'));
else
    ICmaps20 = 0;
end

if exitstatus.comp30
    gunzip ('vmasksm4D_mask.ica++/melodic_IC.nii.gz');
    ICmaps30=spm_read_vols(spm_vol('vmasksm4D_mask.ica++/melodic_IC.nii'));
else
    ICmaps30 = 0;
end

if exitstatus.compinf
    gunzip ('vmasksm4D_mask.ica+++/melodic_IC.nii.gz');
    ICmaps1000=spm_read_vols(spm_vol('vmasksm4D_mask.ica+++/melodic_IC.nii'));
else
    ICmaps1000 = 0;
end


%%%%if all([exitstatus.comp10,exitstatus.comp20,exitstatus.comp30,exitstatus.compinf])
%for each network it creates a table including the component with highest spatial overlap (gof) for each ICA settings 
%(10,20,30 and FSL determined number of components)the one with highest gof
%is selected
%%%%if size(size(ICmaps10),2)==4 && size(size(ICmaps20),2)==4 && size(size(ICmaps30),2)==4 && size(size(ICmaps1000),2)==4
    %==4
    disp('calcola il gof')

    
if size(size(ICmaps10),2)==4
    
    gof10_vis=zeros(10,3);
    gof10_motor=zeros(10,3);
    gof10_lang=zeros(10,3);

    gof10_vis_names = [];
    gof10_motor_names = [];
    gof10_lang_names = [];
    for i=1:10

        comp10=ICmaps10(:,:,:,i);

        % VISUAL 10 COMPONENTS
        mean_vis10 = mean(comp10(vis>0 & comp10>2.5));
        if isnan(mean_vis10)
            mean_vis10 = 0;
        end
        mean_nonvis10 = mean(comp10(comp10>2.5 & vis==0));
        if isnan(mean_nonvis10)
            mean_nonvis10 = 0;
        end
        
        %gof10_vis(i,1)=mean(comp10(vis>0 & comp10>2.5))-mean(comp10(comp10>2.5 & vis==0));
        gof10_vis(i,1) = mean_vis10 - mean_nonvis10;
        %gof10_vis_names{i} = ['ICA10\_',num2str(i)];
        gof10_vis_names = [gof10_vis_names, i];
        %gof10_vis(i,2) = 1000+i;
        [mv10,jv10]=max(gof10_vis(:,1));
        vis_comp(2,1)=mv10;
        vis_comp(3,1)=jv10;
        

        % MOTOR 10 COMPONENTS
        mean_motor10 = mean(comp10(motor>0 & comp10>2.5));
        if isnan(mean_motor10)
            mean_motor10 = 0;
        end
        mean_nonmotor10 = mean(comp10(comp10>2.5 & motor==0));
        if isnan(mean_nonmotor10)
            mean_nonmotor10 = 0;
        end
        
        %gof10_motor(i,1)=mean(comp10(motor>0 & comp10>2.5))-mean(comp10(comp10>2.5 & motor==0));
        gof10_motor(i,1) = mean_motor10 - mean_nonmotor10;
        %gof10_motor_names{i} = ['ICA10\_',num2str(i)];
        gof10_motor_names = [gof10_motor_names, i];
        [mm10,jm10]=max(gof10_motor(:,1));
        motor_comp(2,1)=mm10;
        motor_comp(3,1)=jm10;

        % LANG 10 COMPONENTS
        mean_lang10 = mean(comp10(lang>0 & comp10>2.5));
        if isnan(mean_lang10)
            mean_lang10 = 0;
        end
        mean_nonlang10 = mean(comp10(comp10>2.5 & lang==0));
        if isnan(mean_nonlang10)
            mean_nonlang10 = 0;
        end
        
        %gof10_lang(i,1)=mean(comp10(lang>0 & comp10>2.5))-mean(comp10(comp10>2.5 & lang==0));
        gof10_lang(i,1) = mean_lang10 - mean_nonlang10;
        %gof10_lang_names{i} = ['ICA10\_',num2str(i)];
        gof10_lang_names = [gof10_lang_names, i];
        [ml10,jl10]=max(gof10_lang(:,1));
        lang_comp(2,1)=ml10;
        lang_comp(3,1)=jl10;

    end
    
else
    
    vis_comp(2,1) = NaN;
    vis_comp(3,1) = NaN;
    motor_comp(2,1) = NaN;
    motor_comp(3,1) = NaN;
    lang_comp(2,1) = NaN;
    lang_comp(3,1) = NaN;
    gof10_vis = [NaN NaN NaN];
    gof10_motor = [NaN NaN NaN];
    gof10_lang = [NaN NaN NaN];

    
end
    
if size(size(ICmaps20),2)==4
    
    gof20_vis=zeros(20,3);
    gof20_motor=zeros(20,3);
    gof20_lang=zeros(20,3);

    gof20_vis_names = [];
    gof20_motor_names = [];
    gof20_lang_names = [];
    for i=1:20

        comp20=ICmaps20(:,:,:,i);
        
        
       % VISUAL 20 COMPONENTS
        mean_vis20 = mean(comp20(vis>0 & comp20>2.5));
        if isnan(mean_vis20)
            mean_vis20 = 0;
        end
        mean_nonvis20 = mean(comp20(comp20>2.5 & vis==0));
        if isnan(mean_nonvis20)
            mean_nonvis20 = 0;
        end    

        %gof20_vis(i,1)=mean(comp20(vis>0 & comp20>2.5))-mean(comp20(comp20>2.5 & vis==0));
        gof20_vis(i,1) = mean_vis20 - mean_nonvis20;
        %gof20_vis_names{i} = ['ICA20\_',num2str(i)];
        gof20_vis_names = [gof20_vis_names, i];
        [mv20,jv20]=max(gof20_vis(:,1));
        vis_comp(2,2)=mv20;
        vis_comp(3,2)=jv20;

        
       % MOTOR 20 COMPONENTS
        mean_motor20 = mean(comp20(motor>0 & comp20>2.5));
        if isnan(mean_motor20)
            mean_motor20 = 0;
        end
        mean_nonmotor20 = mean(comp20(comp20>2.5 & motor==0));
        if isnan(mean_nonmotor20)
            mean_nonmotor20 = 0;
        end    
        
        %gof20_motor(i,1)=mean(comp20(motor>0 & comp20>2.5))-mean(comp20(comp20>2.5 & motor==0));
        gof20_motor(i,1) = mean_motor20 - mean_nonmotor20;
        %gof20_motor_names{i} = ['ICA20\_',num2str(i)];
        gof20_motor_names = [gof20_motor_names, i];
        [mm20,jm20]=max(gof20_motor(:,1));
        motor_comp(2,2)=mm20;
        motor_comp(3,2)=jm20;

        
       % LANG 20 COMPONENTS
        mean_lang20 = mean(comp20(lang>0 & comp20>2.5));
        if isnan(mean_lang20)
            mean_lang20 = 0;
        end
        mean_nonlang20 = mean(comp20(comp20>2.5 & lang==0));
        if isnan(mean_nonlang20)
            mean_nonlang20 = 0;
        end 
        
        %gof20_lang(i,1)=mean(comp20(lang>0 & comp20>2.5))-mean(comp20(comp20>2.5 & lang==0));
        gof20_lang(i,1) = mean_lang20 - mean_nonlang20;
        %gof20_lang_names{i} = ['ICA20\_',num2str(i)];
        gof20_lang_names = [gof20_lang_names, i];
        [ml20,jl20]=max(gof20_lang(:,1));
        lang_comp(2,2)=ml20;
        lang_comp(3,2)=jl20;% %     
    end
    
else
    
    vis_comp(2,2) = NaN;
    vis_comp(3,2) = NaN;
    motor_comp(2,2) = NaN;
    motor_comp(3,2) = NaN;
    lang_comp(2,2) = NaN;
    lang_comp(3,2) = NaN;
    gof20_vis = [NaN NaN NaN];
    gof20_motor = [NaN NaN NaN];
    gof20_lang = [NaN NaN NaN];
    
end

if size(size(ICmaps30),2)==4
% 
    gof30_vis=zeros(30,3);
    gof30_motor=zeros(30,3);
    gof30_lang=zeros(30,3);

    gof30_vis_names = [];
    gof30_motor_names = [];
    gof30_lang_names = [];
    for i=1:30

        comp30=ICmaps30(:,:,:,i);

        
       % VISUAL 30 COMPONENTS
        mean_vis30 = mean(comp30(vis>0 & comp30>2.5));
        if isnan(mean_vis30)
            mean_vis30 = 0;
        end
        mean_nonvis30 = mean(comp30(comp30>2.5 & vis==0));
        if isnan(mean_nonvis30)
            mean_nonvis30 = 0;
        end 

        %gof30_vis(i,1)=mean(comp30(vis>0 & comp30>2.5))-mean(comp30(comp30>2.5 & vis==0));
        gof30_vis(i,1) = mean_vis30 - mean_nonvis30;
        %gof30_vis_names{i} = ['ICA30\_',num2str(i)];
        gof30_vis_names = [gof30_vis_names, i];
        [mv30,jv30]=max(gof30_vis(:,1));
        vis_comp(2,3)=mv30;
        vis_comp(3,3)=jv30;

        
        % MOTOR 30 COMPONENTS
        mean_motor30 = mean(comp30(motor>0 & comp30>2.5));
        if isnan(mean_motor30)
            mean_motor30 = 0;
        end
        mean_nonmotor30 = mean(comp30(comp30>2.5 & motor==0));
        if isnan(mean_nonmotor30)
            mean_nonmotor30 = 0;
        end
        
        %gof30_motor(i,1)=mean(comp30(motor>0 & comp30>2.5))-mean(comp30(comp30>2.5 & motor==0));
        gof30_motor(i,1) = mean_motor30 - mean_nonmotor30;
        %gof30_motor_names{i} = ['ICA30\_',num2str(i)];
        gof30_motor_names = [gof30_motor_names, i];
        [mm30,jm30]=max(gof30_motor(:,1));
        motor_comp(2,3)=mm30;
        motor_comp(3,3)=jm30;

        
       % LANG 30 COMPONENTS
        mean_lang30 = mean(comp30(lang>0 & comp30>2.5));
        if isnan(mean_lang30)
            mean_lang30 = 0;
        end
        mean_nonlang30 = mean(comp30(comp30>2.5 & lang==0));
        if isnan(mean_nonlang30)
            mean_nonlang30 = 0;
        end 
        
        %gof30_lang(i,1)=mean(comp30(lang>0 & comp30>2.5))-mean(comp30(comp30>2.5 & lang==0));
        gof30_lang(i,1) = mean_lang30 - mean_nonlang30;
        %gof30_lang_names{i} = ['ICA30\_',num2str(i)];
        gof30_lang_names = [gof30_lang_names, i];
        [ml30,jl30]=max(gof30_lang(:,1));
        lang_comp(2,3)=ml30;
        lang_comp(3,3)=jl30;% %     
    end
    
else
    
    vis_comp(2,3) = NaN;
    vis_comp(3,3) = NaN;
    motor_comp(2,3) = NaN;
    motor_comp(3,3) = NaN;
    lang_comp(2,3) = NaN;
    lang_comp(3,3) = NaN;
    gof30_vis = [NaN NaN NaN];
    gof30_motor = [NaN NaN NaN];
    gof30_lang = [NaN NaN NaN];
    
end

if size(size(ICmaps1000),2)==4

    gof_free_vis=zeros(size(ICmaps1000,4),3);
    gof_free_motor=zeros(size(ICmaps1000,4),3);
    gof_free_lang=zeros(size(ICmaps1000,4),3);

    gof_free_vis_names = [];
    gof_free_motor_names = [];
    gof_free_lang_names = [];
    for i=1:size(ICmaps1000,4)

        comp_free=ICmaps1000(:,:,:,i);

        
       % VISUAL FREE COMPONENTS
        mean_vis_free = mean(comp_free(vis>0 & comp_free>2.5));
        if isnan(mean_vis_free)
            mean_vis_free = 0;
        end
        mean_nonvis_free = mean(comp_free(comp_free>2.5 & vis==0));
        if isnan(mean_nonvis_free)
            mean_nonvis_free = 0;
        end 
        
        
        %gof_free_vis(i,1)=mean(comp_free(vis>0 & comp_free>2.5))-mean(comp_free(comp_free>2.5 & vis==0));
        gof_free_vis(i,1) = mean_vis_free - mean_nonvis_free;
        %gof_free_vis_names{i} = ['ICAfree\_',num2str(i)];
        gof_free_vis_names = [gof_free_vis_names, i];
        [mv_free,jv_free]=max(gof_free_vis(:,1));
        vis_comp(2,4)=mv_free;
        vis_comp(3,4)=jv_free;

        
        % MOTOR FREE COMPONENTS
        mean_motor_free = mean(comp_free(motor>0 & comp_free>2.5));
        if isnan(mean_motor_free)
            mean_motor_free = 0;
        end
        mean_nonmotor_free = mean(comp_free(comp_free>2.5 & motor==0));
        if isnan(mean_nonmotor_free)
            mean_nonmotor_free = 0;
        end        
        
        %gof_free_motor(i,1)=mean(comp_free(motor>0 & comp_free>2.5))-mean(comp_free(comp_free>2.5 & motor==0));
        gof_free_motor(i,1) = mean_motor_free - mean_nonmotor_free;
        %gof_free_motor_names{i} = ['ICAfree\_',num2str(i)];
        gof_free_motor_names = [gof_free_motor_names, i];
        [mm_free,jm_free]=max(gof_free_motor(:,1));
        motor_comp(2,4)=mm_free;
        motor_comp(3,4)=jm_free;

       % LANG FREE COMPONENTS
        mean_lang_free = mean(comp_free(lang>0 & comp_free>2.5));
        if isnan(mean_lang_free)
            mean_lang_free = 0;
        end
        mean_nonlang_free = mean(comp_free(comp_free>2.5 & lang==0));
        if isnan(mean_nonlang_free)
            mean_nonlang_free = 0;
        end         
        
        %gof_free_lang(i,1)=mean(comp_free(lang>0 & comp_free>2.5))-mean(comp_free(comp_free>2.5 & lang==0));
        gof_free_lang(i,1) = mean_lang_free - mean_nonlang_free;
        %gof_free_lang_names{i} = ['ICAfree\_',num2str(i)];
        gof_free_lang_names = [gof_free_lang_names, i];
        [ml_free,jl_free]=max(gof_free_lang(:,1));
        lang_comp(2,4)=ml_free;
        lang_comp(3,4)=jl_free;% %     
%     
    end

else
    
    vis_comp(2,4) = NaN;
    vis_comp(3,4) = NaN;
    motor_comp(2,4) = NaN;
    motor_comp(3,4) = NaN;
    lang_comp(2,4) = NaN;
    lang_comp(3,4) = NaN;
    gof_free_vis = [NaN NaN NaN];
    gof_free_motor = [NaN NaN NaN];
    gof_free_lang = [NaN NaN NaN];
    
%     disp('check free melodic')
%     return
end

% create a plot per each network with GOF values per each component
% do so for VISUAL network ------------------------------------------------
figure
% detect in which run the best GOF was detected.
[max_vis,pos_max_vis]=max(vis_comp(2,:));
%do so for ICA10
if(exitstatus.comp10)
    subplot1vis = subplot(4,1,1)
    plot1vis = plot(gof10_vis_names, gof10_vis(:,1),'Parent',subplot1vis)
    xlim(subplot1vis,[min(gof10_vis_names) max(gof10_vis_names)]);
    xlabel(subplot1vis,'Component number')
    ylabel(subplot1vis,'GOF')
    ax1v = plot1vis.Parent;   % Important
    set(ax1v, 'XTick', 1:1:max(gof10_vis_names))
    title('VISUAL NETWORK: GOF values for ICA 10 components')
    hold on
    [max_vis10, posmax_vis10] = maxk(gof10_vis(:,1),3);
    scatter(posmax_vis10,max_vis10,'*','m')
    text(posmax_vis10,max_vis10,num2str(max_vis10),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_vis == 1
        pos_max_vis_whichcomp = find(gof10_vis(:,1)==max_vis);
        scatter(pos_max_vis_whichcomp,max_vis,'g','filled')
    end
    box off
end
%do so for ICA20
if(exitstatus.comp20)
    subplot2vis = subplot(4,1,2)
    plot2vis = plot(gof20_vis_names, gof20_vis(:,1),'Parent',subplot2vis)
    xlabel(subplot2vis,'Component number')
    ylabel(subplot2vis,'GOF')    
    xlim(subplot2vis,[min(gof20_vis_names) max(gof20_vis_names)]);
    ax2v = plot2vis.Parent;   % Important
    set(ax2v, 'XTick', 1:1:max(gof20_vis_names))
    title('VISUAL NETWORK: GOF values for ICA 20 components')
    hold on
    [max_vis20, posmax_vis20] = maxk(gof20_vis(:,1),3);
    scatter(posmax_vis20,max_vis20,'*','m')
    text(posmax_vis20,max_vis20,num2str(max_vis20),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_vis == 2
       pos_max_vis_whichcomp = find(gof20_vis(:,1)==max_vis);
       scatter(pos_max_vis_whichcomp,max_vis,'g','filled')
    end
    box off
end
%do so for ICA30
if(exitstatus.comp30)
    subplot3vis = subplot(4,1,3)    
    plot3vis = plot(gof30_vis_names, gof30_vis(:,1),'Parent',subplot3vis)
    xlabel(subplot3vis,'Component number')
    ylabel(subplot3vis,'GOF')
    xlim(subplot3vis,[min(gof30_vis_names) max(gof30_vis_names)]);
    ax3v = plot3vis.Parent;   % Important
    set(ax3v, 'XTick', 1:1:max(gof30_vis_names))
    title('VISUAL NETWORK: GOF values for ICA 30 components')
    hold on
    [max_vis30, posmax_vis30] = maxk(gof30_vis(:,1),3);
    scatter(posmax_vis30,max_vis30,'*','m')
    text(posmax_vis30,max_vis30,num2str(max_vis30),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_vis == 3
       pos_max_vis_whichcomp = find(gof30_vis(:,1)==max_vis);
       scatter(pos_max_vis_whichcomp,max_vis,'g','filled')
    end    
    box off
end
%do so for ICAfree
if(exitstatus.compinf)
    subplot4vis = subplot(4,1,4)
    plot4vis = plot(gof_free_vis_names, gof_free_vis(:,1),'Parent',subplot4vis)
    xlabel(subplot4vis,'Component number')
    ylabel(subplot4vis,'GOF')
    xlim(subplot4vis,[min(gof_free_vis_names) max(gof_free_vis_names)]);
    ax4v = plot4vis.Parent;   % Important
    set(ax4v, 'XTick', 1:1:max(gof_free_vis_names))
    title('VISUAL NETWORK: GOF values for ICA data-driven number components')
    hold on
    [max_vis_free, posmax_vis_free] = maxk(gof_free_vis(:,1),3);
    scatter(posmax_vis_free,max_vis_free,'*','m')
    text(posmax_vis_free,max_vis_free,num2str(max_vis_free),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_vis == 4
       pos_max_vis_whichcomp = find(gof_free_vis(:,1)==max_vis);
       scatter(pos_max_vis_whichcomp,max_vis,'g','filled')
    end       
    box off
end
width=1420;
height=800;
pmtit = mtit(['GOF summary for visual network for ',patient], 'xoff',0,'yoff',0.05);
set(gcf,'position',[180,254,width,height])
saveas(gcf,'GOF_visual.png')



% do so for MOTOR network ------------------------------------------------
figure
% detect in which run the best GOF was detected.
[max_motor,pos_max_motor]=max(motor_comp(2,:));
%do so for ICA10
if(exitstatus.comp10)
    subplot1motor = subplot(4,1,1)   
    plot1motor = plot(gof10_motor_names, gof10_motor(:,1),'Parent',subplot1motor)
    xlabel(subplot1motor,'Component number')
    ylabel(subplot1motor,'GOF') 
    xlim(subplot1motor,[min(gof10_motor_names) max(gof10_motor_names)]);
    ax1m = plot1motor.Parent;   % Important
    set(ax1m, 'XTick', 1:1:max(gof10_motor_names))
    title('MOTOR NETWORK: GOF values for ICA 10 components')
    hold on
    [max_motor10, posmax_motor10] = maxk(gof10_motor(:,1),3);
    scatter(posmax_motor10,max_motor10,'*','m')
    text(posmax_motor10,max_motor10,num2str(max_motor10),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_motor == 1
        pos_max_motor_whichcomp = find(gof10_motor(:,1)==max_motor);
        scatter(pos_max_motor_whichcomp,max_motor,'g','filled')
    end
    box off
end
%do so for ICA20
if(exitstatus.comp20)
    subplot2motor = subplot(4,1,2)    
    plot2motor = plot(gof20_motor_names, gof20_motor(:,1),'Parent',subplot2motor)
    xlabel(subplot2motor,'Component number')
    ylabel(subplot2motor,'GOF')
    xlim(subplot2motor,[min(gof20_motor_names) max(gof20_motor_names)]);
    ax2m = plot2motor.Parent;   % Important
    set(ax2m, 'XTick', 1:1:max(gof20_motor_names))
    title('MOTOR NETWORK: GOF values for ICA 20 components')
    hold on
    [max_motor20, posmax_motor20] = maxk(gof20_motor(:,1),3);
    scatter(posmax_motor20,max_motor20,'*','m')
    text(posmax_motor20,max_motor20,num2str(max_motor20),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_motor == 2
       pos_max_motor_whichcomp = find(gof20_motor(:,1)==max_motor);
       scatter(pos_max_motor_whichcomp,max_motor,'g','filled')
    end
    box off
end
%do so for ICA30
if(exitstatus.comp30)
    subplot3motor = subplot(4,1,3)    
    plot3motor = plot(gof30_motor_names, gof30_motor(:,1),'Parent',subplot3motor)
    xlabel(subplot3motor,'Component number')
    ylabel(subplot3motor,'GOF')
    xlim(subplot3motor,[min(gof30_motor_names) max(gof30_motor_names)]);
    ax3m = plot3motor.Parent;   % Important
    set(ax3m, 'XTick', 1:1:max(gof30_motor_names))
    title('MOTOR NETWORK: GOF values for ICA 30 components')
    hold on
    [max_motor30, posmax_motor30] = maxk(gof30_motor(:,1),3);
    scatter(posmax_motor30,max_motor30,'*','m')
    text(posmax_motor30,max_motor30,num2str(max_motor30),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_motor == 3
       pos_max_motor_whichcomp = find(gof30_motor(:,1)==max_motor);
       scatter(pos_max_motor_whichcomp,max_motor,'g','filled')
    end    
    box off
end
%do so for ICAfree
if(exitstatus.compinf)
    subplot4motor = subplot(4,1,4)    
    plot4motor = plot(gof_free_motor_names, gof_free_motor(:,1),'Parent',subplot4motor)
    xlabel(subplot4motor,'Component number')
    ylabel(subplot4motor,'GOF')
    xlim(subplot4motor,[min(gof_free_motor_names) max(gof_free_motor_names)]);
    ax4m = plot4motor.Parent;   % Important
    set(ax4m, 'XTick', 1:1:max(gof_free_motor_names))
    title('MOTOR NETWORK: GOF values for ICA data-driven number components')
    hold on
    [max_motor_free, posmax_motor_free] = maxk(gof_free_motor(:,1),3);
    scatter(posmax_motor_free,max_motor_free,'*','m')
    text(posmax_motor_free,max_motor_free,num2str(max_motor_free),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_motor == 4
       pos_max_motor_whichcomp = find(gof_free_motor(:,1)==max_motor);
       scatter(pos_max_motor_whichcomp,max_motor,'g','filled')
    end       
    box off
end
width=1420;
height=800;
pmtit = mtit(['GOF summary for motor network for ',patient], 'xoff',0,'yoff',0.05);
set(gcf,'position',[180,254,width,height])
saveas(gcf,'GOF_motor.png')


% do so for LANGUAGE network ------------------------------------------------
figure
% detect in which run the best GOF was detected.
[max_lang,pos_max_lang]=max(lang_comp(2,:));
%do so for ICA10
if(exitstatus.comp10)
    subplot1lang = subplot(4,1,1)    
    plot1lang = plot(gof10_lang_names, gof10_lang(:,1),'Parent',subplot1lang)
    xlabel(subplot1lang,'Component number')
    ylabel(subplot1lang,'GOF')
    xlim(subplot1lang,[min(gof10_lang_names) max(gof10_lang_names)]);
    ax1l = plot1lang.Parent;   % Important
    set(ax1l, 'XTick', 1:1:max(gof10_lang_names))
    title('LANGUAGE NETWORK: GOF values for ICA 10 components')
    hold on
    [max_lang10, posmax_lang10] = maxk(gof10_lang(:,1),3);
    scatter(posmax_lang10,max_lang10,'*','m')
    text(posmax_lang10,max_lang10,num2str(max_lang10),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_lang == 1
        pos_max_lang_whichcomp = find(gof10_lang(:,1)==max_lang);
        scatter(pos_max_lang_whichcomp,max_lang,'g','filled')
    end
    box off
end
%do so for ICA20
if(exitstatus.comp20)
    subplot2lang = subplot(4,1,2)    
    plot2lang = plot(gof20_lang_names, gof20_lang(:,1),'Parent',subplot2lang)
    xlabel(subplot2lang,'Component number')
    ylabel(subplot2lang,'GOF')
    xlim(subplot2lang,[min(gof20_lang_names) max(gof20_lang_names)]);
    ax2l = plot2lang.Parent;   % Important
    set(ax2l, 'XTick', 1:1:max(gof20_lang_names))
    title('LANGUAGE NETWORK: GOF values for ICA 20 components')
    hold on
    [max_lang20, posmax_lang20] = maxk(gof20_lang(:,1),3);
    scatter(posmax_lang20,max_lang20,'*','m')
    text(posmax_lang20,max_lang20,num2str(max_lang20),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_lang == 2
       pos_max_lang_whichcomp = find(gof20_lang(:,1)==max_lang);
       scatter(pos_max_lang_whichcomp,max_lang,'g','filled')
    end
    box off
end
%do so for ICA30
if(exitstatus.comp30)
    subplot3lang = subplot(4,1,3)    
    plot3lang = plot(gof30_lang_names, gof30_lang(:,1),'Parent',subplot3lang)
    xlabel(subplot3lang,'Component number')
    ylabel(subplot3lang,'GOF')
    xlim(subplot3lang,[min(gof30_lang_names) max(gof30_lang_names)]);
    ax3l = plot3lang.Parent;   % Important
    set(ax3l, 'XTick', 1:1:max(gof30_lang_names))
    title('LANGUAGE NETWORK: GOF values for ICA 30 components')
    hold on
    [max_lang30, posmax_lang30] = maxk(gof30_lang(:,1),3);
    scatter(posmax_lang30,max_lang30,'*','m')
    text(posmax_lang30,max_lang30,num2str(max_lang30),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_lang == 3
       pos_max_lang_whichcomp = find(gof30_lang(:,1)==max_lang);
       scatter(pos_max_lang_whichcomp,max_lang,'g','filled')
    end    
    box off
end
%do so for ICAfree
if(exitstatus.compinf)
    subplot4lang = subplot(4,1,4) 
    plot4lang = plot(gof_free_lang_names, gof_free_lang(:,1),'Parent',subplot4lang)
    xlabel(subplot4lang,'Component number')
    ylabel(subplot4lang,'GOF')   
    xlim(subplot4lang,[min(gof_free_lang_names) max(gof_free_lang_names)]);
    ax4l = plot4lang.Parent;   % Important
    set(ax4l, 'XTick', 1:1:max(gof_free_lang_names))
    title('LANGUAGE NETWORK: GOF values for ICA data-driven number components')
    hold on
    [max_lang_free, posmax_lang_free] = maxk(gof_free_lang(:,1),3);
    scatter(posmax_lang_free,max_lang_free,'*','m')
    text(posmax_lang_free,max_lang_free,num2str(max_lang_free),'VerticalAlignment','bottom','HorizontalAlignment','center')
    if pos_max_lang == 4
       pos_max_lang_whichcomp = find(gof_free_lang(:,1)==max_lang);
       scatter(pos_max_lang_whichcomp,max_lang,'g','filled')
    end       
    box off
end
width=1420;
height=800;
pmtit = mtit(['GOF summary for language network for ',patient], 'xoff',0,'yoff',0.05);
set(gcf,'position',[180,254,width,height])
saveas(gcf,'GOF_language.png')





all_gofs_vis = vertcat(gof10_vis(:,1), gof20_vis(:,1), gof30_vis(:,1), gof_free_vis(:,1));
all_gofs_lang = vertcat(gof10_lang(:,1), gof20_lang(:,1), gof30_lang(:,1), gof_free_lang(:,1));
all_gofs_motor = vertcat(gof10_motor(:,1), gof20_motor(:,1), gof30_motor(:,1), gof_free_motor(:,1));
fid_vis = fopen('gof_vis.txt', 'w');
fid_lang = fopen('gof_lang.txt', 'w');    
fid_mot = fopen('gof_mot.txt', 'w');
formatspec = '%2.4f\n';
fprintf(fid_vis,formatspec,all_gofs_vis);
fclose(fid_vis);
fprintf(fid_lang,formatspec,all_gofs_lang);
fclose(fid_lang);
fprintf(fid_mot,formatspec,all_gofs_motor);
fclose(fid_mot);




% LN 2019-04-07: Make T1w_res folder
statusMkdir0 = system('mkdir T1w_res');
     if statusMkdir0
         close all
         msgstatusMkdir0 = 'an error occurred while creating the T1w_res folder.';
         error(msgstatusMkdir0)
     end

% VISUAL network
[m2,j2]=max(vis_comp(2,:));

map_to_get=strcat('ICmaps',num2str(vis_comp(1,j2)));
vis_out=eval(map_to_get);
vis_out=vis_out(:,:,:,vis_comp(3,j2));

temp=spm_vol('rwprim_Visual.nii');
vis_out_map=temp;
vis_out_map.fname='vis.nii';
vis_out_map.dt=[16 1];
spm_write_vol(vis_out_map,vis_out);

% -- bring vis_out image 2 T1w resolution
filesT1=dir('s*T1.nii');
myd.files=filesT1.name;
T1img=spm_vol(myd.files);
% d.filenetv=out_ICA.fname;
myd.filenetv='vis.nii';
matlabbatch = batch_job4d_reslicer(myd);
try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI'); 
        spm_jobman('serial', matlabbatch);
catch
        disp ('error in batch_job4d_reslicer visual')
end

% --- threshold images in native resolution
vis_out_thr=vis_out;
vis_out_thr(vis_out_thr<2.5)=0;
vis_out_map_thr=temp;
vis_out_map_thr.dt=[16 1];
vis_out_map_thr.fname='vis_25.nii';
spm_write_vol(vis_out_map_thr,vis_out_thr);

vis_out_thr=vis_out;
vis_out_thr(vis_out_thr<3.0)=0;
vis_out_map_thr=temp;
vis_out_map_thr.dt=[16 1];
vis_out_map_thr.fname='vis_30.nii';
spm_write_vol(vis_out_map_thr,vis_out_thr);

vis_out_thr=vis_out;
vis_out_thr(vis_out_thr<3.5)=0;
vis_out_map_thr=temp;
vis_out_map_thr.dt=[16 1];
vis_out_map_thr.fname='vis_35.nii';
spm_write_vol(vis_out_map_thr,vis_out_thr);

% --- threshold images in T1w resolution
visT1w = spm_vol('./T1w_res/T1w_vis.nii');
visT1w_vol = spm_read_vols(visT1w);
visT1w_vol_thr = visT1w_vol;
visT1w_vol_thr(visT1w_vol_thr<2.5) = 0;
visT1w_vol_map_thr = visT1w;
visT1w_vol_map_thr.dt = [16 1];
visT1w_vol_map_thr.fname = './T1w_res/T1w_vis_25.nii';
spm_write_vol(visT1w_vol_map_thr,visT1w_vol_thr);

visT1w_vol_thr = visT1w_vol;
visT1w_vol_thr(visT1w_vol_thr<3.0) = 0;
visT1w_vol_map_thr = visT1w;
visT1w_vol_map_thr.dt = [16 1];
visT1w_vol_map_thr.fname = './T1w_res/T1w_vis_30.nii';
spm_write_vol(visT1w_vol_map_thr,visT1w_vol_thr);

visT1w_vol_thr = visT1w_vol;
visT1w_vol_thr(visT1w_vol_thr<3.5) = 0;
visT1w_vol_map_thr = visT1w;
visT1w_vol_map_thr.dt = [16 1];
visT1w_vol_map_thr.fname = './T1w_res/T1w_vis_35.nii';
spm_write_vol(visT1w_vol_map_thr,visT1w_vol_thr);





% MOTOR network

[m3,j3]=max(motor_comp(2,:));

map_to_get=strcat('ICmaps',num2str(motor_comp(1,j3)));
mot_out=eval(map_to_get);
mot_out=mot_out(:,:,:,motor_comp(3,j3));

temp=spm_vol('rwSensorimotor.nii');
motor_out_map=temp;
motor_out_map.fname='motor.nii';
motor_out_map.dt=[16 1];
spm_write_vol(motor_out_map,mot_out);

% -- bring mot_out image 2 T1w resolution

myd.filenetv='motor.nii';
matlabbatch = batch_job4d_reslicer(myd);
try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI'); 
        spm_jobman('serial', matlabbatch);
catch
        disp ('error in batch_job4d motor')
end

% --- threshold images in native resolution
motor_out_thr=mot_out;
motor_out_thr(motor_out_thr<2.5)=0;
motor_out_map_thr=temp;
motor_out_map_thr.dt=[16 1];
motor_out_map_thr.fname='motor_25.nii';
spm_write_vol(motor_out_map_thr,motor_out_thr);

motor_out_thr=mot_out;
motor_out_thr(motor_out_thr<3.0)=0;
motor_out_map_thr=temp;
motor_out_map_thr.dt=[16 1];
motor_out_map_thr.fname='motor_30.nii';
spm_write_vol(motor_out_map_thr,motor_out_thr);

motor_out_thr=mot_out;
motor_out_thr(motor_out_thr<3.5)=0;
motor_out_map_thr=temp;
motor_out_map_thr.dt=[16 1];
motor_out_map_thr.fname='motor_35.nii';
spm_write_vol(motor_out_map_thr,motor_out_thr);


% --- threshold images in T1w resolution
motorT1w = spm_vol('./T1w_res/T1w_motor.nii');
motorT1w_vol = spm_read_vols(motorT1w);
motorT1w_vol_thr = motorT1w_vol;
motorT1w_vol_thr(motorT1w_vol_thr<2.5) = 0;
motorT1w_vol_map_thr = motorT1w;
motorT1w_vol_map_thr.dt = [16 1];
motorT1w_vol_map_thr.fname = './T1w_res/T1w_motor_25.nii';
spm_write_vol(motorT1w_vol_map_thr,motorT1w_vol_thr);

motorT1w_vol_thr = motorT1w_vol;
motorT1w_vol_thr(motorT1w_vol_thr<3.0) = 0;
motorT1w_vol_map_thr = motorT1w;
motorT1w_vol_map_thr.dt = [16 1];
motorT1w_vol_map_thr.fname = './T1w_res/T1w_motor_30.nii';
spm_write_vol(motorT1w_vol_map_thr,motorT1w_vol_thr);

motorT1w_vol_thr = motorT1w_vol;
motorT1w_vol_thr(motorT1w_vol_thr<3.5) = 0;
motorT1w_vol_map_thr = motorT1w;
motorT1w_vol_map_thr.dt = [16 1];
motorT1w_vol_map_thr.fname = './T1w_res/T1w_motor_35.nii';
spm_write_vol(motorT1w_vol_map_thr,motorT1w_vol_thr);


% LINGUISTIC network

[m4,j4]=max(lang_comp(2,:));

map_to_get=strcat('ICmaps',num2str(lang_comp(1,j4)));
lang_out=eval(map_to_get);
lang_out=lang_out(:,:,:,lang_comp(3,j4));

temp=spm_vol('rwLanguage.nii');
lang_out_map=temp;
lang_out_map.fname='lang.nii';
lang_out_map.dt=[16 1];
spm_write_vol(lang_out_map,lang_out);

% -- bring lang_out image 2 T1w resolution

myd.filenetv='lang.nii';
matlabbatch = batch_job4d_reslicer(myd);
try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI'); 
        spm_jobman('serial', matlabbatch);
catch
        disp ('error in batch_job4d lang')
end

% --- threshold images in native resolution

lang_out_thr=lang_out;
lang_out_thr(lang_out_thr<2.5)=0;
lang_out_map_thr=temp;
lang_out_map_thr.dt=[16 1];
lang_out_map_thr.fname='lang_25.nii';
spm_write_vol(lang_out_map_thr,lang_out_thr);

lang_out_thr=lang_out;
lang_out_thr(lang_out_thr<3.0)=0;
lang_out_map_thr=temp;
lang_out_map_thr.dt=[16 1];
lang_out_map_thr.fname='lang_30.nii';
spm_write_vol(lang_out_map_thr,lang_out_thr);

lang_out_thr=lang_out;
lang_out_thr(lang_out_thr<3.5)=0;
lang_out_map_thr=temp;
lang_out_map_thr.dt=[16 1];
lang_out_map_thr.fname='lang_35.nii';
spm_write_vol(lang_out_map_thr,lang_out_thr);

% --- threshold images in T1w resolution
langT1w = spm_vol('./T1w_res/T1w_lang.nii');
langT1w_vol = spm_read_vols(langT1w);
langT1w_vol_thr = langT1w_vol;
langT1w_vol_thr(langT1w_vol_thr<2.5) = 0;
langT1w_vol_map_thr = langT1w;
langT1w_vol_map_thr.dt = [16 1];
langT1w_vol_map_thr.fname = './T1w_res/T1w_lang_25.nii';
spm_write_vol(langT1w_vol_map_thr,langT1w_vol_thr);

langT1w_vol_thr = langT1w_vol;
langT1w_vol_thr(langT1w_vol_thr<3.0) = 0;
langT1w_vol_map_thr = langT1w;
langT1w_vol_map_thr.dt = [16 1];
langT1w_vol_map_thr.fname = './T1w_res/T1w_lang_30.nii';
spm_write_vol(langT1w_vol_map_thr,langT1w_vol_thr);

langT1w_vol_thr = langT1w_vol;
langT1w_vol_thr(langT1w_vol_thr<3.5) = 0;
langT1w_vol_map_thr = langT1w;
langT1w_vol_map_thr.dt = [16 1];
langT1w_vol_map_thr.fname = './T1w_res/T1w_lang_35.nii';
spm_write_vol(langT1w_vol_map_thr,langT1w_vol_thr);



end

