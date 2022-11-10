//
//  GPKGDgiwgValidationKey.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgValidationKey.h"

@implementation GPKGDgiwgValidationKey

-(instancetype) initWithColumn: (NSString *) column andValue: (NSString *) value{
    self = [super init];
    if(self != nil){
        self.column = column;
        self.value = value;
    }
    return self;
}

-(instancetype) initWithColumn: (NSString *) column andNumber: (NSNumber *) value{
    return [self initWithColumn:column andValue:[value stringValue]];
}

-(NSString *) description{
    NSMutableString *description = [NSMutableString alloc];
    [description appendString:@"Key Column: "];
    [description appendFormat:@"%@", self.column];
    [description appendString:@", Value: "];
    [description appendFormat:@"%@", self.value];
    return description;
}

@end
