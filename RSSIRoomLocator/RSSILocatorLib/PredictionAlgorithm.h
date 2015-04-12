//
//  PredictionAlgorithm.h
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/12/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PredictionAlgorithm : NSObject
- (void)train:(NSData *)rawTrainingData numFeatures:(int)numFeatures filterSize:(int)filterSize;
@end
