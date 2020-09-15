//
//  GPKGRawConstraint.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGRawConstraint.h"
#import "GPKGConstraintParser.h"

@implementation GPKGRawConstraint

-(instancetype) initWithSql: (NSString *) sql{
    return [self initWithType:[GPKGConstraintParser typeForSQL:sql] andSql:sql];
}

-(instancetype) initWithType: (enum GPKGConstraintType) type andSql: (NSString *) sql{
    return [self initWithType:type andName:[GPKGConstraintParser nameForSQL:sql] andSql:sql];
}

-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name andSql: (NSString *) sql{
    return [self initWithType:type andName:name andOrder:nil andSql:sql];
}

-(instancetype) initWithOrder: (NSNumber *) order andSql: (NSString *) sql{
    return [self initWithType:[GPKGConstraintParser typeForSQL:sql] andOrder:order andSql:sql];
}

-(instancetype) initWithType: (enum GPKGConstraintType) type andOrder: (NSNumber *) order andSql: (NSString *) sql{
    return [self initWithType:type andName:nil andOrder:order andSql:sql];
}

-(instancetype) initWithType: (enum GPKGConstraintType) type andName: (NSString *) name andOrder: (NSNumber *) order andSql: (NSString *) sql{
    self = [super initWithType:type andName:name andOrder:order];
    if(self != nil){
        self.sql = sql;
    }
    return self;
}

-(void) setTypeFromSql: (NSString *) sql{
    [self setType:[GPKGConstraintParser typeForSQL:sql]];
}

-(void) setNameFromSql: (NSString *) sql{
    [self setName:[GPKGConstraintParser nameForSQL:sql]];
}

-(NSString *) buildSql{
    NSString *sql = self.sql;
    if(![[sql uppercaseString] hasPrefix:GPKG_CONSTRAINT]){
        sql = [NSString stringWithFormat:@"%@%@", [self buildNameSql], sql];
    }
    return sql;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGRawConstraint *constraint = [super mutableCopyWithZone:zone];
    constraint.sql = _sql;
    return constraint;
}

@end
