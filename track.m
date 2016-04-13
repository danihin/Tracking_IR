%% PEOPLE TRACKING ALGORITHM IN IR-IMAGES
% INTRODUCTORY TEXT
%%

close all

% %create AVI object
% vidObj = VideoWriter('video_1');
% vidObj.Quality = 100;
% vidObj.FrameRate = 10;
% open(vidObj);

%% DEFINE PARAMETERS

WIDTH = 384;
HEIGHT = 288;
TRESHOLD = 200;
MAX_PERSONS = 10;

IR_data = memmapfile('frames_part1.dat', 'format',{'uint16',[HEIGHT, WIDTH],'frame'},'Repeat',Inf);

start_frame=1;
for frame_number = start_frame:(start_frame+100)
    
    %get frame to current frame_number
    frame = IR_data.Data(frame_number).frame;
    
    %% PREPROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% CREATE AVERAGE TEMPLATE
    
    %empty frames (without any person)
    av1 = IR_data.Data(490).frame;
    av2 = IR_data.Data(500).frame;
    av3= IR_data.Data(590).frame;
    av4 = IR_data.Data(600).frame;
    
    mat_average = zeros(HEIGHT,WIDTH);
    
    for h = 1:HEIGHT
        for w = 1:WIDTH
            %calculate average of empty frames
            mat_average(h,w) = (av1(h,w)+av2(h,w)+av3(h,w)+av4(h,w))/4;
        end
    end
    
    %% BACKGROUND SUBSTRACTION
    
    mat_diff = zeros(HEIGHT,WIDTH);
    
    for h = 1:HEIGHT
        for w = 1:WIDTH
            mat_diff(h,w) = (frame(h,w) - mat_average(h,w)) ;
        end
    end
    
    %% GAUSSIAN
    
    hsize = [5 5];
    sigma = 0.5;
    h = fspecial('disk',10);
    mat_gaussian = imfilter(mat_diff,h,'replicate');
    
    %% TRESHOLD
    
    mat_threshold = mat_diff;
    
    for h = 1:HEIGHT
        for w = 1:WIDTH
            if(mat_threshold(h,w)<TRESHOLD)
                mat_threshold(h,w)=0;
            else
                mat_threshold(h,w)=1;
            end
        end
    end
    
    %% NOISE CANCEL
    
    %remove all objects containing fewer than 1000 pixels
    mat_noise_cancel = bwareaopen(mat_threshold, 1000);
    
    %% PLOT
    
    % figure(1)
    % hold on
    %
    % subplot(2,2,1)
    % imagesc(frame)
    % caxis([15000 16000])
    %
    % subplot(2,2,3)
    % imagesc(mat_threshold)
    % caxis([0 1])
    %
    % subplot(2,2,4)
    % imagesc(mat_noise_cancel)
    % caxis([0 1])
    %
    % subplot(2,2,2)
    % imagesc(mat_diff)
    % caxis([70 200])
    
    %% TRACKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% PROJECTION
    
    %new width because of defect pixels
    width_new = WIDTH-20;
    
    mat_w = zeros(1,width_new);
    mat_h = zeros(HEIGHT,1);
    
    %write mean values for rows
    for h = 1:HEIGHT
        mat_h(h) = sum(frame(h,1:width_new))/width_new;
    end
    
    %write mean values for columns
    for w = 1:width_new
        mat_w(w) = sum(frame(:,w))/HEIGHT;
    end
    
    %get maxima of projection
    [max_w pos_w] = max(mat_w(:));
    [max_h pos_h] = max(mat_h(:));
    
    %% EXPONENTIAL SMOOTHING
    
    mat_w_smooth = zeros(1,width_new);
    mat_h_smooth = zeros(HEIGHT,1);
    
    %set initial values
    predict_h =  mat_h(1);
    predict_w =  mat_w(1);
    alpha = 0.1;
    
    %smooth column projection
    for h = 1:HEIGHT
        mat_h_smooth(h) = (alpha*mat_h(h))+((1-alpha)*predict_h);
        predict_h = mat_h_smooth(h);
    end
    
    %smooth row projection
    for w = 1:width_new
        mat_w_smooth(w) = (alpha*mat_w(w))+((1-alpha)*predict_w);
        predict_w = mat_w_smooth(w);
    end
    
    %% SET PROJECTION TRESHOLD
    
    mean_projection_w = sum(mat_w_smooth)/width_new;
    tresh_projection_w = mean_projection_w + (max_w - mean_projection_w)/5;
    
    %% EXTRACTION OF PEOPLE FROM PROJECTION
    
    person_position_w = zeros(1,MAX_PERSONS);
    person_position = zeros(1,MAX_PERSONS);
    person_position_counter = 1;
    person_count = 0;
    
    grad_pos = 0;
    
    pos_a = 0;
    pos_b = 0;
    
    for w = 1:width_new
        if (mat_w_smooth(w) > tresh_projection_w) && (grad_pos == 0)
            
            %maxima in endregion of image
            if(w == HEIGHT)
                person_position_w(person_count) = pos_a + int32((w - pos_a)/2);
            end
            
            pos_a = w;
            person_position(person_position_counter) = pos_a;
            person_position_counter = person_position_counter + 1;
            grad_pos = 1;
        end
        
        if (mat_w_smooth(w) < tresh_projection_w) && (grad_pos == 1)
            pos_b = w;
            
            person_position(person_position_counter) = pos_b;
            person_position_counter = person_position_counter + 1;
            
            person_count = person_count + 1;
            
            [max_w_sub pos_w_sub] = max(mat_w(pos_a:pos_b));
            person_position_w(person_count) = pos_w_sub + pos_a;
            
            %set trackingpoint to middleposition of maxima
            %person_position_w(person_count) = pos_a + int32((pos_b - pos_a)/2);
            
            grad_pos = 0;
        end
    end
    
    %width-projection for each height-area
    
    person_position_h = zeros(1,MAX_PERSONS);
    
    for s = 1:person_count
        
        mat_h_sub = zeros(HEIGHT,1);
        
        if(frame_number == 37)
            %
        end
        
        %write mean values for rows
        for h = 1:HEIGHT
            mat_h_sub(h) = sum(frame(h,person_position(s+(s-1)):person_position(s+s)))/width_new;
        end
        
        %get maxima of projection -> tracking point
        [max_h_sub pos_h_sub] = max(mat_h_sub(:));
        person_position_h(s) = pos_h_sub;
        
    end
    
    %% PLOT
    
    fig = figure(2);
    set(fig,'units','normalized','outerposition',[0 0 1 1]);
    %hold on
    
    subplot(2,2,3)
    imagesc(frame)
    caxis([15000 16000])
    %caxis([80 300])
    
    hold on
    k=1;
    while(person_position_w(k) ~= 0)
        
        if(person_position_h(k) == 0 && (k ~= 1))
            person_position_h(k) = person_position_h(k-1);
        end
        plot(person_position_w(k), person_position_h(k),'+','color','r','MarkerSize',10)
        hold on;
        k = k + 1;
    end
    
    subplot(2,2,4)
    plot(mat_h)
    view(-270,90)
    
    subplot(2,2,1)
    plot(mat_w)
    
    pause(0.01)
   
%     drawnow;
%     add current frame of figure(gcf) to video
%     writeVideo(vidObj, getframe(gcf));
end
% 
% close(vidObj);
