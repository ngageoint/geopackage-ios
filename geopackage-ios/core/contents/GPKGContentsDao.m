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

@implementation GPKGContentsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_CON_TABLE_NAME;
        self.idColumns = @[GPKG_CON_COLUMN_PK];
        self.columns = @[GPKG_CON_COLUMN_TABLE_NAME, GPKG_CON_COLUMN_DATA_TYPE, GPKG_CON_COLUMN_IDENTIFIER, GPKG_CON_COLUMN_DESCRIPTION, GPKG_CON_COLUMN_LAST_CHANGE, GPKG_CON_COLUMN_MIN_X, GPKG_CON_COLUMN_MIN_Y, GPKG_CON_COLUMN_MAX_X, GPKG_CON_COLUMN_MAX_Y, GPKG_CON_COLUMN_SRS_ID];
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
            setObject.minX = (NSDecimalNumber *) value;
            break;
        case 6:
            setObject.minY = (NSDecimalNumber *) value;
            break;
        case 7:
            setObject.maxX = (NSDecimalNumber *) value;
            break;
        case 8:
            setObject.maxY = (NSDecimalNumber *) value;
            break;
        case 9:
            setObject.srsId = (NSNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGContents *getObject = (GPKGContents*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.dataType;
            break;
        case 2:
            value = getObject.identifier;
            break;
        case 3:
            value = getObject.theDescription;
            break;
        case 4:
            value = getObject.lastChange;
            break;
        case 5:
            value = getObject.minX;
            break;
        case 6:
            value = getObject.minY;
            break;
        case 7:
            value = getObject.maxX;
            break;
        case 8:
            value = getObject.maxY;
            break;
        case 9:
            value = getObject.srsId;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    GPKGContents *projectionObject = (GPKGContents*) object;
    GPKGSpatialReferenceSystem * srs = [self getSrs:projectionObject];
    GPKGSpatialReferenceSystemDao * srsDao = [self getSpatialReferenceSystemDao];
    GPKGProjection * projection = [srsDao getProjection:srs];
    return projection;
}

-(void) validateObject: (NSObject*) object{
    
    GPKGContents *validateObject = (GPKGContents*) object;
    enum GPKGContentsDataType dataType = [validateObject getContentsDataType];
    
    switch (dataType) {
        case GPKG_CDT_FEATURES:{
                // Features require Geometry Columns table (Spec Requirement 21)
                GPKGGeometryColumnsDao * geometryColumnsDao = [self getGeometryColumnsDao];
                if(![geometryColumnsDao tableExists]){
                    [NSException raise:@"Missing Table" format:@"A data type of %@ requires the %@ table to first be created using the GeoPackage.", validateObject.dataType, GPKG_GC_TABLE_NAME];
                }
            }
            break;
        case GPKG_CDT_TILES:{
                // Tiles require Tile Matrix Set table (Spec Requirement 37)
                GPKGTileMatrixSetDao * tileMatrixSetDao = [self getTileMatrixSetDao];
                if(![tileMatrixSetDao tableExists]){
                    [NSException raise:@"Missing Table" format:@"A data type of %@ requires the %@ table to first be created using the GeoPackage.", validateObject.dataType, GPKG_TMS_TABLE_NAME];
                }
            
                // Tiles require Tile Matrix table (Spec Requirement 41)
                GPKGTileMatrixDao * tileMatrixDao = [self getTileMatrixDao];
                if(![tileMatrixDao tableExists]){
                    [NSException raise:@"Missing Table" format:@"A data type of %@ requires the %@ table to first be created using the GeoPackage.", validateObject.dataType, GPKG_TM_TABLE_NAME];
                }
            }
            
            break;
            
        default:
            [NSException raise:@"Illegal Data Type" format:@"Unsupported data type: %d", dataType];
            break;
    }
    
    // Verify the feature or tile table exists
    if(![self.database tableExists:validateObject.tableName]){
        [NSException raise:@"Missing Table" format:@"No table exists for Content Table Name: %@. Table must first be created.", validateObject.tableName];
    }
}

-(int) deleteCascade: (GPKGContents *) contents{
    
    int count = 0;
    
    if(contents != nil){
        
        // Delete Geometry Columns
        GPKGGeometryColumnsDao * geometryColumnsDao = [self getGeometryColumnsDao];
        if([geometryColumnsDao tableExists]){
            GPKGGeometryColumns * geometryColumns = [self getGeometryColumns:contents];
            if(geometryColumns != nil){
                [geometryColumnsDao delete:geometryColumns];
            }
        }
        
        // Delete Tile Matrix
        GPKGTileMatrixDao * tileMatrixDao = [self getTileMatrixDao];
        if([tileMatrixDao tableExists]){
            GPKGResultSet * tileMatrixResults = [self getTileMatrix:contents];
            while([tileMatrixResults moveToNext]){
                GPKGTileMatrix * tileMatrix = (GPKGTileMatrix *)[tileMatrixDao getObject:tileMatrixResults];
                [tileMatrixDao delete:tileMatrix];
            }
            [tileMatrixResults close];
        }
        
        // Delete Tile Matrix Set
        GPKGTileMatrixSetDao * tileMatrixSetDao = [self getTileMatrixSetDao];
        if([tileMatrixSetDao tableExists]){
            GPKGTileMatrixSet * tileMatrixSet = [self getTileMatrixSet:contents];
            if(tileMatrixSet != nil){
                [tileMatrixSetDao delete:tileMatrixSet];
            }
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
        GPKGResultSet *results = [self queryWhere:where andWhereArgs:whereArgs];
        while([results moveToNext]){
            GPKGContents *contents = (GPKGContents *)[self getObject:results];
            count += [self deleteCascade:contents andUserTable:userTable];
        }
        [results close];
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

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGContents *) contents{
    GPKGSpatialReferenceSystemDao * dao = [self getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:contents.srsId];
    return srs;
}

-(GPKGGeometryColumns *) getGeometryColumns: (GPKGContents *) contents{
    GPKGGeometryColumns * geometryColumns = nil;
    GPKGGeometryColumnsDao * dao = [self getGeometryColumnsDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_GC_COLUMN_TABLE_NAME andValue:contents.tableName];
    if([results moveToNext]){
        geometryColumns = (GPKGGeometryColumns *)[dao getObject:results];
    }
    [results close];
    return geometryColumns;
}

-(GPKGTileMatrixSet *) getTileMatrixSet: (GPKGContents *) contents{
    GPKGTileMatrixSet * tileMatrixSet = nil;
    GPKGTileMatrixSetDao * dao = [self getTileMatrixSetDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_TMS_COLUMN_TABLE_NAME andValue:contents.tableName];
    if([results moveToNext]){
        tileMatrixSet = (GPKGTileMatrixSet *)[dao getObject:results];
    }
    [results close];
    return tileMatrixSet;
}

-(GPKGResultSet *) getTileMatrix: (GPKGContents *) contents{
    GPKGTileMatrixDao * dao = [self getTileMatrixDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_TM_COLUMN_TABLE_NAME andValue:contents.tableName];
    return results;
}

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.database];
}

-(GPKGTileMatrixSetDao *) getTileMatrixSetDao{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:self.database];
}

-(GPKGTileMatrixDao *) getTileMatrixDao{
    return [[GPKGTileMatrixDao alloc] initWithDatabase:self.database];
}

@end
