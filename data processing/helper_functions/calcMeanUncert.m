function [mean_value, standard_deviation, uncertainty] = ...
    calcMeanUncert (data_array, alpha_confidence)


    num_trials = length(data_array);

    % Compute t-factor using inverse CDF of student's t-distribution
    t_factor = tinv(1 - alpha_confidence/2, num_trials - 1);
    
    % Compute mean value and standard deviation
    mean_value = mean(data_array);
    standard_deviation = std(data_array);

    % Compute magnitude of uncertainty
    uncertainty = t_factor * standard_deviation / sqrt(num_trials);

end