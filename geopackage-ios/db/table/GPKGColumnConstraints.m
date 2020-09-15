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
        self.constraints = [[GPKGConstraints alloc] init];
    }
    return self;
}

-(void) addConstraint: (GPKGConstraint *) constraint{
    [self.constraints add:constraint];
}

-(void) addConstraintArray: (NSArray<GPKGConstraint *> *) constraints{
    [self.constraints addArray:constraints];
}

-(void) addConstraints: (GPKGConstraints *) constraints{
    [self.constraints addConstraints:constraints];
}

-(GPKGConstraint *) constraintAtIndex: (int) index{
    return [self.constraints atIndex:index];
}

-(int) numConstraints{
    return [self.constraints size];
}

-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints{
    if(self.constraints != nil){
        [self addConstraints:constraints.constraints];
    }
}

-(BOOL) hasConstraints{
    return [self.constraints has];
}

@end
