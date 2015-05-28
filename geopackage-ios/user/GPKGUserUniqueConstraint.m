//
//  GPKGUserUniqueConstraint.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserUniqueConstraint.h"
#import "GPKGUtils.h"

@implementation GPKGUserUniqueConstraint

-(instancetype) init{
    return [super init];
}

-(instancetype) initWithColumns: (NSMutableArray *) columns{
    self = [super init];
    if(self != nil){
        self.columns = columns;
    }
    return self;
}

-(void) add: (GPKGUserColumn *)column{
    [GPKGUtils addObject:column toArray:self.columns];
}

@end
