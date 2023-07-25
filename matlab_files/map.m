% Original data ranging from 0 to 240*160
clear
newFolderPath = fullfile(pwd, 'output_txt');
original_data = 0:240*160;

% Specify the target range (0 to 255)
target_min = 0;
target_max = 255;

% Use mapminmax to scale the data to the target range
mapped_data = mapminmax(original_data, target_min, target_max);
mapped_data_c=mapped_data';
mapped_data_c_floor=floor(mapped_data_c)
filename = 'memory.mif';   % Replace this with your des
fid = fopen(filename, 'wt');
if fid == -1
    error('Failed to open the file for writing.');
end
% Write the MIF file header
fprintf(fid, 'DEPTH = %d;\n', numel(mapped_data_c_floor));
fprintf(fid, 'WIDTH = 8;\n');
fprintf(fid, 'ADDRESS_RADIX = HEX;\n');
fprintf(fid, 'DATA_RADIX = HEX;\n');
fprintf(fid, 'CONTENT\n');
fprintf(fid, 'BEGIN\n');
% Write each address and corresponding data to the MIF file
for i = 1:numel(mapped_data_c_floor)
    address = dec2hex(i - 1, ceil(log2(numel(mapped_data_c_floor))));
    fprintf(fid, '%s : %s;\n', address, mapped_data_c_floor(i, :));
end

% Write the MIF file footer
fprintf(fid, 'END;\n');

% Close the file
fclose(fid);

disp('MIF file generation completed.');

% Ensure that the data is in integer format
data = uint8(mapped_data_c_floor);

% Open the COE file for writing
filename = 'memory.coe';  % Replace this with your desired output COE file path
fid = fopen(filename, 'wt');
if fid == -1
    error('Failed to open the file for writing.');
end

% Write the COE file header
fprintf(fid, 'memory_initialization_radix=16;\n');
fprintf(fid, 'memory_initialization_vector=\n');

% Write each data element to the COE file
for i = 1:numel(data)
    fprintf(fid, '%02X', data(i));
    
    % Add a comma and newline after each data element (except the last one)
    if i < numel(data)
        fprintf(fid, ',\n');
    else
        fprintf(fid, ';\n');
    end
end


%fprintf(fid, '%s%s \n', hex_data);
disp('Text file write done');disp('');