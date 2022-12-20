//
//  GPKGFeatureIndexTestEnvelope.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "SFGeometryEnvelope.h"

@interface GPKGFeatureIndexTestEnvelope : NSObject

/**
 * Envelope
 */
@property (nonatomic, strong) SFGeometryEnvelope *envelope;

/**
 * Integer full envelope coverage percentage
 */
@property (nonatomic) int percentage;

/**
 * Expected result count
 */
@property (nonatomic) int count;

@end
