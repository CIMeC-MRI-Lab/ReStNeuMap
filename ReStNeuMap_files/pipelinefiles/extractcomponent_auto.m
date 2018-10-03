%This script automatically extracts the motor, language and primary visual network
%by determining the component with highest spatial overlap with
%corresponding network template (https://findlab.stanford.edu/functional_ROIs.html)

vis=spm_read_vols(spm_vol('rwprim_Visual.nii'));
vis_comp(1,:)=[10,20,30,1000];

lang=spm_read_vols(spm_vol('rwLanguage.nii'));
lang_comp=zeros(3,4);
lang_comp(1,:)=[10,20,30,1000];

motor=spm_read_vols(spm_vol('rwSensorimotor.nii'));
motor_comp=zeros(3,4);
motor_comp(1,:)=[10,20,30,1000];

%gunzip ('vmasksm4D_mask.ica\melodic_IC.nii.gz');
%gunzip ('vmasksm4D_mask.ica+\melodic_IC.nii.gz');
%gunzip ('vmasksm4D_mask.ica++\melodic_IC.nii.gz');
%gunzip ('vmasksm4D_mask.ica+++\melodic_IC.nii.gz');

%Lisa's fix 2018-06-09
gunzip ('vmasksm4D_mask.ica/melodic_IC.nii.gz');
gunzip ('vmasksm4D_mask.ica+/melodic_IC.nii.gz');
gunzip ('vmasksm4D_mask.ica++/melodic_IC.nii.gz');
gunzip ('vmasksm4D_mask.ica+++/melodic_IC.nii.gz');


%ICmaps10=spm_read_vols(spm_vol('vmasksm4D_mask.ica\melodic_IC.nii'));
%ICmaps20=spm_read_vols(spm_vol('vmasksm4D_mask.ica+\melodic_IC.nii'));
%ICmaps30=spm_read_vols(spm_vol('vmasksm4D_mask.ica++\melodic_IC.nii'));
%ICmaps1000=spm_read_vols(spm_vol('vmasksm4D_mask.ica+++\melodic_IC.nii'));

%Lisa's fix 2018-06-09
ICmaps10=spm_read_vols(spm_vol('vmasksm4D_mask.ica/melodic_IC.nii'));
ICmaps20=spm_read_vols(spm_vol('vmasksm4D_mask.ica+/melodic_IC.nii'));
ICmaps30=spm_read_vols(spm_vol('vmasksm4D_mask.ica++/melodic_IC.nii'));
ICmaps1000=spm_read_vols(spm_vol('vmasksm4D_mask.ica+++/melodic_IC.nii'));

%for each network it creates a table including the component with highest spatial overlap (gof) for each ICA settings 
%(10,20,30 and FSL determined number of components)the one with highest gof
%is selected
if size(size(ICmaps10),2)==4 && size(size(ICmaps20),2)==4 && size(size(ICmaps30),2)==4 && size(size(ICmaps1000),2)==4
    %==4
    disp('calcola il gof')
    
    gof10_vis=zeros(10,3);
    gof10_mot=zeros(10,3);
    gof10_lang=zeros(10,3);
    
    for i=1:10
    
        comp10=ICmaps10(:,:,:,i);
    
        gof10_vis(i,1)=mean(comp10(vis>0))-mean(comp10(comp10~=0 & vis==0));
        [mv10,jv10]=max(gof10_vis(:,1));
        vis_comp(2,1)=mv10;
        vis_comp(3,1)=jv10;
        
        gof10_mot(i,1)=mean(comp10(motor>0))-mean(comp10(comp10~=0 & motor==0));
        [mm10,jm10]=max(gof10_mot(:,1));
        motor_comp(2,1)=mm10;
        motor_comp(3,1)=jm10;
        
        gof10_vis(i,1)=mean(comp10(lang>0))-mean(comp10(comp10~=0 & lang==0));
        [ml10,jl10]=max(gof10_lang(:,1));
        lang_comp(2,1)=ml10;
        lang_comp(3,1)=jl10;
    
     
    end

    gof20_vis=zeros(20,3);
    gof20_mot=zeros(20,3);
    gof20_lang=zeros(20,3);
    
    for i=1:20
    
        comp20=ICmaps20(:,:,:,i);
    
        gof20_vis(i,1)=mean(comp20(vis>0))-mean(comp20(comp20~=0 & vis==0));
        [mv20,jv20]=max(gof20_vis(:,1));
        vis_comp(2,2)=mv20;
        vis_comp(3,2)=jv20;
    
        gof20_motor(i,1)=mean(comp20(motor>0))-mean(comp20(comp20~=0 & motor==0));
        [mm20,jm20]=max(gof20_mot(:,1));
        motor_comp(2,2)=mm20;
        motor_comp(3,2)=jm20;
        
        gof20_lang(i,1)=mean(comp20(lang>0))-mean(comp20(comp20~=0 & lang==0));
        [ml20,jl20]=max(gof20_lang(:,1));
        lang_comp(2,2)=ml20;
        lang_comp(3,2)=jl20;% %     
    end
% 
    gof30_vis=zeros(30,3);
    gof30_mot=zeros(30,3);
    gof30_lang=zeros(30,3);
    
    for i=1:30
    
        comp30=ICmaps30(:,:,:,i);
    
        
    
        gof30_vis(i,1)=mean(comp30(vis>0))-mean(comp30(comp30~=0 & vis==0));
        [mv30,jv30]=max(gof30_vis(:,1));
        vis_comp(2,3)=mv30;
        vis_comp(3,3)=jv30;
    
        gof30_motor(i,1)=mean(comp30(motor>0))-mean(comp30(comp30~=0 & motor==0));
        [mm30,jm30]=max(gof30_mot(:,1));
        motor_comp(2,3)=mm30;
        motor_comp(3,3)=jm30;
        
        gof30_lang(i,1)=mean(comp30(lang>0))-mean(comp30(comp30~=0 & lang==0));
        [ml30,jl30]=max(gof30_lang(:,1));
        lang_comp(2,3)=ml30;
        lang_comp(3,3)=jl30;% %     
    end
    
    gof_free_vis=zeros(size(ICmaps1000,4),3);
    gof_free_mot=zeros(size(ICmaps1000,4),3);
    gof_free_lang=zeros(size(ICmaps1000,4),3);
    
    for i=1:size(ICmaps1000,4)
    
        comp_free=ICmaps1000(:,:,:,i);
    

        gof_free_vis(i,1)=mean(comp_free(vis>0))-mean(comp_free(comp_free~=0 & vis==0));
        [mv_free,jv_free]=max(gof_free_vis(:,1));
        vis_comp(2,4)=mv_free;
        vis_comp(3,4)=jv_free;
    
        gof_free_motor(i,1)=mean(comp_free(motor>0))-mean(comp_free(comp_free~=0 & motor==0));
        [mm_free,jm_free]=max(gof_free_mot(:,1));
        motor_comp(2,4)=mm_free;
        motor_comp(3,4)=jm_free;
        
        gof_free_lang(i,1)=mean(comp_free(lang>0))-mean(comp_free(comp_free~=0 & lang==0));
        [ml_free,jl_free]=max(gof_free_lang(:,1));
        lang_comp(2,4)=ml_free;
        lang_comp(3,4)=jl_free;% %     
%     
    end

else
    disp('check free melodic')
    return
end



[m2,j2]=max(vis_comp(2,:));

map_to_get=strcat('ICmaps',num2str(vis_comp(1,j2)));
vis_out=eval(map_to_get);
vis_out=vis_out(:,:,:,vis_comp(3,j2));

temp=spm_vol('rwprim_Visual.nii');
vis_out_map=temp;
vis_out_map.fname='vis.nii';
vis_out_map.dt=[16 1];
spm_write_vol(vis_out_map,vis_out);

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

[m3,j3]=max(motor_comp(2,:));

map_to_get=strcat('ICmaps',num2str(motor_comp(1,j3)));
mot_out=eval(map_to_get);
mot_out=mot_out(:,:,:,motor_comp(3,j3));

temp=spm_vol('rwSensorimotor.nii');
motor_out_map=temp;
motor_out_map.fname='motor.nii';
motor_out_map.dt=[16 1];
spm_write_vol(motor_out_map,mot_out);

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

[m4,j4]=max(lang_comp(2,:));

map_to_get=strcat('ICmaps',num2str(lang_comp(1,j4)));
lang_out=eval(map_to_get);
lang_out=lang_out(:,:,:,lang_comp(3,j4));

temp=spm_vol('rwLanguage.nii');
lang_out_map=temp;
lang_out_map.fname='lang.nii';
lang_out_map.dt=[16 1];
spm_write_vol(lang_out_map,lang_out);

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