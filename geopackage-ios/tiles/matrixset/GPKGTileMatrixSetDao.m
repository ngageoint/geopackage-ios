//
//  GPKGTileMatrixSetDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileMatrixSetDao.h"
#import "GPKGContentsDao.h"
#import "GPKGSpatialReferenceSystemDao.h"

@implementation GPKGTileMatrixSetDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_TMS_TABLE_NAME;
        self.idColumns = @[GPKG_TMS_COLUMN_PK];
        self.columns = @[GPKG_TMS_COLUMN_TABLE_NAME, GPKG_TMS_COLUMN_SRS_ID, GPKG_TMS_COLUMN_MIN_X, GPKG_TMS_COLUMN_MIN_Y, GPKG_TMS_COLUMN_MAX_X, GPKG_TMS_COLUMN_MAX_Y];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGTileMatrixSet alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGTileMatrixSet *setObject = (GPKGTileMatrixSet*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.srsId = (NSNumber *) value;
            break;
        case 2:
            setObject.minX = (NSDecimalNumber *) value;
            break;
        case 3:
            setObject.minY = (NSDecimalNumber *) value;
            break;
        case 4:
            setObject.maxX = (NSDecimalNumber *) value;
            break;
        case 5:
            setObject.maxY = (NSDecimalNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGTileMatrixSet *getObject = (GPKGTileMatrixSet*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.srsId;
            break;
        case 2:
            value = getObject.minX;
            break;
        case 3:
            value = getObject.minY;
            break;
        case 4:
            value = getObject.maxX;
            break;
        case 5:
            value = getObject.maxY;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    GPKGTileMatrixSet *projectionObject = (GPKGTileMatrixSet*) object;
    GPKGSpatialReferenceSystem * srs = [self getSrs:projectionObject];
    GPKGSpatialReferenceSystemDao * srsDao = [self getSpatialReferenceSystemDao];
    GPKGProjection * projection = [srsDao getProjection:srs];
    return projection;
}

-(NSArray *) getTileTables{
    
    NSString *queryString = [NSString stringWithFormat:@"select %@ from %@", GPKG_TMS_COLUMN_TABLE_NAME, GPKG_TMS_TABLE_NAME];
    
    GPKGResultSet *results = [self rawQuery:queryString];
    NSArray *tables = [self singleColumnResults:results];
    [results close];
    
    return tables;
}

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGTileMatrixSet *) tileMatrixSet{
    GPKGSpatialReferenceSystemDao * dao = [self getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:tileMatrixSet.srsId];
    return srs;
}

-(GPKGContents *) getContents: (GPKGTileMatrixSet *) tileMatrixSet{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:tileMatrixSet.tableName];
    return contents;
}

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
