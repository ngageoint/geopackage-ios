//
//  GPKGFeatureIndexer.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureDao.h"
#import "GPKGProgress.h"

@interface GPKGFeatureIndexer : NSObject

@property (nonatomic, strong)  GPKGFeatureDao * featureDao;
@property (nonatomic, strong)  NSObject<GPKGProgress> * progress;

-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao;

-(int) index;

-(int) indexWithForce: (BOOL) force;

-(void) indexFeatureRow: (GPKGFeatureRow *) row;

-(BOOL) isIndexed;

@end
