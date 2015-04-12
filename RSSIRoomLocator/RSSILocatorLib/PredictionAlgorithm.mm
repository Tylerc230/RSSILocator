//
//  PredictionAlgorithm.m
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/12/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

#import "PredictionAlgorithm.h"
#import <opencv2/opencv.hpp>
#import <ios>

using namespace cv;
using namespace std;
@interface PredictionAlgorithm ()
@property (nonatomic, assign) CvSVM *SVM;
@end

@implementation PredictionAlgorithm
- (void)train:(NSData *)rawTrainingData numFeatures:(int)numFeatures filterSize:(int)filterSize{
    self.SVM = new CvSVM;
    CvSVMParams params;
    params.svm_type = CvSVM::C_SVC;
    params.kernel_type = CvSVM::RBF;
    params.term_crit = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    int columns = numFeatures + 1;
    int rows = (int)(rawTrainingData.length/sizeof(float)) / columns;
    Mat rawTrainingMatrix = Mat(rows, columns, CV_32F, (void *)rawTrainingData.bytes);
    Range labelColumn = cv::Range(0, 1);
    //todo filter
    Range featureColumns = cv::Range(1, columns);
    Mat labels = Mat(rawTrainingMatrix, cv::Range::all(), labelColumn);
    Mat features = Mat(rawTrainingMatrix, cv::Range::all(), featureColumns);
//    cout << "labels: " << labels << endl;
//    cout << "features: " << features << endl;
    self.SVM->train_auto(features, labels, Mat(), Mat(), params);
}

- (void)dealloc {
    if (self.SVM) {
        delete self.SVM;
    }
}
@end
