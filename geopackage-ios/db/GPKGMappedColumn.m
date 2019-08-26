//
//  GPKGMappedColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/22/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGMappedColumn.h"
#import "GPKGSqlUtils.h"

@implementation GPKGMappedColumn

-(instancetype) initWithToColumn: (NSString *) toColumn{
    self = [super init];
    if(self != nil){
        self.toColumn = toColumn;
    }
    return self;
}

-(instancetype) initWithToColumn: (NSString *) toColumn andFromColumn: (NSString *) fromColumn{
    self = [self initWithToColumn:toColumn];
    if(self != nil){
        self.fromColumn = fromColumn;
    }
    return self;
}

-(instancetype) initWithToColumn: (NSString *) toColumn andFromColumn: (NSString *) fromColumn andDefaultValue: (NSObject *) defaultValue andDataType: (enum GPKGDataType) dataType{
    self = [self initWithToColumn:toColumn andFromColumn:fromColumn];
    if(self != nil){
        self.defaultValue = defaultValue;
        self.dataType = dataType;
    }
    return self;
}

-(instancetype) initWithToColumn: (NSString *) toColumn andDefaultValue: (NSObject *) defaultValue andDataType: (enum GPKGDataType) dataType{
    return [self initWithToColumn:toColumn andFromColumn:nil andDefaultValue:defaultValue andDataType:dataType];
}

-(instancetype) initWithUserColumn: (GPKGUserColumn *) column{
    return [self initWithToColumn:column.name andDefaultValue:column.defaultValue andDataType:column.dataType];
}

-(instancetype) initWithTableColumn: (GPKGTableColumn *) column{
    return [self initWithToColumn:column.name andDefaultValue:column.defaultValue andDataType:column.dataType];
}

-(BOOL) hasNewName{
    return self.fromColumn != nil && ![self.fromColumn isEqualToString:self.toColumn];
}

-(NSString *) fromColumn{
    NSString *column = _fromColumn;
    if(column == nil){
        column = _toColumn;
    }
    return column;
}

-(BOOL) hasDefaultValue{
    return self.defaultValue != nil;
}

-(NSString *) defaultValueAsString{
    return [GPKGSqlUtils columnDefaultValue:self.defaultValue withType:self.dataType];
}

-(BOOL) hasConstantValue{
    return self.constantValue != nil;
}

-(NSString *) constantValueAsString{
    return [GPKGSqlUtils columnDefaultValue:self.constantValue withType:self.dataType];
}

-(BOOL) hasWhereValue{
    return self.whereValue != nil;
}

-(NSString *) whereValueAsString{
    return [GPKGSqlUtils columnDefaultValue:self.whereValue withType:self.dataType];
}

-(void) setWhereValue: (NSObject *) whereValue withOperator: (NSString *) whereOperator{
    [self setWhereValue:whereValue];
    [self setWhereOperator:whereOperator];
}

-(NSString *) whereOperator{
    return _whereOperator != nil ? _whereOperator : @"=";
}

@end
