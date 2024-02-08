//
//  GPKGDataColumnsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataColumnsDao.h"
#import "GPKGContentsDao.h"
#import "GPKGGeoPackageTableCreator.h"

@implementation GPKGDataColumnsDao

+(GPKGDataColumnsDao *) createWithDatabase: (GPKGConnection *) database{
    return [[GPKGDataColumnsDao alloc] initWithDatabase:database];
}

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_DC_TABLE_NAME;
        self.idColumns = @[GPKG_DC_COLUMN_PK1, GPKG_DC_COLUMN_PK2];
        self.columnNames = @[GPKG_DC_COLUMN_TABLE_NAME, GPKG_DC_COLUMN_COLUMN_NAME, GPKG_DC_COLUMN_NAME, GPKG_DC_COLUMN_TITLE, GPKG_DC_COLUMN_DESCRIPTION, GPKG_DC_COLUMN_MIME_TYPE, GPKG_DC_COLUMN_CONSTRAINT_NAME];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGDataColumns alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGDataColumns *setObject = (GPKGDataColumns*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.columnName = (NSString *) value;
            break;
        case 2:
            setObject.name = (NSString *) value;
            break;
        case 3:
            setObject.title = (NSString *) value;
            break;
        case 4:
            setObject.theDescription = (NSString *) value;
            break;
        case 5:
            setObject.mimeType = (NSString *) value;
            break;
        case 6:
            setObject.constraintName = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject *value = nil;
    
    GPKGDataColumns *columns = (GPKGDataColumns*) object;
    
    switch(columnIndex){
        case 0:
            value = columns.tableName;
            break;
        case 1:
            value = columns.columnName;
            break;
        case 2:
            value = columns.name;
            break;
        case 3:
            value = columns.title;
            break;
        case 4:
            value = columns.theDescription;
            break;
        case 5:
            value = columns.mimeType;
            break;
        case 6:
            value = columns.constraintName;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(PROJProjection *) projection: (NSObject *) object{
    GPKGDataColumns *projectionObject = (GPKGDataColumns*) object;
    GPKGContents *contents = [self contents:projectionObject];
    GPKGContentsDao *contentsDao = [self contentsDao];
    PROJProjection *projection = [contentsDao projection:contents];
    return projection;
}

-(GPKGContents *) contents: (GPKGDataColumns *) dataColumns{
    GPKGContentsDao *dao = [self contentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:dataColumns.tableName];
    return contents;
}

-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName{
    GPKGResultSet *results = [self queryForEqWithField:GPKG_DC_COLUMN_CONSTRAINT_NAME andValue:constraintName];
    return results;
}

-(GPKGContentsDao *) contentsDao{
    return [GPKGContentsDao createWithDatabase:self.database];
}

-(GPKGDataColumns *) dataColumnByTableName: tableName andColumnName: columnName {
    if (![self tableExists]) return nil;
    NSString *whereClause = [NSString stringWithFormat:@"%@ and %@",
                              [self buildWhereWithField:GPKG_DC_COLUMN_TABLE_NAME andValue:tableName],
                              [self buildWhereWithField:GPKG_DC_COLUMN_COLUMN_NAME andValue:columnName]];
    NSArray *values = [NSArray arrayWithObjects:tableName, columnName, nil];
                        
    return (GPKGDataColumns *)[self firstObject:[self queryWhere: whereClause andWhereArgs: values]];
}

-(GPKGResultSet *) queryByTable: (NSString *) tableName{
    return [self queryForEqWithField:GPKG_DC_COLUMN_TABLE_NAME andValue:tableName];
}

-(int) deleteByTableName: (NSString *) tableName{
    NSString *where = [self buildWhereWithField:GPKG_DC_COLUMN_TABLE_NAME andValue:tableName];
    NSArray *whereArgs = [self buildWhereArgsWithValue:tableName];
    return [self deleteWhere:where andWhereArgs:whereArgs];
}

-(int) deleteByTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    NSString *where = [NSString stringWithFormat:@"%@ and %@",
                              [self buildWhereWithField:GPKG_DC_COLUMN_TABLE_NAME andValue:tableName],
                              [self buildWhereWithField:GPKG_DC_COLUMN_COLUMN_NAME andValue:columnName]];
    NSArray *whereArgs = [NSArray arrayWithObjects:tableName, columnName, nil];
    return [self deleteWhere:where andWhereArgs:whereArgs];
}

-(void) saveSchemaWithTable: (GPKGUserTable *) table{
    [self saveSchemaWithColumns:[table userColumns]];
}

-(void) saveSchemaWithColumns: (GPKGUserColumns *) columns{
    [self saveSchemaWithTable:columns.tableName andColumns:[columns columns]];
}

-(void) saveSchemaWithTable: (NSString *) table andColumns: (NSArray<GPKGUserColumn *> *) columns{
    
    for(GPKGUserColumn *column in columns){
        [self saveSchemaWithTable:table andColumn:column];
    }
    
}

-(void) saveSchemaWithTable: (NSString *) table andColumn: (GPKGUserColumn *) column{
    
    NSString *columnName = column.name;
    
    GPKGDataColumns *schema = [column schema];
    GPKGDataColumns *existing = [self schemaByTable:table andColumn:columnName];
    
    if(schema != nil){
        [schema setTableName:table];
        [schema setColumnName:columnName];
        if(![self tableExists]){
            [[self tableCreator] createDataColumns];
        }
        [self createOrUpdate:schema];
    }else if(existing != nil){
        [self deleteByTableName:table andColumnName:columnName];
    }
    
}

-(void) loadSchemaWithTable: (GPKGUserTable *) table{
    [self loadSchemaWithColumns:[table userColumns]];
}

-(void) loadSchemaWithColumns: (GPKGUserColumns *) columns{
    [self loadSchemaWithTable:columns.tableName andColumns:[columns columns]];
}

-(void) loadSchemaWithTable: (NSString *) table andColumns: (NSArray<GPKGUserColumn *> *) columns{
    
    if([self tableExists]){
        
        for(GPKGUserColumn *column in columns){
            
            [self loadSchemaWithTable:table andColumn:column];
            
        }
        
    }
    
}

-(void) loadSchemaWithTable: (NSString *) table andColumn: (GPKGUserColumn *) column{
    
    [column setSchema:[self schemaByTable:table andColumn:column.name]];
    
}

-(GPKGDataColumns *) schemaByTable: table andColumn: column{
    
    GPKGDataColumns *schema = nil;
    
    if([self tableExists]){
        schema = [self dataColumnByTableName:table andColumnName:column];
    }
    
    return schema;
}

-(GPKGGeoPackageTableCreator *) tableCreator{
    return [[GPKGGeoPackageTableCreator alloc] initWithDatabase:self.database];
}

@end
