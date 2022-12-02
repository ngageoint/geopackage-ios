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
#import "GPKGUtils.h"
#import "GPKGCrsWktExtension.h"

@implementation GPKGTileMatrixSetDao

+(GPKGTileMatrixSetDao *) createWithDatabase: (GPKGConnection *) database{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:database];
}

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_TMS_TABLE_NAME;
        self.idColumns = @[GPKG_TMS_COLUMN_PK];
        self.columnNames = @[GPKG_TMS_COLUMN_TABLE_NAME, GPKG_TMS_COLUMN_SRS_ID, GPKG_TMS_COLUMN_MIN_X, GPKG_TMS_COLUMN_MIN_Y, GPKG_TMS_COLUMN_MAX_X, GPKG_TMS_COLUMN_MAX_Y];
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
            setObject.minX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 3:
            setObject.minY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 4:
            setObject.maxX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 5:
            setObject.maxY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject *value = nil;
    
    GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet*) object;
    
    switch(columnIndex){
        case 0:
            value = tileMatrixSet.tableName;
            break;
        case 1:
            value = tileMatrixSet.srsId;
            break;
        case 2:
            value = tileMatrixSet.minX;
            break;
        case 3:
            value = tileMatrixSet.minY;
            break;
        case 4:
            value = tileMatrixSet.maxX;
            break;
        case 5:
            value = tileMatrixSet.maxY;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(PROJProjection *) projection: (NSObject *) object{
    GPKGTileMatrixSet *projectionObject = (GPKGTileMatrixSet*) object;
    GPKGSpatialReferenceSystem *srs = [self srs:projectionObject];
    PROJProjection *projection = [srs projection];
    return projection;
}

-(NSArray *) tileTables{
    
    NSString *queryString = [NSString stringWithFormat:@"select %@ from %@", GPKG_TMS_COLUMN_TABLE_NAME, GPKG_TMS_TABLE_NAME];
    
    GPKGResultSet *results = [self rawQuery:queryString];
    NSArray *tables = [self singleColumnResults:results];
    [results close];
    
    return tables;
}

-(GPKGSpatialReferenceSystem *) srs: (GPKGTileMatrixSet *) tileMatrixSet{
    GPKGSpatialReferenceSystemDao *dao = [self spatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForIdObject:tileMatrixSet.srsId];
    return srs;
}

-(GPKGContents *) contents: (GPKGTileMatrixSet *) tileMatrixSet{
    GPKGContentsDao *dao = [self contentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:tileMatrixSet.tableName];
    return contents;
}

-(GPKGBoundingBox *) boundingBoxOfTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *boundingBox = [tileMatrixSet boundingBox];
    if (projection != nil) {
        SFPGeometryTransform *transform = [SFPGeometryTransform transformFromProjection:[self projection:tileMatrixSet] andToProjection:projection];
        if(![transform isSameProjection]){
            boundingBox = [boundingBox transform:transform];
        }
    }
    return boundingBox;
}

-(GPKGSpatialReferenceSystemDao *) spatialReferenceSystemDao{
    GPKGSpatialReferenceSystemDao *dao = [GPKGSpatialReferenceSystemDao createWithDatabase:self.database];
    [dao setCrsWktExtension:[[GPKGCrsWktExtension alloc] initWithDatabase:self.database]];
    return dao;
}

-(GPKGContentsDao *) contentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
