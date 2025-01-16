%%%% This script labels the top3 components per network 
% processDir = evalin('base','processDir');
% cd(processDir);

primVis_cc = importdata('rPrim_Visual.txt');
mot_cc = importdata('rSensorimotor.txt');
lang_cc = importdata ('rLanguage.txt');
Speech_Arrest_cc = importdata ('rSpeech_Arrest.txt');
FPN_cc = importdata('rFPN.txt');
VSN_cc = importdata('rVisuospatial.txt');
DMN_cc = importdata('rDMN.txt');

cc_values= {primVis_cc(:,3), mot_cc(:,3), lang_cc(:,3), Speech_Arrest_cc(:,3), FPN_cc(:,3), VSN_cc(:,3), DMN_cc(:,3)};
cc_IC= {primVis_cc(:,1), mot_cc(:,1), lang_cc(:,1), Speech_Arrest_cc(:,1), FPN_cc(:,1), VSN_cc(:,1), DMN_cc(:,1)};

winning_cc=cell(1,length(cc_values));
for i=1:length(cc_values)
    cc_column_values = cc_values{i}; % Takes values of all CC scores for each network
    [max_cc, maxcc_index] = sort(cc_values{i},'descend'); % Takes all CC scores, and sort them in descending order for each network
    temp = cc_IC{i}(maxcc_index);
    if length(temp)>2
        winning_cc{1,i} = [temp(1:3), max_cc(1:3)];
    else
        winning_cc{1,i} = [temp(1:length(temp)), max_cc(1:length(temp))];
    end
end

% Label the images 
names = {'Prim_Visual', 'Sensorimotor', 'Language', 'Speech_Arrest', 'FPN', 'Visuospatial', 'DMN'};
for k=1:length(names)
    
    % Template image
    filename = strcat(names{k},'_template.png');
    image = imread(filename);
    label = strcat(erase(names{k},'_'),' template');
    figure;
    set(0, 'DefaultFigureVisible', 'off');
    imshow(image,'Border','tight');
    hold on;
    title(label, 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
    set(gca,'XTick',[], 'YTick', [])
    set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
    hold off;
    clear filename image label
    
    % Overlap melodic ICs and templates ranked on the basis of the
    % cross correlation value
    for f=1:length(winning_cc{k})
        
        winning_cell = winning_cc{k}(f,2);
        filename = strcat('top',num2str(f),names{k},'.png');
        image = imread(filename);
        label = strcat('Top', num2str(f), ', IC=', num2str(winning_cc{k}(f,1)), ', r=', num2str(winning_cell), ' (red=ICs, green=template, yellow=overlap)');
        figure;
        set(0, 'DefaultFigureVisible', 'off');
        imshow(image,'Border','tight');
        hold on;
        title(label, 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'k');
        set(gca,'XTick',[], 'YTick', [])
        set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
        filename1=strcat('top',num2str(f),names{k},'.png');
        saveas(gcf,filename1);
        hold off;
        
    end
end