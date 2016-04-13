function [irData] = allocate_memory( nrMemmapfiles, MaxNrFrames, nrPckPROmemmap, nrPackages, nrFilesINPackage, height, width, nameDatFile)
%allocate_memory Summary of this function goes here
%   Detailed explanation goes here


if mod(nrPackages/nrPckPROmemmap,1) == 0  %if isinteger(nrMemmapfiles)
    
    for i = 1:nrMemmapfiles
        frameSequency = strcat(nameDatFile,'_part', num2str(i),'.dat');
        h = fopen(frameSequency, 'wb');
        
        text_waitbar = ['Please wait...',blanks(10), 'Part', num2str(i),'/',num2str(nrMemmapfiles),blanks(10)];
        %wait_bar = waitbar(0,text_waitbar);
        wait_bar = waitbar(0,'0','Name','Creating *.dat file...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(wait_bar,'canceling',0)
        
        for j = 1:(MaxNrFrames)
            % Check for Cancel button press
            if getappdata(wait_bar,'canceling')
                break
            end
            
            fwrite(h,rand(height,width), 'uint16');
            waitbar(j/(MaxNrFrames),wait_bar,sprintf('%s Frame %d',text_waitbar, j))
        end
        
        fclose(h);
        delete(wait_bar);
        irData{i} = memmapfile(frameSequency,'format',{'uint16',[height, width],'frame'}, ...
            'Repeat',MaxNrFrames, 'Writable', true);
    end
    
    msgbox('Files created!!!');
    

elseif  nrPackages/nrPckPROmemmap < 1   
    
    for i = 1:nrMemmapfiles
        frameSequency = strcat(nameDatFile,'_part', num2str(i),'.dat');
        h = fopen(frameSequency, 'wb');
        
        text_waitbar = ['Please wait...',blanks(10), 'Part', num2str(i),'/',num2str(nrMemmapfiles),blanks(10)];
        %wait_bar = waitbar(0,text_waitbar);
        wait_bar = waitbar(0,'0','Name','Creating *.dat file...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(wait_bar,'canceling',0)
        
        for j = 1:(nrFilesINPackage)
            % Check for Cancel button press
            if getappdata(wait_bar,'canceling')
                break
            end
            
            fwrite(h,rand(height,width), 'uint16');
            waitbar(j/(nrFilesINPackage),wait_bar,sprintf('%s Frame %d',text_waitbar, j))
        end
        
        fclose(h);
        delete(wait_bar);
        irData{i} = memmapfile(frameSequency,'format',{'uint16',[height, width],'frame'}, ...
            'Repeat',nrFilesINPackage, 'Writable', true);
    end
    
    msgbox('Files created!!!');    
    
else
    
    for i = 1:nrMemmapfiles-1
        frameSequency = strcat(nameDatFile,'_part', num2str(i),'.dat');
        h = fopen(frameSequency, 'wb');
        
        text_waitbar = ['Please wait...',blanks(10), 'Part', num2str(i),'/',num2str(nrMemmapfiles),blanks(10)];
        %wait_bar = waitbar(0,text_waitbar);
        wait_bar = waitbar(0,'0','Name','Creating *.dat file...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(wait_bar,'canceling',0)
        
        for j = 1:(MaxNrFrames)
            % Check for Cancel button press
            if getappdata(wait_bar,'canceling')
                break
            end
            
            fwrite(h,rand(height,width), 'uint16');
            waitbar(j/(MaxNrFrames),wait_bar,sprintf('%s Frame %d',text_waitbar, j))
        end
        
        fclose(h);
        delete(wait_bar);
        
        irData{i} = memmapfile(frameSequency,'format',{'uint16',[height, width],'frame'}, ...
            'Repeat',MaxNrFrames, 'Writable', true);
    end
    
    for i = nrMemmapfiles
        frameSequency = strcat(nameDatFile,'_part', num2str(i),'.dat');
        h = fopen(frameSequency, 'wb');
        
        text_waitbar = ['Please wait...',blanks(10), 'Part', num2str(i),'/',num2str(nrMemmapfiles),blanks(10)];
        %wait_bar = waitbar(0,text_waitbar);
        wait_bar = waitbar(0,'0','Name','Creating *.dat file...',...
            'CreateCancelBtn',...
            'setappdata(gcbf,''canceling'',1)');
        setappdata(wait_bar,'canceling',0)
        
        last_frames = (nrPackages - (floor(nrPackages/nrPckPROmemmap)*nrPckPROmemmap)-1)*nrFilesINPackage;
        
        for j = 1:last_frames
            % Check for Cancel button press
            if getappdata(wait_bar,'canceling')
                break
            end
            
            fwrite(h,rand(height,width), 'uint16');
            waitbar(j/last_frames,wait_bar,sprintf('%s Frame %d',text_waitbar, j))
        end
        
        fclose(h);
        delete(wait_bar);
        irData{i} = memmapfile(frameSequency,'format',{'uint16',[height, width],'frame'}, ...
            'Repeat',last_frames, 'Writable', true);
    end
    
    msgbox('Files created!!!');
    
end

end

