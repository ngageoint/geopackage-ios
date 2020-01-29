//
//  GPKGUserDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGUserRow.h"
#import "SFPProjectionTransform.h"
#import "SFPProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGSqlUtils.h"
#import "GPKGAlterTable.h"

@implementation GPKGUserDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserTable *) table{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.table = table;
        self.tableName = [table tableName];
        GPKGUserColumn * pkColumn = [table pkColumn];
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

-(NSString *) idColumn{
    return [self.table pkColumnName];
}

-(NSObject *) queryForIdObject: (NSObject *) idValue{
    
    NSObject * objectResult = nil;
    GPKGResultSet *results = [self queryForId:idValue];
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
    NSObject * value = [row databaseValueWithIndex:columnIndex];

    return value;
}

-(SFPProjection *) projection: (NSObject *) object{
    return _projection;
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
    return [NSArray arrayWithObject:[_table pkColumnName]];
}

-(GPKGUserRow *) row: (GPKGResultSet *) results{
    
    GPKGUserRow * row = nil;
    
    if(self.table != nil){
        
        if(results.columns == nil){
            [results setColumnsFromTable:self.table];
        }
        
        NSUInteger columns = [results.columnNames count];
        
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:columns];
        
        [results rowPopulateValues:values];
        
        row = [self newRowWithColumns:results.columns andValues:values];
    }
    
    return row;
}

-(long long) insert: (NSObject *) object{
    long long id = [super insert:object];
    if([self.table hasPkColumn]){
        [self setId:object withIdValue:[NSNumber numberWithLongLong:id]];
    }
    return id;
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGUserRow alloc] initWithTable:self.table andColumns:columns andValues:values];
}

-(GPKGBoundingBox *) boundingBox{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGBoundingBox *) boundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    SFPProjectionTransform *projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:self.projection];
    GPKGBoundingBox *projectedBoundingBox = [boundingBox transform:projectionTransform];
    return projectedBoundingBox;
}

-(GPKGContents *) contents{
    return _table.contents;
}

-(int) zoomLevel{
    if(self.projection == nil){
        [NSException raise:@"No Projection" format:@"No projection was set which is required to determine the zoom level"];
    }
    int zoomLevel = 0;
    GPKGBoundingBox * boundingBox = [self boundingBox];
    if(boundingBox != nil){
        
        if([self.projection isUnit:SFP_UNIT_DEGREES]){
            boundingBox = [GPKGTileBoundingBoxUtils boundDegreesBoundingBoxWithWebMercatorLimits:boundingBox];
        }
        SFPProjectionTransform * webMercatorTransform = [[SFPProjectionTransform alloc] initWithFromProjection:self.projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        GPKGBoundingBox * webMercatorBoundingBox = [boundingBox transform:webMercatorTransform];
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

-(void) addColumn: (GPKGUserColumn *) column{
    [GPKGSqlUtils addColumn:column toTable:self.tableName withConnection:self.database];
    [self.table addColumn:column];
    [self updateColumns];
}

-(void) renameColumn: (GPKGUserColumn *) column toColumn: (NSString *) newColumnName{
    [self renameTableColumnWithName:column.name toColumn:newColumnName];
    [self.table renameColumn:column toColumn:newColumnName];
    [self updateColumns];
}

-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    [self renameTableColumnWithName:columnName toColumn:newColumnName];
    [self.table renameColumnWithName:columnName toColumn:newColumnName];
    [self updateColumns];
}

-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName{
    [self renameTableColumnWithName:[self.table columnNameWithIndex:index] toColumn:newColumnName];
    [self.table renameColumnWithIndex:index toColumn:newColumnName];
    [self updateColumns];
}

-(void) renameTableColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    
    // Alter Table in SQLite does not support renaming columns until version 3.25.0
    // Once iOS sqlite3 supports column rename alter table statements, this method can be modified to call:
    // [super renameColumnWithName:columnName toColumn:newColumnName];
    
    GPKGUserTable *newTable = [self.table mutableCopy];
    
    [newTable renameColumnWithName:columnName toColumn:newColumnName];
    
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:newTable];
    [[tableMapping columnForName:newColumnName] setFromColumn:columnName];
    
    [GPKGAlterTable alterTable:newTable withMapping:tableMapping withConnection:self.database];
}

-(void) dropColumn: (GPKGUserColumn *) column{
    [self dropColumnWithName:column.name];
}

-(void) dropColumnWithIndex: (int) index{
    [self dropColumnWithName:[self.table columnNameWithIndex:index]];
}

-(void) dropColumnWithName: (NSString *) columnName{
    [GPKGAlterTable dropColumn:columnName fromTable:self.table withConnection:self.database];
    [self updateColumns];
}

-(void) dropColumns: (NSArray<GPKGUserColumn *> *) columns{
    NSMutableArray<NSString *> *columnNames = [[NSMutableArray alloc] init];
    for(GPKGUserColumn *column in columns){
        [columnNames addObject:column.name];
    }
    [self dropColumnNames:columnNames];
}

-(void) dropColumnIndexes: (NSArray<NSNumber *> *) indexes{
    NSMutableArray<NSString *> *columnNames = [[NSMutableArray alloc] init];
    for(NSNumber *index in indexes){
        [columnNames addObject:[self columnNameWithIndex:[index intValue]]];
    }
    [self dropColumnNames:columnNames];
}

-(void) dropColumnNames: (NSArray<NSString *> *) columnNames{
    [GPKGAlterTable dropColumns:columnNames fromTable:self.table withConnection:self.database];
    [self updateColumns];
}

-(void) alterColumn: (GPKGUserColumn *) column{
    [GPKGAlterTable alterColumn:column inTable:self.table withConnection:self.database];
    [self updateColumns];
}

-(void) alterColumns: (NSArray<GPKGUserColumn *> *) columns{
    [GPKGAlterTable alterColumns:columns inTable:self.table withConnection:self.database];
    [self updateColumns];
}

-(void) updateColumns{
    self.columnNames = [self.table columnNames];
    [self initializeColumnIndex];
}

@end
