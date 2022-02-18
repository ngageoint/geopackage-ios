//
//  GPKGUserDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGUserRow.h"
#import "PROJProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGSqlUtils.h"
#import "GPKGAlterTable.h"

@implementation GPKGUserDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserTable *) table{
    self = [super initWithDatabase:database];
    if(self != nil){
        _table = table;
        self.tableName = [table tableName];
        GPKGUserColumn *pkColumn = [table pkColumn];
        if(pkColumn != nil){
            self.idColumns = @[pkColumn.name];
        }else{
            self.idColumns = @[];
        }
        self.autoIncrementId = YES;
        self.columnNames = [table columnNames];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGUserRow alloc] init];
}

-(NSString *) idColumnName{
    return [_table pkColumnName];
}

-(NSObject *) queryForIdObject: (NSObject *) idValue{
    return [self queryWithColumns:self.columnNames forIdObject:idValue];
}

-(NSObject *) queryWithColumns: (NSArray<NSString *> *) columns forIdObject: (NSObject *) idValue{
    NSObject *objectResult = nil;
    GPKGResultSet *results = [self queryWithColumns:columns forId:idValue];
    @try{
        if([results moveToNext]){
            objectResult = [self row:results];
        }
    }@finally{
        [results close];
    }
    return objectResult;
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGUserRow *setObject = (GPKGUserRow*) object;
    [setObject setValueNoValidationWithIndex:columnIndex andValue:value];
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    GPKGUserRow *row = (GPKGUserRow*) object;
    NSObject *value = [row databaseValueWithIndex:columnIndex];

    return value;
}

-(PROJProjection *) projection: (NSObject *) object{
    return _projection;
}

-(GPKGContentValues *) contentValuesWithObject: (NSObject *) object andIncludeNils: (BOOL) includeNils{
    
    GPKGContentValues *values = [[GPKGContentValues alloc] init];
    
    for(GPKGUserColumn *column in [self columns]){
        
        NSObject *value = [self valueFromObject:object withColumnIndex:column.index];
        
        if(!column.primaryKey || (value != nil && [_table isPkModifiable])){
            
            NSString *columnName = column.name;
            
            if(includeNils || value != nil){
                [values putKey:columnName withValue:value];
            }
            
        }
        
    }
    
    return values;
}

-(BOOL) hasPkColumn{
    return [_table hasPkColumn];
}

-(int) pkIndex{
    return [_table pkIndex];
}

-(GPKGUserColumn *) pkColumn{
    return [_table pkColumn];
}

-(NSString *) pkColumnName{
    return [_table pkColumnName];
}

-(NSArray<GPKGUserColumn *> *) columns{
    return [_table columns];
}

-(NSArray<NSString *> *) columnNames{
    return [_table columnNames];
}

-(int) columnCount{
    return [_table columnCount];
}

-(NSArray<NSString *> *) idColumns{
    NSMutableArray<NSString *> *columns = [NSMutableArray array];
    NSString *idColumn = [_table pkColumnName];
    if(idColumn != nil){
        [columns addObject:idColumn];
    }
    return columns;
}

-(GPKGUserRow *) row: (GPKGResultSet *) results{
    
    GPKGUserRow *row = nil;
    
    if(_table != nil){
        
        if(results.columns == nil){
            [results setColumnsFromTable:_table];
        }
        
        NSUInteger columns = [results.columnNames count];
        
        NSMutableArray *values = [NSMutableArray arrayWithCapacity:columns];
        
        [results rowPopulateValues:values];
        
        row = [self newRowWithColumns:results.columns andValues:values];
    }
    
    return row;
}

-(GPKGUserRow *) rowWithRow: (GPKGRow *) row{
    
    GPKGUserRow *userRow = nil;
    
    if(_table != nil){

        NSArray<NSString *> *columnNames = row.columns;
        
        GPKGUserColumns *columns = nil;
        if(columnNames == nil || [[_table columnNames] isEqualToArray:columnNames]){
            columns = [_table userColumns];
        }else{
            columns = [_table createUserColumnsWithNames:columnNames];
        }
        
        NSMutableArray *values = [NSMutableArray arrayWithArray:row.values];
        
        userRow = [self newRowWithColumns:columns andValues:values];
    }
    
    return userRow;
}

-(GPKGRowResultSet *) results: (GPKGResultSet *) results{
    return [GPKGRowResultSet createWithDao:self andResults:results];
}

-(long long) insert: (NSObject *) object{
    long long id = [super insert:object];
    if([_table hasPkColumn]){
        [self setId:object withIdValue:[NSNumber numberWithLongLong:id]];
    }
    return id;
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGUserRow alloc] initWithTable:_table andColumns:columns andValues:values];
}

-(GPKGBoundingBox *) boundingBox{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGBoundingBox *) boundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    SFPGeometryTransform *projectionTransform = [SFPGeometryTransform transformFromProjection:projection andToProjection:_projection];
    GPKGBoundingBox *projectedBoundingBox = [boundingBox transform:projectionTransform];
    return projectedBoundingBox;
}

-(GPKGContents *) contents{
    return _table.contents;
}

-(int) zoomLevel{
    if(_projection == nil){
        [NSException raise:@"No Projection" format:@"No projection was set which is required to determine the zoom level"];
    }
    int zoomLevel = 0;
    GPKGBoundingBox *boundingBox = [self boundingBox];
    if(boundingBox != nil){
        
        if([_projection isUnit:PROJ_UNIT_DEGREES]){
            boundingBox = [GPKGTileBoundingBoxUtils boundDegreesBoundingBoxWithWebMercatorLimits:boundingBox];
        }
        SFPGeometryTransform *webMercatorTransform = [SFPGeometryTransform transformFromProjection:_projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        GPKGBoundingBox *webMercatorBoundingBox = [boundingBox transform:webMercatorTransform];
        zoomLevel = [GPKGTileBoundingBoxUtils zoomLevelWithWebMercatorBoundingBox:webMercatorBoundingBox];
    }
    return zoomLevel;
}

-(GPKGUserRow *) queryForIdRow: (int) id{
    return [self queryWithColumns:self.columnNames forIdRow:id];
}

-(GPKGUserRow *) queryWithColumns: (NSArray<NSString *> *) columns forIdRow: (int) id{
    GPKGUserRow *row = nil;
    GPKGResultSet *resultSet = [self queryWithColumns:columns forIdInt:id];
    if([resultSet moveToNext]){
        row = [self row:resultSet];
    }
    [resultSet close];
    return row;
}

-(BOOL) isPkModifiable{
    return [_table isPkModifiable];
}

-(void) setPkModifiable: (BOOL) pkModifiable{
    [_table setPkModifiable:pkModifiable];
}

-(BOOL) isValueValidation{
    return [_table isValueValidation];
}

-(void) setValueValidation: (BOOL) valueValidation{
    [_table setValueValidation:valueValidation];
}

-(void) addColumn: (GPKGUserColumn *) column{
    [GPKGSqlUtils addColumn:column toTable:self.tableName withConnection:self.database];
    [_table addColumn:column];
    [self updateColumns];
}

-(void) renameColumn: (GPKGUserColumn *) column toColumn: (NSString *) newColumnName{
    [self renameTableColumnWithName:column.name toColumn:newColumnName];
    [_table renameColumn:column toColumn:newColumnName];
    [self updateColumns];
}

-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    [self renameTableColumnWithName:columnName toColumn:newColumnName];
    [_table renameColumnWithName:columnName toColumn:newColumnName];
    [self updateColumns];
}

-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName{
    [self renameTableColumnWithName:[_table columnNameWithIndex:index] toColumn:newColumnName];
    [_table renameColumnWithIndex:index toColumn:newColumnName];
    [self updateColumns];
}

-(void) renameTableColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    
    // Alter Table in SQLite does not support renaming columns until version 3.25.0
    // Once iOS sqlite3 supports column rename alter table statements, this method can be modified to call:
    // [super renameColumnWithName:columnName toColumn:newColumnName];
    
    GPKGUserTable *newTable = [_table mutableCopy];
    
    [newTable renameColumnWithName:columnName toColumn:newColumnName];
    
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:newTable];
    [[tableMapping columnForName:newColumnName] setFromColumn:columnName];
    
    [GPKGAlterTable alterTable:newTable withMapping:tableMapping withConnection:self.database];
}

-(void) dropColumn: (GPKGUserColumn *) column{
    [self dropColumnWithName:column.name];
}

-(void) dropColumnWithIndex: (int) index{
    [self dropColumnWithName:[_table columnNameWithIndex:index]];
}

-(void) dropColumnWithName: (NSString *) columnName{
    [GPKGAlterTable dropColumn:columnName fromTable:_table withConnection:self.database];
    [self updateColumns];
}

-(void) dropColumns: (NSArray<GPKGUserColumn *> *) columns{
    NSMutableArray<NSString *> *columnNames = [NSMutableArray array];
    for(GPKGUserColumn *column in columns){
        [columnNames addObject:column.name];
    }
    [self dropColumnNames:columnNames];
}

-(void) dropColumnIndexes: (NSArray<NSNumber *> *) indexes{
    NSMutableArray<NSString *> *columnNames = [NSMutableArray array];
    for(NSNumber *index in indexes){
        [columnNames addObject:[self columnNameWithIndex:[index intValue]]];
    }
    [self dropColumnNames:columnNames];
}

-(void) dropColumnNames: (NSArray<NSString *> *) columnNames{
    [GPKGAlterTable dropColumns:columnNames fromTable:_table withConnection:self.database];
    [self updateColumns];
}

-(void) alterColumn: (GPKGUserColumn *) column{
    [GPKGAlterTable alterColumn:column inTable:_table withConnection:self.database];
    [self updateColumns];
}

-(void) alterColumns: (NSArray<GPKGUserColumn *> *) columns{
    [GPKGAlterTable alterColumns:columns inTable:_table withConnection:self.database];
    [self updateColumns];
}

-(void) updateColumns{
    self.columnNames = [_table columnNames];
    [self initializeColumnIndex];
}

@end
