
ICmaps10=spm_read_vols(spm_vol('melodic_IC_10.nii'));
ICmaps20=spm_read_vols(spm_vol('melodic_IC_20.nii'));
ICmaps30=spm_read_vols(spm_vol('melodic_IC_30.nii'));
ICmaps1000=spm_read_vols(spm_vol('melodic_IC_free.nii'));

vis=spm_read_vols(spm_vol('rwprim_Visual.nii'));
vis_comp(1,:)=[10,20,30,1000];



if size(size(ICmaps10),2)==4 && size(size(ICmaps20),2)==4 && size(size(ICmaps30),2)==4 && size(size(ICmaps1000),2)==4
    %==4
    disp('calcola il gof')
    
    gof10_l=zeros(10,3);
    gof10_m=zeros(10,3);
    for i=1:10
    
        comp10=ICmaps10(:,:,:,i);
    
        gof10_l(i,1)=mean(comp10(vis>0))-mean(comp10(comp10~=0 & vis==0));
        [ml10,jl10]=max(gof10_l(:,1));
        vis_comp(2,1)=ml10;
        vis_comp(3,1)=jl10;
    
%         gof10_m(i,1)=mean(comp10(motor>0))-mean(comp10(comp10~=0 & motor==0));
%         [mm10,jm10]=max(gof10_m(:,1));
%         motor_comp(2,1)=mm10;
%         motor_comp(3,1)=jm10;
    %     
    %     visual=spm_read_vols(spm_vol('prim_Visual.nii'));
    %     gof(i,3)=mean(comp(visual>0))-mean(comp(comp~=0 & visual==0));
    %     [m3,j3]=max(gof(:,3));
    %     visual_comp=j3;
%     
    end

    gof20_l=zeros(20,3);
    gof20_m=zeros(20,3);

    for i=1:20
    
        comp20=ICmaps20(:,:,:,i);
    
        gof20_l(i,1)=mean(comp20(vis>0))-mean(comp20(comp20~=0 & vis==0));
        [ml20,jl20]=max(gof20_l(:,1));
        vis_comp(2,2)=ml20;
        vis_comp(3,2)=jl20;
    
%         gof20_m(i,1)=mean(comp20(motor>0))-mean(comp20(comp20~=0 & motor==0));
%         [mm20,jm20]=max(gof20_m(:,1));
%         motor_comp(2,2)=mm20;
%         motor_comp(3,2)=jm20;

% %     visual=spm_read_vols(spm_vol('prim_Visual.nii'));
% %     gof(i,3)=mean(comp(visual>0))-mean(comp(comp~=0 & visual==0));
% %     [m3,j3]=max(gof(:,3));
% %     visual_comp=j3;
% %     
    end
% 
    gof30_l=zeros(20,3);
    gof30_m=zeros(30,3);

    for i=1:30
    
        comp30=ICmaps30(:,:,:,i);
    
        
    
        gof30_l(i,1)=mean(comp30(vis>0))-mean(comp30(comp30~=0 & vis==0));
        [ml30,jl30]=max(gof30_l(:,1));
        vis_comp(2,3)=ml30;
        vis_comp(3,3)=jl30;
    
%         gof30_m(i,1)=mean(comp30(motor>0))-mean(comp30(comp30~=0 & motor==0));
%         [mm30,jm30]=max(gof30_m(:,1));
%         motor_comp(2,3)=mm30;
%         motor_comp(3,3)=jm30;
    end
    
    gof_free_l=zeros(size(ICmaps1000,4),3);
    gof_free_m=zeros(size(ICmaps1000,4),3);
    
    for i=1:size(ICmaps1000,4)
    
        comp_free=ICmaps1000(:,:,:,i);
    

        gof_free_l(i,1)=mean(comp_free(vis>0))-mean(comp_free(comp_free~=0 & vis==0));
        [ml_free,jl_free]=max(gof_free_l(:,1));
        vis_comp(2,4)=ml_free;
        vis_comp(3,4)=jl_free;
    
%         gof_free_m(i,1)=mean(comp_free(motor>0))-mean(comp_free(comp_free~=0 & motor==0));
%         [mm_free,jm_free]=max(gof_free_m(:,1));
%         motor_comp(2,4)=mm_free;
%         motor_comp(3,4)=jm_free;
    
    

%     gof(i,2)=mean(comp(motor>0))-mean(comp(comp~=0 & motor==0));
%     [m2,j2]=max(gof(:,2));
%     motor_comp=j2;
%     
%     visual=spm_read_vols(spm_vol('prim_Visual.nii'));
%     gof(i,3)=mean(comp(visual>0))-mean(comp(comp~=0 & visual==0));
%     [m3,j3]=max(gof(:,3));
%     visual_comp=j3;
%     
    end

else
    disp('check free melodic')
    return
end


% [m3,j3]=max(motor_comp(2,:));
% 
% map_to_get=strcat('ICmaps',num2str(motor_comp(1,j3)));
% mot_out=eval(map_to_get);
% mot_out=mot_out(:,:,:,motor_comp(3,j3));

% temp=spm_vol('rwSensorimotor.nii');
% motor_out_map=temp;
% motor_out_map.fname='motor_auto.nii';
% motor_out_map.dt=[16 1];
% spm_write_vol(motor_out_map,mot_out);
% 
% motor_out_thr=mot_out;
% motor_out_thr(motor_out_thr<3.1311)=0;
% motor_out_map_thr=temp;
% motor_out_map_thr.dt=[16 1];
% motor_out_map_thr.fname='motor_auto_thr.nii';
% spm_write_vol(motor_out_map_thr,motor_out_thr);

[m4,j4]=max(vis_comp(2,:));

map_to_get=strcat('ICmaps',num2str(vis_comp(1,j4)));
vis_out=eval(map_to_get);
vis_out=vis_out(:,:,:,vis_comp(3,j4));

temp=spm_vol('rwprim_Visual.nii');
vis_out_map=temp;
vis_out_map.fname='vis_auto.nii';
vis_out_map.dt=[16 1];
spm_write_vol(vis_out_map,vis_out);

vis_out_thr=vis_out;
vis_out_thr(vis_out_thr<3.5)=0;
vis_out_map_thr=temp;
vis_out_map_thr.dt=[16 1];
vis_out_map_thr.fname='vis_auto_thr.nii';
spm_write_vol(vis_out_map_thr,vis_out_thr);