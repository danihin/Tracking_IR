function [countTotalFrames] = getIRBdata(pathIRTdata, nameDatFile)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

close all
%keyboard;
%nrFilesINPackage;



%%%%%%%%%%%%%%%%%%%%%%                               %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%         Parameters            %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%                               %%%%%%%%%%%%%%%%%%%%%%
header = 7424; % 2*3712 bytes -> uint16=2bytes
tail = 2*896;%+2*2*1024; % 2*896 bytes -> uint16=2bytes
width = 384;
height = 288;
precision = 'uint16';
nrFramesProPackage = 750;
nrPckPROmemmap = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%                               %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%           Figures             %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%                               %%%%%%%%%%%%%%%%%%%%%%
fig1 = figure(1);
set(fig1,'Position',[-1906 520 560 474])
figures.fig_thermogram = axes;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



currentFolder = pwd;
cd(pathIRTdata)
addpath(currentFolder);



% #***_List all files contained in the current directory_***#
listing = dir(pwd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%                       For Loop                        %%%%%%%%%%
%%%%%%%%%%         Keep in the list just *.irb* files            %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% #***_Search in #struct# listing all names that do not contain the
% #String# '.irb'_***#
row = 1;
for i = 1:size(listing,1) % [1:nummer_of_columns]
    filename_i = listing(i).name; % Name of file for column i
    k = strfind(filename_i, '.irb'); % Find string '.irb' in #var# filename_i
    % if filename_i does not contain the string '.irb' then
    % k is empty,
    % else
    % k contains the position where string '.irb' beginns.
    if isempty(k) % if k is empty then save row's number
        delFromlisting(row,1) = i;
        row = row + 1;
    end
end

% #***_Convert #struct# listing to #cell# listing_table_***#
listing_table = struct2cell(listing)';
% #***_Sort the #array# delFromlisting_***#
delFromlisting = sort(delFromlisting,'descend');
% #***_Delete rows from #cell# listing table_***#
listing_table = removerows(listing_table,'ind',delFromlisting(1:end));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



nrPackages = size(listing_table,1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%             Define Name of Memmapfiles                %%%%%%%%%%
%%%%%%%%%%                  Memory allocation                    %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nrMemmapfiles = ceil(nrPackages/nrPckPROmemmap);
MaxNrFrames = nrPckPROmemmap * nrFramesProPackage; %% 100 Packages * 50 frames

[irData] = allocate_memory(nrMemmapfiles, MaxNrFrames, nrPckPROmemmap, nrPackages, nrFramesProPackage, height, width, nameDatFile);

countTotalFrames = 1;
countFrames = 1;
step = 1;

%keyboard;

if nrPackages ~= 1
    for file_row = 1:nrPackages-1
        
        if file_row == 1, disp('memmapfile - 1'); end
        
        filename = listing_table{file_row,1}(:,:); % 'irdata_000.irb'
        fileID = fopen(filename,'r');
        
        for i = 1:nrFramesProPackage
            
            if i == 1
                skip = header;
            else
                skip = (header + 2*height*width + tail)*(i-1) + header;
            end
            
            fseek(fileID,skip,'bof');
            image = fread(fileID,[width,height],precision);
            
            thermogram = (reshape(image,width,height))';
            irData{step}.Data(countFrames).frame = uint16(thermogram);
            
            imagesc(thermogram, 'Parent', figures.fig_thermogram)
            text_fig = [num2str(countFrames), ' (', num2str(step),'/',num2str(nrMemmapfiles),')'];
            text(5,10,text_fig,'FontSize',18,'Color','w');
            axis image
            drawnow;
            
            countFrames = countFrames + 1;
            countTotalFrames = countTotalFrames + 1;
        end
        
        
        if (abs(round(file_row/nrPckPROmemmap) - file_row/nrPckPROmemmap) <= ...
                sqrt(eps(file_row/nrPckPROmemmap)))==1
            irData{step}=[];
            step = step + 1;
            countFrames = 1;
            X = ['memmapfile - ', num2str(step)];
            disp(X);
        end
        
        fclose(fileID);
    end
    
else
    
    file_row = 1;
    
    disp('memmapfile - 1');
    
    filename = listing_table{file_row,1}(:,:); % 'irdata_000.irb'
    fileID = fopen(filename,'r');
    
    for i = 1:nrFramesProPackage
        
        if i == 1
            skip = header;
        else
            skip = (header + 2*height*width + tail)*(i-1) + header;
        end
        
        fseek(fileID,skip,'bof');
        image = fread(fileID,[width,height],precision);
        
        thermogram = (reshape(image,width,height))';
        irData{step}.Data(countFrames).frame = uint16(thermogram);
        
        imagesc(thermogram, 'Parent', figures.fig_thermogram)
        text_fig = [num2str(countFrames), ' (', num2str(step),'/',num2str(nrMemmapfiles),')'];
        text(5,10,text_fig,'FontSize',18,'Color','w');
        axis image
        drawnow;
        
        countFrames = countFrames + 1;
        countTotalFrames = countTotalFrames + 1;
    end
    
    
    if (abs(round(file_row/nrPckPROmemmap) - file_row/nrPckPROmemmap) <= ...
            sqrt(eps(file_row/nrPckPROmemmap)))==1
        irData{step}=[];
        step = step + 1;
        countFrames = 1;
        X = ['memmapfile - ', num2str(step)];
        disp(X);
    end
    
    fclose(fileID);
end


end




