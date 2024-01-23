//
//  GPKGColumnRange.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/22/24.
//  Copyright © 2024 NGA. All rights reserved.
//

#import "GPKGColumnRange.h"

@implementation GPKGColumnRange

-(instancetype) initWithMin: (NSNumber *) min andMax: (NSNumber *) max{
    return [self initWithMin:min andMax:max andTolerance:nil];
}

-(instancetype) initWithMin: (NSNumber *) min andMax: (NSNumber *) max andTolerance: (NSNumber *) tolerance{
    self = [super init];
    if(self != nil){
        self.min = min;
        self.max = max;
        self.tolerance = tolerance;
    }
    return self;
}

@end
