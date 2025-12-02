function [] = improveJournalFig(plot_width_px, plot_height_px)
    % Author:  C Folinus, MIT 05/2024
    % ----------------------------------------------------------------------
    % Adapted from improveThesisFig (C Folinus, MIT 04/2022, from B Hughey, MIT
    % MechE)
    %
    % Revised: C Folinus, MIT 05/2024
    % Changes:
    % - Changed inputs to include "_px"
    % - Modified fonts to Helvetica
    % ----------------------------------------------------------------------
    %
    % improveJournalFig formats the active figure and reshapes it to a
    % specified size. MATLAB treats figures differently on Mac and PC
    % operating systems; this version was created for MacOS, and figures
    % may not look as intended using PC.
    %
    % Original source code modified from Dr. Barbara Hughey's
    % "improveFig.m", created for MIT's 2.671 course (available on 2.671
    % course website).
    %
    % Inputs:
    %   plot_width: horizontal size/length of figure after reformatting, in
    %               current figure units (default is pixels) (scalar double)
    %   plot_height: vertical size/length of figure after reformatting, in
    %               current figure units (default is pixels) (scalar double)
    %
    % ----------------------------------------------------------------------

    %% SETUP
    % Markers and Lines
    % marker_size=25;
    % marker_line_width=1;
    box_thickness = 1.5;
    % error_bar_cap_size = 15;
    % marker_outline = 'matching'; % could be 'black' or 'matching'    
    
    % Fonts
    axis_tick_font_size = 14;
    axis_label_font_size = 18;
    legend_font_size = 14;
    latexReg = 'Helvetica';

    % Get current figure, change to white background
    hFig = gcf;                    
    set(hFig, 'Color', 'white', 'Position', [100,100,plot_width_px,plot_height_px]);


    %% FORMAT AXES
    % Iterate over all axes handles
    axis_handles=findobj(hFig,'type','axe');
    for i = 1:length(axis_handles)
        ax = axis_handles(i);

        % CHANGE AXES AND TICKS
        set(ax,'Box', 'off', 'TickDir', 'out', ...
            'FontSize', axis_tick_font_size, ...
            'FontSmoothing', 'on', 'FontName', latexReg, 'FontWeight', 'normal', ...
            'LineWidth', box_thickness);

        % CHANGE AXES LABELS
        set(get(ax, 'XLabel'), ...
            'FontSmoothing', 'on', 'FontName', latexReg,...
            'FontSize', axis_label_font_size, 'FontWeight', 'bold');
        set(get(ax, 'YLabel'),...
            'FontSmoothing', 'on', 'FontName', latexReg,...
            'FontSize', axis_label_font_size, 'FontWeight', 'bold');
        set(get(ax, 'ZLabel'),...
            'FontSmoothing', 'on', 'FontName', latexReg,...
            'FontSize', axis_label_font_size, 'FontWeight', 'bold');

        % MOVE AXES TO TOP LAYER
        set(ax, 'Layer', 'Top');
    
    end
    
%     %% FORMAT LINES AND MARKERS (if desired; I usually manually set
%     these)
%     % Find all the lines, and markers
%     LineH = findobj(hFig, 'type', 'line', '-or', 'type', 'errorbar');
% 
%     if(~isempty(LineH))
%         for i=1:length(LineH) % Iterate over all lines in the plot
%             % Decide what color for the marker edges
%             this_line_color = get(LineH(i),'color');
%             if strcmp(marker_outline, 'black')
%                 marker_outline_color = 'black';
%             elseif strcmp(marker_outline, 'matching')
%                 marker_outline_color = this_line_color;
%             else
%                 marker_outline_color = 'black';
%             end
% 
%             % If the LineWidth has not been customized, then change it
%             if (get(LineH(i), 'LineWidth') <= 1.0)
%                 set(LineH(i), 'LineWidth', marker_line_width)
%             end
%             % Change lines and markers if they exist on the plot
%             set(LineH(i),   ...
%                 'MarkerEdgeColor', marker_outline_color, ...
%                 'MarkerFaceColor', this_line_color);
%         end
%     end
% 
%     % Find and change the error bars
%     LineH = findobj(hFig, 'type', 'errorbar');
%     if(~isempty(LineH))
%         for i=1:length(LineH) % Iterate over all lines in the plot
%             LineH(i).CapSize=error_bar_cap_size;
% 
%         end
%     end

    %% FORMAT LEGEND
    % Find the legend, and if there is one, change it  
    h = get(hFig,'children');
    for k = 1:length(h)
        if strcmpi(get(h(k),'Tag'),'legend')
            set(h(k), 'EdgeColor', 'none',...
                'FontSize', legend_font_size,...
                'FontName', latexReg, 'FontWeight', 'normal');
            break;
        end
    end

end