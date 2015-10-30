//
//  GPKGExtensionsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGExtensionsDao.h"
#import "GPKGUtils.h"

@implementation GPKGExtensionsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_EX_TABLE_NAME;
        self.idColumns = @[GPKG_EX_COLUMN_TABLE_NAME, GPKG_EX_COLUMN_COLUMN_NAME, GPKG_EX_COLUMN_EXTENSION_NAME];
        self.columns = @[GPKG_EX_COLUMN_TABLE_NAME, GPKG_EX_COLUMN_COLUMN_NAME, GPKG_EX_COLUMN_EXTENSION_NAME, GPKG_EX_COLUMN_DEFINITION, GPKG_EX_COLUMN_SCOPE];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGExtensions alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGExtensions *setObject = (GPKGExtensions*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.columnName = (NSString *) value;
            break;
        case 2:
            setObject.extensionName = (NSString *) value;
            break;
        case 3:
            setObject.definition = (NSString *) value;
            break;
        case 4:
            setObject.scope = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGExtensions *getObject = (GPKGExtensions*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.columnName;
            break;
        case 2:
            value = getObject.extensionName;
            break;
        case 3:
            value = getObject.definition;
            break;
        case 4:
            value = getObject.scope;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(int) deleteByExtension: (NSString *) extensionName{
    NSString * where = [self buildWhereWithField:GPKG_EX_COLUMN_EXTENSION_NAME andValue:extensionName];
    NSArray * whereArgs = [self buildWhereArgsWithValue:extensionName];
    int count = [self deleteWhere:where andWhereArgs:whereArgs];
    return count;
}

-(int) deleteByExtension: (NSString *) extensionName andTable: (NSString *) tableName{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_EX_COLUMN_EXTENSION_NAME withValue:extensionName];
    [values addColumn:GPKG_EX_COLUMN_TABLE_NAME withValue:tableName];
    
    NSString * where = [self buildWhereWithFields:values];
    NSArray * whereArgs = [self buildWhereArgsWithValues:values];
    int count = [self deleteWhere:where andWhereArgs:whereArgs];
    return count;
}

-(int) deleteByExtension: (NSString *) extensionName andTable: (NSString *) tableName andColumnName: (NSString *) columnName{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_EX_COLUMN_EXTENSION_NAME withValue:extensionName];
    [values addColumn:GPKG_EX_COLUMN_TABLE_NAME withValue:tableName];
    [values addColumn:GPKG_EX_COLUMN_COLUMN_NAME withValue:columnName];
    
    NSString * where = [self buildWhereWithFields:values];
    NSArray * whereArgs = [self buildWhereArgsWithValues:values];
    int count = [self deleteWhere:where andWhereArgs:whereArgs];
    return count;
}

-(GPKGResultSet *) queryByExtension: (NSString *) extensionName{
    return [self queryForEqWithField:GPKG_EX_COLUMN_EXTENSION_NAME andValue:extensionName];
}

-(int) countByExtension: (NSString *) extensionName{
    GPKGResultSet * extensions = [self queryByExtension:extensionName];
    int count = extensions.count;
    [extensions close];
    return count;
}

-(GPKGResultSet *) queryByExtension: (NSString *) extensionName andTable: (NSString *) tableName{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_EX_COLUMN_EXTENSION_NAME withValue:extensionName];
    [values addColumn:GPKG_EX_COLUMN_TABLE_NAME withValue:tableName];
    
    return [self queryForFieldValues:values];
}

-(int) countByExtension: (NSString *) extensionName andTable: (NSString *) tableName{
    GPKGResultSet * extensions = [self queryByExtension:extensionName andTable:tableName];
    int count = extensions.count;
    [extensions close];
    return count;
}

-(GPKGExtensions *) queryByExtension: (NSString *) extensionName andTable: (NSString *) tableName andColumnName: (NSString *) columnName{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_EX_COLUMN_EXTENSION_NAME withValue:extensionName];
    [values addColumn:GPKG_EX_COLUMN_TABLE_NAME withValue:tableName];
    [values addColumn:GPKG_EX_COLUMN_COLUMN_NAME withValue:columnName];
    
    GPKGResultSet * extensions = [self queryForFieldValues:values];
    
    GPKGExtensions * extension = nil;
    if(extensions.count > 1){
        [NSException raise:@"Too Many Results" format:@"More than one Extenion existed for unique combination of Extension Name: %@, Table Name: %@, Column Name: %@", extensionName, tableName, columnName];
    } else if([extensions moveToNext]){
        extension = (GPKGExtensions *)[self getObject:extensions];
    }
    
    [extensions close];
    
    return extension;
}

@end
