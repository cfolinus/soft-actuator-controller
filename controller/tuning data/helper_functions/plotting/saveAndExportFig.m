function saveAndExportFig (figure_name, varargin)
    % Author:  C Folinus, MIT 06/2021
    % ----------------------------------------------------------------------
    % Revised: C Folinus, MIT 08/2024
    % Changes:
    % - Added variable number of inputs to allow specifying particular file
    % outputs
    % ----------------------------------------------------------------------
    %
    % saveAndExportFig saves the active figure to multiple file types
    % (.png, .pdf, and .fig) using the base figure_name: generating
    % figure_name.png, figure_name.pdf, and figure_name.fig.
    % 
    %
    % Inputs:
    %   figure_name: base filename for the saved figures. By default,
    %               MATLAB will save in the current active directory; if
    %               figure_name is a filepath (without the extension),
    %               MATLAB will save into the designated directory/subdirectory (char)
    %
    % ----------------------------------------------------------------------
    
    % Handle variable number of input arguments
    if isempty(varargin)
        figure_outputs = 'all';
    elseif isscalar(varargin)
        temp_inputs = varargin;
        figure_outputs = temp_inputs{1};
    else
        error('Error in saveOpenFigs: too many inputs');
    end


    
    % Define 'all' figure_outputs
    if strcmp(figure_outputs, 'all')
        figure_outputs = {'png', 'pdf', 'fig', 'svg'};
    end



    if any(strcmp(figure_outputs, 'png'))
        % Save .PNG with 300ppi resolution; can be changed to save at higher res
        % exportgraphics(gcf, [figure_name, '.png'], ...
        %                 'Resolution', '600');
        print([figure_name, '.png'], '-dpng', '-r300');
        pause(0.25);
    end



    if any(strcmp(figure_outputs, 'pdf'))
        % Save .PDF with bestfit page size; can be changed to save with a
        % desired page size
        warning off;
        exportgraphics(gcf, [figure_name, '.pdf'], 'ContentType', 'vector');
        warning on;
    end


    if any(strcmp(figure_outputs, 'fig'))
        % Save .FIG
        savefig ([figure_name, '.fig'])
    end


    if any(strcmp(figure_outputs, 'svg'))
        % Save .SVG
        print(gcf, [figure_name, '.svg'], '-dsvg');
    end

%     % Uncomment to save a .png with no background
%     hFig = gcf;    
%     ax = gca;
%     ax = gca; 
%     ax.XTickMode = 'manual';
%     ax.YTickMode = 'manual';
%     ax.ZTickMode = 'manual';
%     ax.XLimMode = 'manual';
%     ax.YLimMode = 'manual';
%     ax.ZLimMode = 'manual';
%     exportgraphics(ax, [figure_name, '.png'], ...
%         'Resolution', 300, 'BackgroundColor', 'none');


end