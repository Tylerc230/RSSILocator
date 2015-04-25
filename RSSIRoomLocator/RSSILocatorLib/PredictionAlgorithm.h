//
//  PredictionAlgorithm.h
//  RSSIRoomLocator
//
//  Created by Tyler Casselman on 4/12/15.
//  Copyright (c) 2015 Casselman Consulting. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PredictionAlgorithm : NSObject
- (instancetype)initWithNumFeatures:(int)numFeatures filterSize:(int)filterSize;
- (void)train:(NSMutableData *)featureData labels:(NSMutableData *)labelData;
- (int)predict:(NSData *)features;
@end
