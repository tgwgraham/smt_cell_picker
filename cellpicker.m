function cellpicker(basefname,range,outfile,gridsize)
% cellpicker(infile,range,outfile)
% 
% inputs
% % basefname - base file name of snapshots
% % range - min and max file numbers to include
% % outfile - output (.mat) file to store the categorization of good vs.
% bad
% % gridsize - size of grid for display

placeholderim = imread('placeholder.png');

if exist(outfile,'file')
    temp = load(outfile);
    classification = temp.classification;
    masks = temp.masks;
else
    % in this version the classification array and masks cell array will
    % start at 1, even if the range of movies does not
    classification = zeros(1,range(2));
    masks = cell(1,range(2));
end

f = figure;
if ~exist('gridsize')
    nrows = 6;
    ncols = 6;
else
    nrows = gridsize(1);
    ncols = gridsize(2);
end

nmontages = ceil((1+range(2)-range(1))/(nrows*ncols));
n = range(1);
disp(range(1))
m = 0;
while m < nmontages
    clf;
    handles = [];
    rects = [];
    for j=n:min(n+nrows*ncols-1, range(2))
                
        currf = sprintf('%s%d.tif',basefname,j);
        
        if ~exist(currf,'file')
            handles(end+1) = subplot(nrows,ncols,j-n+1);
            imshow(placeholderim); axis equal; axis off;
            title(sprintf('FOV %d: Rejected',j))
            continue;
        end
        
        im = double(imread(currf));
        minpx = min(im(:));
        maxpx = max(im(:));
        im = (im - minpx)/(maxpx-minpx);
        segf = sprintf('%s%d_seg.csv',basefname,j);
        
        if isempty(masks{j})
            seg = csvread(segf);
            masks{j} = seg;
        else
            seg = masks{j};
        end
        
        handles(end+1) = subplot(nrows,ncols,j-n+1);
        
        % TO DO: Divide up the seg into positive and negative
        % Draw each in a different color.
%         posseg = seg;
%         posseg(posseg < 0) = 0;
%         posbounds = bwboundaries(posseg);      
%         
%         negseg = seg;
%         negseg(negseg > 0) = 0;
%         negbounds = bwboundaries(negseg);
%         
%         %ov = labeloverlay(im,boundaries);
%         %imshow(ov);
%                
%         for b = 1:length(posbounds)
%             bounds = posbounds{b};
%             plot(bounds(:,2),bounds(:,1),'b-')
%         end
% 
%         for b = 1:length(negbounds)
%             bounds = negbounds{b};
%             plot(bounds(:,2),bounds(:,1),'-','Color',[0,0.75,0])
%         end

        imagesc(im); colormap gray; hold on;
        
        posindices = unique(seg(seg(:) > 0));
        negindices = unique(seg(seg(:) < 0));
        
        for regind = 1:numel(posindices)
            currmask = seg==posindices(regind);
            bounds = bwboundaries(currmask);
            plot(bounds{1}(:,2),bounds{1}(:,1),'b-')            
        end

        for regind = 1:numel(negindices)
            currmask = seg==negindices(regind);
            bounds = bwboundaries(currmask);
            plot(bounds{1}(:,2),bounds{1}(:,1),'-','Color',[0,0.75,0])
        end
        
        if any(masks{j}(:)<0)
            classification(j) = 1;
        else
            classification(j) = 0;
        end
        
        %hold on; 
        rects(end+1) = rectangle('Position',[1,1,size(im)],'LineWidth',2);
        if classification(j) == 1
            set(rects(end),'EdgeColor',[0,0.75,0]);
        else
            set(rects(end),'EdgeColor','b');
        end
        
        axis equal; axis off;
        set(gca,'ButtonDownFcn',@(x,y)disp([num2str(x) num2str(y)]),...
            'HitTest','on')
        title(sprintf('FOV %d (%d, %d)',j,minpx,maxpx))
        set(gcf,'name',sprintf('Cells %d to %d of %d.',n,min(n+nrows*ncols-1, range(2)),range(2)))
    end
    gottenkey = 0;
    while ~gottenkey
        [x,y,key] = ginput(1);
        if key == 113
            %gottenkey = 1;
            m = nmontages;
            close(f)
        elseif key == 28
            %gottenkey = 1;
            n = n - nrows*ncols;
            m = m-1;
        elseif key == 29
            %gottenkey = 1;
            n = n + nrows*ncols;
            m = m+1;
        else
            clickedim = find(handles==gca);
            clickedindex = n + clickedim - 1;
            
            % Determine in which ROI the click lies, and change the sign of
            % that label
            if ~isempty(masks{clickedindex})
                currlabel = masks{clickedindex}(round(y),round(x));
                masks{clickedindex}(masks{clickedindex}==currlabel) = -currlabel;
                if any(masks{clickedindex}<0)
                    classification(clickedindex) = 1;
                else
                    classification(clickedindex) = 0;
                end
            end
            
%             if classification(clickedindex) == 1
%                 set(rects(clickedim),'EdgeColor','b');
%             else
%                 set(rects(clickedim),'EdgeColor',[0,0.75,0]);
%             end    
        end
        gottenkey = 1;
        save(outfile,'classification','range','masks');
    end
    
end


end