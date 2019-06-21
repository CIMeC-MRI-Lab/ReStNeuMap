
clear all
field='act';
value={'Cont_Nicolo_C_Visual_1_MNI.nii';'Cont_Nicolo_C_Visual_2_MNI.nii';'Cont_Nicolo_C_Visual_3_MNI.nii';'Cont_Nicolo_C_Visual_4_MNI.nii';'Cont_Nicolo_C_Visual_5_MNI.nii'};
s=struct(field,value);
mindis=zeros(size(s),1);
%motormap=spm_read_vols(spm_vol('Sanfilippo_Brigitte_C_Negative_Motor_1_MNI.nii'));
for p=1:size(s,1)
motormap=spm_read_vols(spm_vol(s(p,1).act));
y=0;x=0;

z=0;
for i=1:size(motormap,3)
    edges=motormap(:,:,i);
    if size(find(edges>0),1)>0
        [rowop,colop]=find(edges>0);
        thickop=zeros(size(find(edges>0)),1);%thick=zeros(size(find(pizza>0.5)),1);
        k=size(x,1);
        for j=1:size(find(edges>0),1)
            x(j+k,1)=rowop(j,1);
            y(j+k,1)=colop(j,1);
            z(j+k,1)=i;
        end
    end
end    
x(1,:)=[];
y(1,:)=[];
z(1,:)=[];
xc=sum(x,1)/size(x,1);
yc=sum(y,1)/size(y,1);
zc=sum(z,1)/size(z,1);

actmap=spm_read_vols(spm_vol('vis_MNI_auto_thr.nii'));
x=0;%k=size(a,1)
y=0;
z=0;
for i=1:size(actmap,3)
    edges=actmap(:,:,i);
    if size(find(edges>0),1)>0
        [rowop,colop]=find(edges>0);
        thickop=zeros(size(find(edges>0)),1);%thick=zeros(size(find(pizza>0.5)),1);
        k=size(x,1);
        for j=1:size(find(edges>0),1)
            x(j+k,1)=rowop(j,1);
            y(j+k,1)=colop(j,1);
            z(j+k,1)=i;
        end
    end
end    


vect_dis=zeros(size(x,1),1);
for i=1:size(x,1)
            distvox_x=abs(x(i,1)-xc);
            distvox_y=abs(y(i,1)-yc);
            distvox_z=abs(z(i,1)-zc);
            %vect_dis(i,1)=sqrt((x(i,1)-xc)^2+(y(i,1)-yc)^2+(z(i,1)-zc)^2);
            vect_dis(i,1)=sqrt((2*distvox_x)^2+(2*distvox_y)^2+(2*distvox_z)^2);
end
mindis(p,1)=min(vect_dis);
end