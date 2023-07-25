Abstract:
Histogram equalization is a widely-used technique in image processing that enhances contrast and improves visual quality. This paper presents an innovative approach to accelerate histogram equalization using Field-Programmable Gate Arrays (FPGAs). The proposed method involves calculating the histogram of an image in MATLAB, implementing histogram equalization in VHDL on an FPGA using the calculated histogram data, and then converting the processed data back to images using MATLAB. Additionally, the approach was extended to test its effectiveness on video data. The FPGA's parallel processing capabilities and high-speed data handling make it ideal for real-time processing and efficient handling of high-resolution images and videos. Experimental results demonstrate the effectiveness of FPGA-accelerated histogram equalization, achieving real-time processing and improved image and video quality even for high-resolution data. The proposed approach has potential applications in various fields, including medical imaging and surveillance.

Introduction:
Image histogram equalization is a widely-used technique in image processing to improve contrast and enhance visual quality. Traditional implementations on CPUs may suffer from slow processing times, especially for high-resolution images and videos, limiting real-time applications. To overcome this limitation, we propose a novel approach that utilizes FPGAs for parallel processing and high-speed data handling to accelerate histogram equalization.

Methodology:
2.1 Image Preprocessing in MATLAB:
We start by calculating the grayscale of an image in MATLAB. Each image is first converted to grayscale. The MATLAB-generated grayscale data is then used to create a text file, which will serve as the input for the FPGA implementation.

2.2 FPGA Implementation of Histogram Equalization:
In the VHDL design, the FPGA reads the image data from the text file and calculates the histogram data. After that, it performs histogram equalization using the calculated histogram data for each pixel in the image. The FPGA's parallel processing capabilities enable efficient processing of the entire image in real-time.

2.3 Video Data Processing:
The proposed approach was extended to handle video data. Multiple frames are processed in parallel by the FPGA, leveraging its high-speed data handling capabilities.

2.4 Writing Processed Data to Text File:
After processing the image and video data using FPGA-accelerated histogram equalization, the FPGA writes the processed data back to separate text files.

Results:
MATLAB reads the processed data from the text files and reconstructs the images and videos. The final results demonstrate the effectiveness of FPGA-accelerated histogram equalization, achieving real-time processing even for high-resolution images and videos, and significantly improving their quality compared to traditional CPU-based implementations.
![resim](https://github.com/mbatuhanorak/Implementing-Histogram-Equalization-on-Video-using-FPGA/assets/63021742/1aa60b48-1f86-4626-ac28-43f5a4463591)


Discussion:
The FPGA-based approach demonstrated superior performance in histogram equalization for both image and video data compared to traditional CPU-based methods. The parallel processing capabilities and high-speed data handling of FPGAs enable real-time processing of high-resolution images and videos, making it suitable for various applications, such as medical imaging and surveillance.

Conclusion:
The proposed novel approach of combining MATLAB and VHDL for image and video histogram equalization on an FPGA platform offers significant advantages in terms of real-time processing and enhanced quality. The results demonstrate the potential of FPGA-accelerated histogram equalization in various image and video processing applications, opening new avenues for efficient and high-performance data processing techniques.
