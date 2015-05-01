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
@property (nonatomic, assign) int numFeatures;
@property (nonatomic, assign) int filterSize;
@end

@implementation PredictionAlgorithm
- (instancetype)initWithNumFeatures:(int)numFeatures filterSize:(int)filterSize{
    if (self = [super init]) {
        self.numFeatures = numFeatures;
        self.filterSize = filterSize;
    }
    return self;
}
- (void)train:(NSMutableData *)featureData labels:(NSMutableData *)labelData {
    self.SVM = new CvSVM;
    CvSVMParams params;
    params.svm_type = CvSVM::C_SVC;
    params.kernel_type = CvSVM::RBF;
    params.term_crit = cvTermCriteria(CV_TERMCRIT_ITER, 100, 1e-6);
    
    int rows = (int)(featureData.length/sizeof(float)) / self.numFeatures;
    Mat features = Mat(rows, self.numFeatures, CV_32F, featureData.mutableBytes);
    Mat filteredFeatures = [self filterMatrix:features];
    Mat labels = Mat(rows, 1, CV_32F, labelData.mutableBytes);
    //todo filter
    cout << "labels: " << labels << endl;
    cout << "features: " << features << endl;
    cout << "filtered features " << filteredFeatures << endl;
    self.SVM->train_auto(filteredFeatures, labels, Mat(), Mat(), params);
}

- (int)predict:(NSMutableData *)sampleData {
    Mat sampleMatrix = Mat(self.filterSize, self.numFeatures, CV_32F, sampleData.mutableBytes);
    cout << sampleMatrix << endl;
    return self.SVM->predict(sampleMatrix.row(self.filterSize - 1));
}

- (Mat)filterMatrix:(Mat)featureMatrix {
    static Mat filter_kernal = Mat::ones(self.filterSize, 1, CV_32F)/self.filterSize;
    Mat output = Mat(featureMatrix.size(), CV_32F);
    filter2D(featureMatrix, output, -1, filter_kernal, cv::Point(0, self.filterSize - 1), 0, BORDER_REPLICATE);
    return output;
}

- (void)dealloc {
    if (self.SVM) {
        delete self.SVM;
    }
}
@end
