//
//  GPKGColumnValue.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGColumnValue.h"

@implementation GPKGColumnValue

-(instancetype) initWithValue: (NSObject *) value{
    return [self initWithValue:value andTolerance:nil];
}

-(instancetype) initWithValue: (NSObject *) value andTolerance: (NSNumber *) tolerance{
    self = [super init];
    if(self != nil){
        self.value = value;
        self.tolerance = tolerance;
    }
    return self;
}

@end
