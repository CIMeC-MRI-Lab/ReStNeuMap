%%%% This script moves network files to relevant subfolder (i.e. DMN1, DMN2, DMN3, DMN_template, etc. --> DMN)
function results2folders()
    clear DMN FPN Language prim_Visual SAN Sensorimotor Visuospatial
    processDir = evalin('base','processDir');
    templateDir = evalin('base','templateDir');
    
    networks = ["DMN","FPN","Language","Prim_Visual","Speech_Arrest","Sensorimotor","Visuospatial"];
    DMN_files = dir('*DMN*.*');
    FPN_files = dir('*FPN*.*');
    Language_files = dir('*Language*.*');
    PrimVisual_files = dir('*Prim_Visual*.*');
    SAN_files = dir('*Speech_Arrest*.*');
    Sensorimotor_files = dir('*Sensorimotor*.*');
    Visuospatial_files = dir('*Visuospatial*.*');

    for i=1:length(networks)
        mkdir(strcat(processDir,filesep,char(networks(i))));
    end

    network_files = {DMN_files,FPN_files,Language_files,PrimVisual_files,SAN_files,Sensorimotor_files,Visuospatial_files};
    for j=1:length(network_files)
        cur_network_files = network_files{j};
        cur_folder = what(char(networks(j)));
        cur_folder = cur_folder.path;
        for k=1:length(cur_network_files)
            [status,msg] = movefile(cur_network_files(k).name,cur_folder);
            if strcmp(cur_network_files(k).name,'.nii')
                cur_file = cur_network_files(k).name;
                system(['gzip ', fullfile(cur_folder,filesep,curfile) ]);
            end
        end
    end

    system(['gzip ', pwd, '/*.nii ']);
    rmdir(templateDir,'s');
end