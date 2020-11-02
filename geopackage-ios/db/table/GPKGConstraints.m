//
//  GPKGConstraints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGConstraints.h"

@interface GPKGConstraints()

/**
 * Constraints
 */
@property (nonatomic, strong) NSMutableArray<GPKGConstraint *> *constraints;

/**
 * Type Constraints
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<GPKGConstraint *> *> *typedContraints;

@end

@implementation GPKGConstraints

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.constraints = [NSMutableArray array];
        self.typedContraints = [NSMutableDictionary dictionary];
    }
    return self;
}

-(instancetype) initWithConstraints: (GPKGConstraints *) constraints{
    self = [self init];
    if(self != nil){
        for(GPKGConstraint *constraint in constraints.constraints){
            [self add:[constraint mutableCopy]];
        }
    }
    return self;
}

-(void) add: (GPKGConstraint *) constraint{
    
    NSUInteger insertLocation = [_constraints indexOfObject:constraint inSortedRange:NSMakeRange(0, _constraints.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(GPKGConstraint *constraint1, GPKGConstraint *constraint2){
        return [constraint1 sortOrder] - [constraint2 sortOrder] <= 0 ? NSOrderedAscending : NSOrderedDescending;
    }];
    [_constraints insertObject:constraint atIndex:insertLocation];
    
    NSNumber *typeNumber = [NSNumber numberWithInteger:constraint.type];
    NSMutableArray<GPKGConstraint *> *typeConstraints = [_typedContraints objectForKey:typeNumber];
    if(typeConstraints == nil){
        typeConstraints = [NSMutableArray array];
        [_typedContraints setObject:typeConstraints forKey:typeNumber];
    }
    [typeConstraints addObject:constraint];
}

-(void) addArray: (NSArray<GPKGConstraint *> *) constraints{
    for(GPKGConstraint *constraint in constraints){
        [self add:constraint];
    }
}

-(void) addConstraints: (GPKGConstraints *) constraints{
    [self addArray:[constraints all]];
}

-(BOOL) has{
    return [self size] > 0;
}

-(BOOL) hasType: (enum GPKGConstraintType) type{
    return [self sizeOfType:type] > 0;
}

-(int) size{
    return (int) _constraints.count;
}

-(int) sizeOfType: (enum GPKGConstraintType) type{
    return (int)[self ofType:type].count;
}

-(NSArray<GPKGConstraint *> *) all{
    return _constraints;
}

-(GPKGConstraint *) atIndex: (int) index{
    return (GPKGConstraint *)[_constraints objectAtIndex:index];
}

-(NSArray<GPKGConstraint *> *) ofType: (enum GPKGConstraintType) type{
    NSArray<GPKGConstraint *> *constraints = [_typedContraints objectForKey:[NSNumber numberWithInteger:type]];
    if(constraints == nil){
        constraints = [NSArray array];
    }
    return constraints;
}

-(NSArray<GPKGConstraint *> *) clear{
    NSArray<GPKGConstraint *> *constraintsCopy = [NSArray arrayWithArray:_constraints];
    [_constraints removeAllObjects];
    [_typedContraints removeAllObjects];
    return constraintsCopy;
}

-(NSArray<GPKGConstraint *> *) clearType: (enum GPKGConstraintType) type{
    NSNumber *typeNumber = [NSNumber numberWithInteger:type];
    NSArray<GPKGConstraint *> *typedConstraints = [_typedContraints objectForKey:typeNumber];
    if(typedConstraints == nil){
        typedConstraints = [NSArray array];
    }else if(typedConstraints.count > 0){
        [_typedContraints removeObjectForKey:typeNumber];
        NSMutableArray<GPKGConstraint *> *removeConstraints = [NSMutableArray array];
        for(GPKGConstraint *constraint in _constraints){
            if(constraint.type == type){
                [removeConstraints addObject:constraint];
            }
        }
        [_constraints removeObjectsInArray:removeConstraints];
    }
    return typedConstraints;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    return [[GPKGConstraints alloc] initWithConstraints:self];
}

@end
