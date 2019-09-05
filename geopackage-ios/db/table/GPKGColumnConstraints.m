//
//  GPKGColumnConstraints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGColumnConstraints.h"

@implementation GPKGColumnConstraints

-(instancetype) initWithName: (NSString *) name{
    self = [super init];
    if(self != nil){
        self.name = name;
        self.constraints = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) addConstraint: (GPKGConstraint *) constraint{
    [self.constraints addObject:constraint];
}

-(void) addConstraints: (NSArray<GPKGConstraint *> *) constraints{
    [self.constraints addObjectsFromArray:constraints];
}

-(GPKGConstraint *) constraintAtIndex: (int) index{
    return [self.constraints objectAtIndex:index];
}

-(int) numConstraints{
    return (int) self.constraints.count;
}

-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints{
    if(self.constraints != nil){
        [self addConstraints:constraints.constraints];
    }
}

-(BOOL) hasConstraints{
    return self.constraints.count > 0;
}

@end
