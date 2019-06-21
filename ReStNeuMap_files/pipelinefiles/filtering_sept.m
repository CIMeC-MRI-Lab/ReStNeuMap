
            %compute WM and CSF mask average signal from head motion
            %corrected volumes
            InputIm=spm_read_vols(spm_vol('craOutBrick.nii'));
            WMmask=dir('rc2*.nii');
            WMmask=spm_read_vols(spm_vol(WMmask.name));
            CSFmask=dir('rc3*.nii');
            CSFmask=spm_read_vols(spm_vol(CSFmask.name));
            
            %select 3D head motion corrected volumes 
            procfile=dir('ua*_00*.nii');
            
            avg_WM=zeros(size(InputIm,4),1);
            avg_CSF=zeros(size(InputIm,4),1);
            for t=1:size(InputIm,4)
                funcvol=spm_read_vols(spm_vol(procfile(t+4,1).name));
                avg_WM(t,1)=mean(funcvol(WMmask>0.9));
                avg_CSF(t,1)=mean(funcvol(CSFmask>0.9));
            end
            
            %median filtering, detrending and low pass filtering of head motion parameters
            mov = dir ('rp*.txt');
            mov = Read_1D (mov.name,1);
            mov=mov(5:size(mov,1),:);
            movmed=medfilt1(mov,2);
            %movmed=medfilt1(mov(5:size(mov,1),:),2);
            
            t = (1:length(movmed))';
            opol = 4;
            [b,a] = butter(4,0.63);
            movmed=detrend(movmed);

            for i=1:size(movmed,2)
                [p,s,mu] = polyfit(t,movmed(:,i),opol);
                f_y = polyval(p,t,[],mu);
                movmed_det(:,i) = movmed(:,i) - f_y;
                movmed_detfilt(:,i)= filter(b,a,movmed_det(:,i));
            end
            
            %median filtering, detrending,low pass filtering of WM average
            %time series
            avg_WM=detrend(avg_WM);
            WM_med=medfilt1(avg_WM,2);
            [p,s,mu] = polyfit(t,WM_med,opol);
            f_y = polyval(p,t,[],mu);
            WM_med_det = WM_med - f_y;
            WM_med_detfilt= filter(b,a,WM_med_det);
            [mdl,mdlint,mdl_WM_resid]=regress(WM_med_detfilt,movmed_detfilt);

            %median filtering, detrending,low pass filtering of CSF average
            %time series
            avg_CSF=detrend(avg_CSF);
            CSF_med=medfilt1(avg_CSF,2);
            [p,s,mu] = polyfit(t,CSF_med,opol);
            f_y = polyval(p,t,[],mu);
            CSF_med_det = CSF_med - f_y;
            CSF_med_detfilt= filter(b,a,CSF_med_det);
            [mdl,mdlint,mdl_CSF_resid]=regress(CSF_med_detfilt,movmed_detfilt);
            
             %median filtering, detrending,low pass filtering and nuisance regression of 
            %each voxel time series
            InputDetFilt_reg=zeros(size(InputIm,1),size(InputIm,2),size(InputIm,3),size(InputIm,4));
            TimeSer=zeros(size(InputIm,4),1);
            for i=1:size(InputIm,1)
                for j=1:size(InputIm,2)
                    for k=1:size(InputIm,3)
                        for l=1:size(TimeSer,1)
                            TimeSer(l,1)=InputIm(i,j,k,l);
                        end
                    TimeSer=detrend(TimeSer);
                    TimeSermed=medfilt1(TimeSer,2);
                    [p,~,mu] = polyfit(t,TimeSermed,opol);
                    f_y = polyval(p,t,[],mu);
                    TimeSerDet = TimeSermed - f_y;
                    TimeSerDetFilt= filter(b,a,TimeSerDet);
                    nuisances=[movmed_detfilt,mdl_WM_resid,mdl_CSF_resid];
                    [mdl,mdlint,TimeSerDetFilt_resid]=regress(TimeSerDetFilt,nuisances);
                    InputDetFilt_reg(i,j,k,:)=TimeSerDetFilt_resid+mean2(InputIm(i,j,k,:));
            
                    end
                end
            end
            
            %Write 3D file from previous time series
            Input=dir('ua*_00005.nii');
            Input=spm_vol(Input.name);

            
            for t=1:size(InputIm,4)
              funcfile = sprintf('InputDetFiltReg_00%d.nii',t);
              InputOut=Input;
              InputOut.fname=funcfile;
              spm_write_vol(InputOut,InputDetFilt_reg(:,:,:,t));  
            end
            
            %Spatial smoothing
            inputmat=Input.mat;
            point1=cor2mni([1 1 1],inputmat);
            point2=cor2mni([1 2 1],inputmat);
            fwhm=2*pdist2(point1, point2);
            filtereim=dir('*DetFiltReg*');
            for i=1:size(filtereim,1)
                %spm_smooth(filtereim(i,1).name,strcat('sm', filtereim(i,1).name),6,0);
                spm_smooth(filtereim(i,1).name,strcat('sm', filtereim(i,1).name),fwhm,0);
            end
    
    
    
    
    
