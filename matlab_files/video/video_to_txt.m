% Replace 'your_video_file.mp4' with the path to your video file
videoFile = 'my_video.mp4';
videoObj = VideoReader(videoFile);
numFrames = videoObj.NumFrames;
frameRate = videoObj.FrameRate;
videoWidth = videoObj.Width;
videoHeight = videoObj.Height;

newWidth = 240;
newHeight = 160;
grayFrames = cell(numFrames, 1);

for i = 1:numFrames
    % Read the current frame
    frame = read(videoObj, i);
    
    % Convert to grayscale
    grayFrame = rgb2gray(frame);
    
    % Resize the frame
    resizedFrame = imresize(grayFrame, [newHeight, newWidth]);
    
    % Store the resized frame in the cell array
    grayFrames{i} = resizedFrame;
end
outputDirectory = 'output_txt_files';
if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end

for i = 1:numFrames
    % Generate a filename for the current frame
    fileName = fullfile(outputDirectory, sprintf('frame_%04d.txt', i));
    
    % Save the frame as a text file
    dlmwrite(fileName, grayFrames{i}, ' ');
end
disp('Text file write done');disp('');