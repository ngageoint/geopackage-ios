//
//  GPKGConstraint.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/16/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraint.h"
#import "GPKGSqlUtils.h"

NSString * const GPKG_CONSTRAINT = @"CONSTRAINT";

@implementation GPKGConstraint

-(instancetype) initWithType: (enum GPKGConstraintType) type{
    return [self initWithType:type andName:nil];
}

-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name{
    return [self initWithType:type andName:name andOrder:nil];
}

-(instancetype) initWithType: (enum GPKGConstraintType) type andOrder: (NSNumber *) order{
    return [self initWithType:type andName:nil andOrder:order];
}

-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name andOrder: (NSNumber *) order{
    self = [super self];
    if(self != nil){
        self.type = type;
        self.name = name;
        self.order = order;
    }
    return self;
}

-(NSString *) buildNameSql{
    NSString *sql = @"";
    if(self.name != nil){
        sql = [NSString stringWithFormat:@"%@ %@ ", GPKG_CONSTRAINT, [GPKGSqlUtils quoteWrapName:self.name]];
    }
    return sql;
}

-(NSString *) buildSql{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(int) sortOrder{
    return self.order != nil ? [self.order intValue] : INT_MAX;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGConstraint *constraint = [[[self class] allocWithZone:zone] init];
    constraint.name = _name;
    constraint.type = _type;
    return constraint;
}

@end
