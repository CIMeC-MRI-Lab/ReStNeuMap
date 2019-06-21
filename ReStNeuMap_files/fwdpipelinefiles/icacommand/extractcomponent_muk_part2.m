

% [m3,j3]=max(motor_comp(2,:));
% 
% map_to_get=strcat('ICmaps',num2str(motor_comp(1,j3)));
% mot_out=eval(map_to_get);
% mot_out=mot_out(:,:,:,motor_comp(3,j3));
% 
% temp=spm_vol('Sensorimotor.nii');
% motor_out_map=temp;
% motor_out_map.fname='motor_MNI_auto.nii';
% motor_out_map.dt=[16 1];
% spm_write_vol(motor_out_map,mot_out);
% 
% motor_out_thr=mot_out;
% motor_out_thr(motor_out_thr<3.0000)=0;
% motor_out_map_thr=temp;
% motor_out_map_thr.dt=[16 1];
% motor_out_map_thr.fname='motor_MNI_auto_thr.nii';
% spm_write_vol(motor_out_map_thr,motor_out_thr);

[m4,j4]=max(vis_comp(2,:));

map_to_get=strcat('ICmaps');%num2str(vis_comp(1,j4)));
vis_out=eval(map_to_get);
vis_out=vis_out(:,:,:,vis_comp(3,j4));

temp=spm_vol('prim_Visual.nii');
vis_out_map=temp;
vis_out_map.fname='vis_MNI_auto.nii';
vis_out_map.dt=[16 1];
spm_write_vol(vis_out_map,vis_out);

vis_out_thr=vis_out;
vis_out_thr(vis_out_thr<3.5074)=0;
vis_out_map_thr=temp;
vis_out_map_thr.dt=[16 1];
vis_out_map_thr.fname='vis_MNI_auto_thr.nii';
spm_write_vol(vis_out_map_thr,vis_out_thr);