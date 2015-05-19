//
//  GPKGDataColumnConstraints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataColumnConstraints.h"

NSString * const DCC_TABLE_NAME = @"gpkg_data_column_constraints";
NSString * const DCC_COLUMN_CONSTRAINT_NAME = @"constraint_name";
NSString * const DCC_COLUMN_CONSTRAINT_TYPE = @"constraint_type";
NSString * const DCC_COLUMN_VALUE = @"value";
NSString * const DCC_COLUMN_MIN = @"min";
NSString * const DCC_COLUMN_MIN_IS_INCLUSIVE = @"minIsInclusive";
NSString * const DCC_COLUMN_MAX = @"max";
NSString * const DCC_COLUMN_MAX_IS_INCLUSIVE = @"maxIsInclusive";
NSString * const DCC_COLUMN_DESCRIPTION = @"description";

@implementation GPKGDataColumnConstraints

-(enum GPKGDataColumnConstraintType) getDataColumnConstraintType{
    enum GPKGDataColumnConstraintType value = -1;
    
    if(self.constraintType != nil){
        NSDictionary *constraintTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithInteger:RANGE], @"range",
                                   [NSNumber numberWithInteger:ENUM], @"enum",
                                   [NSNumber numberWithInteger:GLOB], @"glob",
                                   nil
                                   ];
        NSNumber *enumValue = [constraintTypes objectForKey:self.constraintType];
        value = (enum GPKGDataColumnConstraintType)[enumValue intValue];
    }
    
    return value;
}

-(void) setConstraintType:(NSString *)constraintType{
    _constraintType = constraintType;
    enum GPKGDataColumnConstraintType type = [self getDataColumnConstraintType];
    [self setDataColumnConstraintType:type];
}

-(void) setDataColumnConstraintType: (enum GPKGDataColumnConstraintType) constraintType{
    switch(constraintType){
        case RANGE:
            self.constraintType = @"range";
            break;
        case ENUM:
            self.constraintType = @"enum";
            break;
        case GLOB:
            self.constraintType = @"glob";
            break;
    }
    switch(constraintType){
        case RANGE:
            self.value = nil;
            break;
        case ENUM:
        case GLOB:
            self.min = nil;
            self.max = nil;
            self.minIsInclusive = nil;
            self.maxIsInclusive = nil;
            break;
    }
}

-(void) setValue:(NSString *)value{
    if(self.constraintType != nil && value != nil && [self getDataColumnConstraintType] == RANGE){
        [NSException raise:@"Illegal State" format:@"The value must be null for range constraints"];
    }
    _value = value;
}

-(void) setMin:(NSDecimalNumber *)min{
    [self validateRangeValueWithColumn:DCC_COLUMN_MIN andValue:min];
    _min = min;
}

-(void) setMinIsInclusive:(NSNumber *)minIsInclusive{
    [self validateRangeValueWithColumn:DCC_COLUMN_MIN_IS_INCLUSIVE andValue:minIsInclusive];
    _minIsInclusive = minIsInclusive;
}

-(void) setMax:(NSDecimalNumber *)max{
    [self validateRangeValueWithColumn:DCC_COLUMN_MAX andValue:max];
    _max = max;
}

-(void) setMaxIsInclusive:(NSNumber *)maxIsInclusive{
    [self validateRangeValueWithColumn:DCC_COLUMN_MAX_IS_INCLUSIVE andValue:maxIsInclusive];
    _maxIsInclusive = maxIsInclusive;
}

-(void) validateRangeValueWithColumn: (NSString *) column andValue: (NSObject *) value{
    if(self.constraintType != nil && value != nil && [self getDataColumnConstraintType] != RANGE){
        [NSException raise:@"Illegal State" format:@"The %@ must be null for enum and glob constraints", column];
    }
}

@end
