#include<opencv2/opencv.hpp>

void Stereo(cv::Mat &frame, cv::Mat &img1, cv::Mat &img2) {
    cv::Mat frame1 = img1;
    cv::Mat frame2 = img2;
    cv::resize(frame1, img1, cv::Size(frame.cols/2, frame.rows));
    cv::resize(frame2, img2, cv::Size(frame.cols/2, frame.rows));
    
    for(int z = 0; z < frame.rows; ++z) {
        int x = 0;
        for(int i = frame.cols/2; i < frame.cols; ++i) {
            cv::Vec3b &pixel = frame.at<cv::Vec3b>(z, i);
            cv::Vec3b pix = img1.at<cv::Vec3b>(z, x);
            ++x;
            pixel = pix;
        }
        for(int i = 0; i < frame.cols/2; ++i) {
            cv::Vec3b &pixel = frame.at<cv::Vec3b>(z, i);
            cv::Vec3b pix = img2.at<cv::Vec3b>(z, i);
            pixel = pix;
        }
    }
}

int main(int argc, char **argv) {
    
    int cam1 = atoi(argv[1]);
    int cam2 = atoi(argv[2]);
    
    cv::namedWindow("Stereo");
    
    
    if(cam1 > 0 && cam2 > 0) {
        cv::VideoCapture cap[2];
        cap[0].open(cam1);
        cap[1].open(cam2);
        
        for(int i = 0; i < 2; ++i) {
            if(!cap[i].isOpened()) {
                std::cout << "couldn't open cam: " << i << "\n";
                exit(EXIT_FAILURE);
            }
            
            bool active = true;
            while(active) {
                cv::Mat img[2];
                cap[0].read(img[0]);
                cv::Mat screen = img[0].clone();
                cap[1].read(img[1]);
                Stereo(screen, img[0], img[1]);
                cv::imshow("Stereo",screen);
                int key = cv::waitKey(5);
                if(key == 27)
                    exit(0);
            }
        }
    }
    return 0;
}
