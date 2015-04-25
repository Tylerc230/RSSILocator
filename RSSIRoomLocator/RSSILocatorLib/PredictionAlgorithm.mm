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
    Mat labels = Mat(rows, 1, CV_32F, labelData.mutableBytes);
    //todo filter
    cout << "labels: " << labels << endl;
    cout << "features: " << features << endl;
    self.SVM->train_auto(features, labels, Mat(), Mat(), params);
}

- (int)predict:(NSMutableData *)sampleData {
    Mat sampleMatrix = Mat(self.filterSize, self.numFeatures, CV_32F, sampleData.mutableBytes);
    cout << sampleMatrix << endl;
    return self.SVM->predict(sampleMatrix.row(self.filterSize - 1));
}

- (void)dealloc {
    if (self.SVM) {
        delete self.SVM;
    }
}
@end
