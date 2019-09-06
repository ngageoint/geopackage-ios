//
//  GPKGTableConstraints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTableConstraints.h"

@interface GPKGTableConstraints()

/**
 * Table constraints
 */
@property (nonatomic, strong) NSMutableArray<GPKGConstraint *> *constraints;

/**
 * Column constraints
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGColumnConstraints *> *columnConstraints;

@end

@implementation GPKGTableConstraints

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.constraints = [[NSMutableArray alloc] init];
        self.columnConstraints = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) addTableConstraint: (GPKGConstraint *) constraint{
    [self.constraints addObject:constraint];
}

-(void) addTableConstraintsInArray: (NSArray<GPKGConstraint *> *) constraints{
    [self.constraints addObjectsFromArray:constraints];
}

-(NSArray<GPKGConstraint *> *) tableConstraints{
    return _constraints;
}

-(GPKGConstraint *) tableConstraintAtIndex: (int) index{
    return [self.constraints objectAtIndex:index];
}

-(int) numTableConstraints{
    return (int) self.constraints.count;
}

-(void) addColumnConstraint: (GPKGConstraint *) constraint forColumn: (NSString *) columnName{
    [[self getOrCreateColumnConstraints:columnName] addConstraint:constraint];
}

-(void) addColumnConstraintsInArray: (NSArray<GPKGConstraint *> *) constraints forColumn: (NSString *) columnName{
    [[self getOrCreateColumnConstraints:columnName] addConstraints:constraints];
}

-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints{
    [[self getOrCreateColumnConstraints:constraints.name] addColumnConstraints:constraints];
}

/**
 * Get or create the column constraints for the column name
 *
 * @param columnName
 *            column name
 * @return column constraints
 */
-(GPKGColumnConstraints *) getOrCreateColumnConstraints: (NSString *) columnName{
    GPKGColumnConstraints *constraints = [self.columnConstraints objectForKey:columnName];
    if(constraints == nil){
        constraints = [[GPKGColumnConstraints alloc] initWithName:columnName];
        [_columnConstraints setObject:constraints forKey:columnName];
    }
    return constraints;
}

-(void) addColumnConstraintsInDictionary: (NSDictionary<NSString *, GPKGColumnConstraints *> *) constraints{
    [self addColumnConstraintsInArray:[constraints allValues]];
}

-(void) addColumnConstraintsInArray: (NSArray<GPKGColumnConstraints *> *) constraints{
    for (GPKGColumnConstraints *columnConstraints in constraints) {
        [self addColumnConstraints:columnConstraints];
    }
}

-(NSDictionary<NSString *, GPKGColumnConstraints *> *) columnConstraints{
    return _columnConstraints;
}

-(NSArray<NSString *> *) columnsWithConstraints{
    return [self.columnConstraints allKeys];
}

-(GPKGColumnConstraints *) columnConstraintsForColumn: (NSString *) columnName{
    return [self.columnConstraints objectForKey:columnName];
}

-(GPKGConstraint *) columnConstraintForColumn: (NSString *) columnName atIndex: (int) index{
    GPKGConstraint *constraint = nil;
    GPKGColumnConstraints *columnConstraints = [self columnConstraintsForColumn:columnName];
    if (columnConstraints != nil) {
        constraint = [columnConstraints constraintAtIndex:index];
    }
    return constraint;
}

-(int) numConstraintsForColumn: (NSString *) columnName{
    int count = 0;
    GPKGColumnConstraints *columnConstraints = [self columnConstraintsForColumn:columnName];
    if (columnConstraints != nil) {
        count = [columnConstraints numConstraints];
    }
    return count;
}

-(void) addConstraints: (GPKGTableConstraints *) constraints{
    if (constraints != nil) {
        [self addTableConstraintsInArray:[constraints tableConstraints]];
        [self addColumnConstraintsInDictionary:[constraints columnConstraints]];
    }
}

-(BOOL) hasConstraints{
    return [self hasTableConstraints] || [self hasColumnConstraints];
}

-(BOOL) hasTableConstraints{
    return self.constraints.count > 0;
}

-(BOOL) hasColumnConstraints{
    return self.columnConstraints.count > 0;
}

-(BOOL) hasConstraintsForColumn: (NSString *) columnName{
    return [self numConstraintsForColumn:columnName] > 0;
}

@end
