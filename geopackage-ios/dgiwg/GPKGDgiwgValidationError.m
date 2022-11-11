//
//  GPKGDgiwgValidationError.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgValidationError.h"

@implementation GPKGDgiwgValidationError

-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement{
    self = [self initWithTable:table andValue:value andConstraint:constraint andRequirement:requirement];
    if(self != nil){
        _column = column;
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement{
    return [self initWithTable:table andColumn:column andValue:value != nil ? [value stringValue] : nil andConstraint:constraint andRequirement:requirement];
}

-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraintValue: (NSNumber *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement{
    return [self initWithTable:table andColumn:column andNumber:value andConstraint:constraint != nil ? [constraint stringValue] : nil andRequirement:requirement];
}

-(instancetype) initWithTable: (NSString *) table andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement{
    self = [self initWithValue:value andConstraint:constraint andRequirement:requirement];
    if(self != nil){
        _table = table;
    }
    return self;
}

-(instancetype) initWithValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement{
    self = [self initWithConstraint:constraint andRequirement:requirement];
    if(self != nil){
        _value = value;
    }
    return self;
}

-(instancetype) initWithConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement{
    self = [super init];
    if(self != nil){
        _constraint = constraint;
        _requirement = requirement;
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) table andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys{
    return [self initWithTable:table andColumn:nil andValue:value andConstraint:constraint andRequirement:requirement andKeys:primaryKeys];
}

-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys{
    self = [self initWithTable:table andColumn:column andValue:value andConstraint:constraint andRequirement:requirement];
    if(self != nil){
        _primaryKeys = primaryKeys;
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys{
    return [self initWithTable:table andColumn:column andValue:value != nil ? [value stringValue] : nil andConstraint:constraint andRequirement:requirement andKeys:primaryKeys];
}

-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraintValue: (NSNumber *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys{
    return [self initWithTable:table andColumn:column andNumber:value andConstraint:constraint != nil ? [constraint stringValue] : nil andRequirement:requirement andKeys:primaryKeys];
}

-(NSString *) description{
    NSMutableString *description = [NSMutableString alloc];
    if(self.table != nil){
        [description appendFormat:@"Table: %@", self.table];
    }
    if(self.column != nil){
        if(description.length > 0){
            [description appendString:@", "];
        }
        [description appendFormat:@"Column: %@", self.column];
    }
    if(self.value != nil){
        if(description.length > 0){
            [description appendString:@", "];
        }
        [description appendFormat:@"Value: %@", self.value];
    }
    if(self.primaryKeys != nil){
        for(GPKGDgiwgValidationKey *key in self.primaryKeys){
            if([key.column caseInsensitiveCompare:self.column] != NSOrderedSame){
                if(description.length > 0){
                    [description appendString:@", "];
                }
                [description appendFormat:@"%@", key];
            }
        }
    }
    if(self.constraint != nil){
        if(description.length > 0){
            [description appendString:@", "];
        }
        [description appendFormat:@"Constraint: %@", self.constraint];
    }
    if(self.requirement != -1){
        if(description.length > 0){
            [description appendString:@", "];
        }
        [description appendFormat:@"Requirement: [%@]", [GPKGDgiwgRequirements description:self.requirement]];
    }
    return description;
}

@end
