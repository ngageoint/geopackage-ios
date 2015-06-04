//
//  GPKGUserRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserRow.h"
#import <sqlite3.h>
#import "GPKGUtils.h"

@implementation GPKGUserRow

-(instancetype) initWithTable: (GPKGUserTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super init];
    if(self != nil){
        self.table = table;
        self.columnTypes = columnTypes;
        self.values = values;
    }
    return self;
}

-(instancetype) initWithTable: (GPKGUserTable *) table{
    self = [super init];
    if(self != nil){
        self.table = table;
        
        int columnCount = [self.table columnCount];
        NSMutableArray * tempColumnTypes = [[NSMutableArray alloc] initWithCapacity:columnCount];
        NSMutableArray * tempValues = [[NSMutableArray alloc] initWithCapacity:columnCount];
        for(int i = 0; i < columnCount; i++){
            [GPKGUtils addObject:[NSNumber numberWithInt:SQLITE_NULL] toArray:tempColumnTypes];
            [GPKGUtils addObject:nil toArray:tempValues];
        }
        
        self.columnTypes = tempColumnTypes;
        self.values = tempValues;
    }
    return self;
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(int) columnCount{
    return [self.table columnCount];
}

-(NSArray *) getColumnNames{
    return self.table.columnNames;
}

-(NSString *) getColumnNameWithIndex: (int) index{
    return [self.table getColumnNameWithIndex:index];
}

-(int) getColumnIndexWithColumnName: (NSString *) columnName{
    return [self.table getColumnIndexWithColumnName:columnName];
}

-(NSObject *) getValueWithIndex: (int) index{
    NSObject * value = [GPKGUtils objectAtIndex:index inArray:self.values];
    if(value != nil){
        value = [self toObjectValueWithIndex:index andValue:value];
    }
    return value;
}

-(NSObject *) getValueWithColumnName: (NSString *) columnName{
    return [self getValueWithIndex:[self.table getColumnIndexWithColumnName:columnName]];
}

-(NSObject *) getDatabaseValueWithIndex: (int) index{
    NSObject * value = [GPKGUtils objectAtIndex:index inArray:self.values];
    if(value != nil){
        value =[self toDatabaseValueWithIndex:index andValue:value];
    }
    return value;
}

-(NSObject *) getDatabaseValueWithColumnName: (NSString *) columnName{
    return [self getDatabaseValueWithIndex:[self.table getColumnIndexWithColumnName:columnName]];
}

-(int) getRowColumnTypeWithIndex: (int) index{
    return (int)[GPKGUtils objectAtIndex:index inArray:self.columnTypes];
}

-(int) getRowColumnTypeWithColumnName: (NSString *) columnName{
    return (int)[GPKGUtils objectAtIndex:[self.table getColumnIndexWithColumnName:columnName] inArray:self.columnTypes];
}

-(GPKGUserColumn *) getColumnWithIndex: (int) index{
    return [self.table getColumnWithIndex:index];
}

-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName{
    return [self.table getColumnWithColumnName:columnName];
}

-(NSNumber *) getId{
    
    NSNumber * id = nil;
    NSObject * objectValue = [self getValueWithIndex:[self getPkColumnIndex]];
    if(objectValue == nil){
        [NSException raise:@"Null Id" format:@"Row Id was null. Table: %@, Column Index: %d, Column Name: %@", self.table.tableName, [self getPkColumnIndex], [self getPkColumn].name];
    }
    if([objectValue isKindOfClass:[NSNumber class]]){
        id = (NSNumber *) objectValue;
    }else{
        [NSException raise:@"Non Number Id" format:@"Row Id was not a number. Table: %@, Column Index: %d, Column Name: %@", self.table.tableName, [self getPkColumnIndex], [self getPkColumn].name];
    }
    return id;
}

-(int) getPkColumnIndex{
    return self.table.pkIndex;
}

-(GPKGUserColumn *) getPkColumn{
    return [self.table getPkColumn];
}

-(void) setValueWithIndex: (int) index andValue: (NSObject *) value{
    if(index == self.table.pkIndex){
        [NSException raise:@"Primary Key Update" format:@"Can not update the primary key of the row. Table Name: %@, Index: %d, Name: %@", self.table.tableName, index, [self.table getPkColumn].name];
    }
    [self setValueNoValidationWithIndex:index andValue:value];
}

-(void) setValueNoValidationWithIndex: (int) index andValue: (NSObject *) value{
    [GPKGUtils replaceObjectAtIndex:index withObject:value inArray:self.values];
}

-(void) setValueWithColumnName: (NSString *) columnName andValue: (NSObject *) value{
    [self setValueWithIndex:[self getColumnIndexWithColumnName:columnName] andValue:value];
}

-(void) setId: (NSNumber *) id{
    [GPKGUtils replaceObjectAtIndex:[self getPkColumnIndex] withObject:id inArray:self.values];
}

-(void) resetId{
    [GPKGUtils replaceObjectAtIndex:[self getPkColumnIndex] withObject:nil inArray:self.values];
}

-(void) validateValueWithColumn: (GPKGUserColumn *) column andValue: (NSObject *) value andValueTypes: (NSArray *) valueTypes{
    
    enum GPKGDataType dataType = column.dataType;
    Class dataTypeClass = [GPKGDataTypes classType:dataType];
    
    BOOL valid = false;
    for(Class valueType in valueTypes){
        if(valueType == dataTypeClass){
            valid = true;
            break;
        }
    }
    
    if(!valid){
        [NSException raise:@"Illegal Value" format:@"Column: %@, Value: %@, Expected Type: %@, Actual Type: %@", column.name, value, [dataTypeClass description], [[[GPKGUtils objectAtIndex:0 inArray:valueTypes] class] description]];
    }
}

@end
