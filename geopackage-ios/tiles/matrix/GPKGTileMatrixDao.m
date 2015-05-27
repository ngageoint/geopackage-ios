//
//  GPKGTileMatrixDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileMatrixDao.h"
#import "GPKGContentsDao.h"
#import "GPKGTileMatrixSetDao.h"

@implementation GPKGTileMatrixDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_TM_TABLE_NAME;
        self.idColumns = @[GPKG_TM_COLUMN_PK1, GPKG_TM_COLUMN_PK2];
        self.columns = @[GPKG_TM_COLUMN_TABLE_NAME, GPKG_TM_COLUMN_ZOOM_LEVEL, GPKG_TM_COLUMN_MATRIX_WIDTH, GPKG_TM_COLUMN_MATRIX_HEIGHT, GPKG_TM_COLUMN_TILE_WIDTH, GPKG_TM_COLUMN_TILE_HEIGHT, GPKG_TM_COLUMN_PIXEL_X_SIZE, GPKG_TM_COLUMN_PIXEL_Y_SIZE];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGTileMatrix alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGTileMatrix *setObject = (GPKGTileMatrix*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.zoomLevel = (NSNumber *) value;
            break;
        case 2:
            setObject.matrixWidth = (NSNumber *) value;
            break;
        case 3:
            setObject.matrixHeight = (NSNumber *) value;
            break;
        case 4:
            setObject.tileWidth = (NSNumber *) value;
            break;
        case 5:
            setObject.tileHeight = (NSNumber *) value;
            break;
        case 6:
            setObject.pixelXSize = (NSDecimalNumber *) value;
            break;
        case 7:
            setObject.pixelYSize = (NSDecimalNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGTileMatrix *getObject = (GPKGTileMatrix*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.zoomLevel;
            break;
        case 2:
            value = getObject.matrixWidth;
            break;
        case 3:
            value = getObject.matrixHeight;
            break;
        case 4:
            value = getObject.tileWidth;
            break;
        case 5:
            value = getObject.tileHeight;
            break;
        case 6:
            value = getObject.pixelXSize;
            break;
        case 7:
            value = getObject.pixelYSize;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    GPKGTileMatrix *projectionObject = (GPKGTileMatrix*) object;
    GPKGTileMatrixSetDao * tileMatrixSetDao = [self getTileMatrixSetDao];
    GPKGTileMatrixSet * tileMatrixSet = [self getTileMatrixSet:projectionObject];
    GPKGProjection * projection = [tileMatrixSetDao getProjection:tileMatrixSet];
    return projection;
}

-(GPKGTileMatrixSet *) getTileMatrixSet: (GPKGTileMatrix *) tileMatrix{
    GPKGTileMatrixSetDao * dao = [self getTileMatrixSetDao];
    GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:tileMatrix.tableName];
    return tileMatrixSet;
}

-(GPKGTileMatrixSetDao *) getTileMatrixSetDao{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:self.database];
}

-(GPKGContents *) getContents: (GPKGTileMatrix *) tileMatrix{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:tileMatrix.tableName];
    return contents;
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
