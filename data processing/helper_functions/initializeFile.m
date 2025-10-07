function filename = initializeFile()
    filename = input('Enter the CSV filename (without extension): ', 's');
    filename = [filename, '.csv'];
    % Write the initial header row
    writecell({'Settings:', '', ''}, filename, 'WriteMode', 'overwrite');
end
