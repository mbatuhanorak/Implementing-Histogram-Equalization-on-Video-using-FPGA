clear
newFolderPath = fullfile(pwd, 'output_txt');
% Input values
input_min = 0;
input_max = 240 * 160;
output_min = 0;
output_max = 255;

% Mapping the values
input_values = 0:1:input_max;
output_values = (input_values - input_min) * (output_max - output_min) / (input_max - input_min) + output_min;
output_rom=round(output_values);
output_rom_c=output_rom';
fid = fopen('output_txt/rom.txt', 'wt');
fprintf(fid, '%d\n', output_rom_c);
disp('Text file write done');disp('');
% Displaying the results
disp('Input Values (input_values):');
disp(input_values);
disp('Output Values (output_values):');
disp(output_values);
