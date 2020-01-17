//
//  GPKGContentsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGContentsDao.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGTileMatrixDao.h"
#import "GPKGDateTimeUtils.h"
#import "GPKGUtils.h"

@implementation GPKGContentsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_CON_TABLE_NAME;
        self.idColumns = @[GPKG_CON_COLUMN_PK];
        self.columnNames = @[GPKG_CON_COLUMN_TABLE_NAME, GPKG_CON_COLUMN_DATA_TYPE, GPKG_CON_COLUMN_IDENTIFIER, GPKG_CON_COLUMN_DESCRIPTION, GPKG_CON_COLUMN_LAST_CHANGE, GPKG_CON_COLUMN_MIN_X, GPKG_CON_COLUMN_MIN_Y, GPKG_CON_COLUMN_MAX_X, GPKG_CON_COLUMN_MAX_Y, GPKG_CON_COLUMN_SRS_ID];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGContents alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGContents *setObject = (GPKGContents*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.dataType = (NSString *) value;
            break;
        case 2:
            setObject.identifier = (NSString *) value;
            break;
        case 3:
            setObject.theDescription = (NSString *) value;
            break;
        case 4:
            setObject.lastChange = [GPKGDateTimeUtils convertToDateWithString:((NSString *) value)];
            break;
        case 5:
            setObject.minX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 6:
            setObject.minY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 7:
            setObject.maxX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 8:
            setObject.maxY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 9:
            setObject.srsId = (NSNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGContents *contents = (GPKGContents*) object;
    
    switch(columnIndex){
        case 0:
            value = contents.tableName;
            break;
        case 1:
            value = contents.dataType;
            break;
        case 2:
            value = contents.identifier;
            break;
        case 3:
            value = contents.theDescription;
            break;
        case 4:
            value = contents.lastChange;
            break;
        case 5:
            value = contents.minX;
            break;
        case 6:
            value = contents.minY;
            break;
        case 7:
            value = contents.maxX;
            break;
        case 8:
            value = contents.maxY;
            break;
        case 9:
            value = contents.srsId;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(SFPProjection *) projection: (NSObject *) object{
    GPKGContents *projectionObject = (GPKGContents*) object;
    GPKGSpatialReferenceSystem * srs = [self srs:projectionObject];
    SFPProjection *projection = [srs projection];
    return projection;
}

-(void) validateObject: (NSObject*) object{
    
    GPKGContents *validateObject = (GPKGContents*) object;
    enum GPKGContentsDataType dataType = [validateObject contentsDataType];
    
    if((int)dataType >= 0){
        switch (dataType) {
            case GPKG_CDT_FEATURES:{
                    // Features require Geometry Columns table (Spec Requirement 21)
                    GPKGGeometryColumnsDao * geometryColumnsDao = [self geometryColumnsDao];
                    if(![geometryColumnsDao tableExists]){
                        [NSException raise:@"Missing Table" format:@"A data type of %@ requires the %@ table to first be created using the GeoPackage.", validateObject.dataType, GPKG_GC_TABLE_NAME];
                    }
                }
                break;
            case GPKG_CDT_TILES:
                    [self verifyTiles:dataType];
                break;
            case GPKG_CDT_GRIDDED_COVERAGE:
                    [self verifyTiles:dataType];
                break;
            case GPKG_CDT_ATTRIBUTES:
                break;
            default:
                [NSException raise:@"Illegal Data Type" format:@"Unsupported data type: %d", dataType];
                break;
        }
    }
    
    // Verify the feature or tile table exists
    if(![self.database tableExists:validateObject.tableName]){
        [NSException raise:@"Missing Table" format:@"No table exists for Content Table Name: %@. Table must first be created.", validateObject.tableName];
    }
}

-(void) verifyTiles: (enum GPKGContentsDataType) dataType{
    
    // Tiles require Tile Matrix Set table (Spec Requirement 37)
    GPKGTileMatrixSetDao * tileMatrixSetDao = [self tileMatrixSetDao];
    if(![tileMatrixSetDao tableExists]){
        [NSException raise:@"Missing Table" format:@"A data type of %@ requires the %@ table to first be created using the GeoPackage.", [GPKGContentsDataTypes name:dataType], GPKG_TMS_TABLE_NAME];
    }
    
    // Tiles require Tile Matrix table (Spec Requirement 41)
    GPKGTileMatrixDao * tileMatrixDao = [self tileMatrixDao];
    if(![tileMatrixDao tableExists]){
        [NSException raise:@"Missing Table" format:@"A data type of %@ requires the %@ table to first be created using the GeoPackage.", [GPKGContentsDataTypes name:dataType], GPKG_TM_TABLE_NAME];
    }
}

-(NSArray *) tablesOfType: (enum GPKGContentsDataType) dataType{
    return [self tablesOfTypeName:[GPKGContentsDataTypes name:dataType]];
}

-(NSArray *) tablesOfTypeName: (NSString *) dataType{
    GPKGResultSet * contents = [self contentsOfTypeName:dataType];
    NSMutableArray * tableNames = [[NSMutableArray alloc] init];
    while([contents moveToNext]){
        GPKGContents * content = (GPKGContents *)[self object:contents];
        [tableNames addObject:content.tableName];
    }
    [contents close];
    return tableNames;
}

-(GPKGResultSet *) contentsOfType: (enum GPKGContentsDataType) dataType{
    return [self contentsOfTypeName:[GPKGContentsDataTypes name:dataType]];
}

-(GPKGResultSet *) contentsOfTypeName: (NSString *) dataType{
    GPKGResultSet * contents = [self queryForEqWithField:GPKG_CON_COLUMN_DATA_TYPE andValue:dataType];
    return contents;
}

-(NSArray *) tables{
    GPKGResultSet * contents = [self queryForAll];
    NSMutableArray * tableNames = [[NSMutableArray alloc] init];
    while([contents moveToNext]){
        GPKGContents * content = (GPKGContents *)[self object:contents];
        [tableNames addObject:content.tableName];
    }
    [contents close];
    return tableNames;
}

-(int) deleteCascade: (GPKGContents *) contents{
    
    int count = 0;
    
    if(contents != nil){
        
        int dataType = [contents contentsDataType];
        
        if(dataType > -1){
            
            switch(dataType){
                    
                case GPKG_CDT_FEATURES:
                    {
                        // Delete Geometry Columns
                        GPKGGeometryColumnsDao * geometryColumnsDao = [self geometryColumnsDao];
                        if([geometryColumnsDao tableExists]){
                            GPKGGeometryColumns * geometryColumns = [self geometryColumns:contents];
                            if(geometryColumns != nil){
                                [geometryColumnsDao delete:geometryColumns];
                            }
                        }
                    }
                    break;
                    
                case GPKG_CDT_TILES:
                case GPKG_CDT_GRIDDED_COVERAGE:
                    {
                        // Delete Tile Matrix
                        GPKGTileMatrixDao * tileMatrixDao = [self tileMatrixDao];
                        if([tileMatrixDao tableExists]){
                            GPKGResultSet * tileMatrixResults = [self tileMatrix:contents];
                            while([tileMatrixResults moveToNext]){
                                GPKGTileMatrix * tileMatrix = (GPKGTileMatrix *)[tileMatrixDao object:tileMatrixResults];
                                [tileMatrixDao delete:tileMatrix];
                            }
                            [tileMatrixResults close];
                        }
                        
                        // Delete Tile Matrix Set
                        GPKGTileMatrixSetDao * tileMatrixSetDao = [self tileMatrixSetDao];
                        if([tileMatrixSetDao tableExists]){
                            GPKGTileMatrixSet * tileMatrixSet = [self tileMatrixSet:contents];
                            if(tileMatrixSet != nil){
                                [tileMatrixSetDao delete:tileMatrixSet];
                            }
                        }
                    }
                    break;
                    
                case GPKG_CDT_ATTRIBUTES:
                    {
                        [self.database dropTable:contents.tableName];
                    }
                    break;
                    
            }
            
        } else{
            [self.database dropTable:contents.tableName];
        }
        
        // Delete
        count = [self delete:contents];
    }
    
    return count;
}

-(int) deleteCascade: (GPKGContents *) contents andUserTable: (BOOL) userTable{
    int count = [self deleteCascade:contents];
    
    if(userTable){
        [self.database dropTable:contents.tableName];
    }
    
    return count;
}

-(int) deleteCascadeWithCollection: (NSArray *) contentsCollection{
    return [self deleteCascadeWithCollection:contentsCollection andUserTable:false];
}

-(int) deleteCascadeWithCollection: (NSArray *) contentsCollection andUserTable: (BOOL) userTable{
    int count = 0;
    if(contentsCollection != nil){
        for(GPKGContents *contents in contentsCollection){
            count += [self deleteCascade:contents andUserTable:userTable];
        }
    }
    return count;
}

-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self deleteCascadeWhere:where andWhereArgs:whereArgs andUserTable:false];
}

-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andUserTable: (BOOL) userTable{
    int count = 0;
    if(where != nil){
        NSMutableArray *contentsArray = [[NSMutableArray alloc] init];
        GPKGResultSet *results = [self queryWhere:where andWhereArgs:whereArgs];
        while([results moveToNext]){
            GPKGContents *contents = (GPKGContents *)[self object:results];
            [contentsArray addObject:contents];
        }
        [results close];
        for(GPKGContents *contents in contentsArray){
            count += [self deleteCascade:contents andUserTable:userTable];
        }
    }
    return count;
}

-(int) deleteByIdCascade: (NSString *) id{
    return [self deleteByIdCascade:id andUserTable:false];
}

-(int) deleteByIdCascade: (NSString *) id andUserTable: (BOOL) userTable{
    int count = 0;
    if(id != nil){
        GPKGContents *contents = (GPKGContents *) [self queryForIdObject:id];
        if(contents != nil){
            count = [self deleteCascade:contents andUserTable:userTable];
        }else if(userTable){
            [self.database dropTable:id];
        }
    }
    return count;
}

-(int) deleteIdsCascade: (NSArray *) idCollection{
    return [self deleteIdsCascade:idCollection andUserTable:false];
}

-(int) deleteIdsCascade: (NSArray *) idCollection andUserTable: (BOOL) userTable{
    int count = 0;
    if(idCollection != nil){
        for(NSString * id in idCollection){
            count += [self deleteByIdCascade:id andUserTable:userTable];
        }
    }
    return count;
}

-(void) deleteTable: (NSString *) table{
    [self deleteByIdCascade:table andUserTable:true];
}

-(GPKGSpatialReferenceSystem *) srs: (GPKGContents *) contents{
    GPKGSpatialReferenceSystemDao * dao = [self spatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:contents.srsId];
    return srs;
}

-(GPKGGeometryColumns *) geometryColumns: (GPKGContents *) contents{
    GPKGGeometryColumns * geometryColumns = nil;
    GPKGGeometryColumnsDao * dao = [self geometryColumnsDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_GC_COLUMN_TABLE_NAME andValue:contents.tableName];
    if([results moveToNext]){
        geometryColumns = (GPKGGeometryColumns *)[dao object:results];
    }
    [results close];
    return geometryColumns;
}

-(GPKGTileMatrixSet *) tileMatrixSet: (GPKGContents *) contents{
    GPKGTileMatrixSet * tileMatrixSet = nil;
    GPKGTileMatrixSetDao * dao = [self tileMatrixSetDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_TMS_COLUMN_TABLE_NAME andValue:contents.tableName];
    if([results moveToNext]){
        tileMatrixSet = (GPKGTileMatrixSet *)[dao object:results];
    }
    [results close];
    return tileMatrixSet;
}

-(GPKGResultSet *) tileMatrix: (GPKGContents *) contents{
    GPKGTileMatrixDao * dao = [self tileMatrixDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_TM_COLUMN_TABLE_NAME andValue:contents.tableName];
    return results;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    
    GPKGBoundingBox *boundingBox = nil;
    
    NSArray<NSString *> *tables = [self tables];
    
    for (NSString *table in tables) {
        GPKGBoundingBox *tableBoundingBox = [self boundingBoxOfTable:table inProjection:projection];
        if (tableBoundingBox != nil) {
            if (boundingBox != nil) {
                boundingBox = [boundingBox union:tableBoundingBox];
            } else {
                boundingBox = tableBoundingBox;
            }
        }
    }
    
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table{
    return [self boundingBoxOfTable:table inProjection:nil];
}

-(GPKGBoundingBox *) boundingBoxOfTable: (NSString *) table inProjection: (SFPProjection *) projection{

    GPKGContents *contents = (GPKGContents *)[self queryForIdObject:table];
    GPKGBoundingBox *boundingBox = [self boundingBoxOfContents:contents inProjection:projection];
    
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxOfContents: (GPKGContents *) contents inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *boundingBox = [contents boundingBox];
    if (boundingBox != nil && projection != nil) {
        SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:[self projection:contents] andToProjection:projection];
        if(![transform isSameProjection]){
            boundingBox = [boundingBox transform:transform];
        }
    }
    return boundingBox;
}

-(GPKGSpatialReferenceSystemDao *) spatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGGeometryColumnsDao *) geometryColumnsDao{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.database];
}

-(GPKGTileMatrixSetDao *) tileMatrixSetDao{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:self.database];
}

-(GPKGTileMatrixDao *) tileMatrixDao{
    return [[GPKGTileMatrixDao alloc] initWithDatabase:self.database];
}

@end
