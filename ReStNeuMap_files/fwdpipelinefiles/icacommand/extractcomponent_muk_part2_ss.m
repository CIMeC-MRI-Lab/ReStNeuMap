

[m3,j3]=max(motor_comp(2,:));

map_to_get=strcat('ICmaps',num2str(motor_comp(1,j3)));
mot_out=eval(map_to_get);
mot_out=mot_out(:,:,:,motor_comp(3,j3));

temp=spm_vol('rwSensorimotor.nii');
motor_out_map=temp;
motor_out_map.fname='motor_auto.nii';
motor_out_map.dt=[16 1];
spm_write_vol(motor_out_map,mot_out);

motor_out_thr=mot_out;
motor_out_thr(motor_out_thr<3.1311)=0;
motor_out_map_thr=temp;
motor_out_map_thr.dt=[16 1];
motor_out_map_thr.fname='motor_auto_thr.nii';
spm_write_vol(motor_out_map_thr,motor_out_thr);

[m4,j4]=max(lang_comp(2,:));

map_to_get=strcat('ICmaps',num2str(lang_comp(1,j4)));
lang_out=eval(map_to_get);
lang_out=lang_out(:,:,:,lang_comp(3,j4));

temp=spm_vol('rwLanguage.nii');
lang_out_map=temp;
lang_out_map.fname='lang_auto.nii';
lang_out_map.dt=[16 1];
spm_write_vol(lang_out_map,lang_out);

lang_out_thr=lang_out;
lang_out_thr(lang_out_thr<4.5)=0;
lang_out_map_thr=temp;
lang_out_map_thr.dt=[16 1];
lang_out_map_thr.fname='lang_auto_thr.nii';
spm_write_vol(lang_out_map_thr,lang_out_thr);