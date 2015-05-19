//
//  GPKGDataColumnConstraints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const DCC_TABLE_NAME;
extern NSString * const DCC_COLUMN_CONSTRAINT_NAME;
extern NSString * const DCC_COLUMN_CONSTRAINT_TYPE;
extern NSString * const DCC_COLUMN_VALUE;
extern NSString * const DCC_COLUMN_MIN;
extern NSString * const DCC_COLUMN_MIN_IS_INCLUSIVE;
extern NSString * const DCC_COLUMN_MAX;
extern NSString * const DCC_COLUMN_MAX_IS_INCLUSIVE;
extern NSString * const DCC_COLUMN_DESCRIPTION;

enum GPKGDataColumnConstraintType{
    RANGE,
    ENUM,
    GLOB
};

extern NSString * const DCCT_RANGE;
extern NSString * const DCCT_ENUM;
extern NSString * const DCCT_GLOB;

@interface GPKGDataColumnConstraints : NSObject

@property (nonatomic, strong) NSString *constraintName;
@property (nonatomic, strong) NSString *constraintType;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDecimalNumber *min;
@property (nonatomic, strong) NSNumber *minIsInclusive;
@property (nonatomic, strong) NSDecimalNumber *max;
@property (nonatomic, strong) NSNumber *maxIsInclusive;
@property (nonatomic, strong) NSString *theDescription;

-(enum GPKGDataColumnConstraintType) getDataColumnConstraintType;

-(void) setConstraintType:(NSString *)constraintType;

-(void) setDataColumnConstraintType: (enum GPKGDataColumnConstraintType) constraintType;

-(void) setValue:(NSString *)value;

-(void) setMin:(NSDecimalNumber *)min;

-(void) setMinIsInclusive:(NSNumber *)minIsInclusive;

-(void) setMax:(NSDecimalNumber *)max;

-(void) setMaxIsInclusive:(NSNumber *)maxIsInclusive;

@end
