function saveOpenFigs (fig_directory, varargin)

    if isempty(varargin)
        figure_outputs = 'all';
    elseif isscalar(varargin)
        figure_outputs = varargin;
    else
        error('Error in saveOpenFigs: too many inputs');
    end
    

    fprintf('Saving figures... \n')

    % Make figure directory if it doesn't already exist
    if not(isfolder(fig_directory))
        fprintf('\tMaking figure directory... \n\n')
        mkdir(fig_directory);
    end
    
    % Loop over figures
    figure_handles = findall (0, 'type', 'figure');

    % Get figure
    for figure_index = 1:length(figure_handles)
        fprintf('\tFigure %d of %d... \n', figure_index, length(figure_handles))

        figure(figure_index);
        pause(0.5);
        figure_name = get (gcf, 'Name');
        if isempty(figure_name)
            figure_name = sprintf('Figure %d', figure_index);
        end

        % Save with current name
        saveAndExportFig(fullfile(fig_directory, figure_name), figure_outputs);
    end


end