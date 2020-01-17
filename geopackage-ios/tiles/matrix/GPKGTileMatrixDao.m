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
#import "GPKGUtils.h"

@implementation GPKGTileMatrixDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_TM_TABLE_NAME;
        self.idColumns = @[GPKG_TM_COLUMN_PK1, GPKG_TM_COLUMN_PK2];
        self.columnNames = @[GPKG_TM_COLUMN_TABLE_NAME, GPKG_TM_COLUMN_ZOOM_LEVEL, GPKG_TM_COLUMN_MATRIX_WIDTH, GPKG_TM_COLUMN_MATRIX_HEIGHT, GPKG_TM_COLUMN_TILE_WIDTH, GPKG_TM_COLUMN_TILE_HEIGHT, GPKG_TM_COLUMN_PIXEL_X_SIZE, GPKG_TM_COLUMN_PIXEL_Y_SIZE];
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
            setObject.pixelXSize = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 7:
            setObject.pixelYSize = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGTileMatrix *tileMatrix = (GPKGTileMatrix*) object;
    
    switch(columnIndex){
        case 0:
            value = tileMatrix.tableName;
            break;
        case 1:
            value = tileMatrix.zoomLevel;
            break;
        case 2:
            value = tileMatrix.matrixWidth;
            break;
        case 3:
            value = tileMatrix.matrixHeight;
            break;
        case 4:
            value = tileMatrix.tileWidth;
            break;
        case 5:
            value = tileMatrix.tileHeight;
            break;
        case 6:
            value = tileMatrix.pixelXSize;
            break;
        case 7:
            value = tileMatrix.pixelYSize;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(SFPProjection *) projection: (NSObject *) object{
    GPKGTileMatrix *projectionObject = (GPKGTileMatrix*) object;
    GPKGTileMatrixSetDao * tileMatrixSetDao = [self tileMatrixSetDao];
    GPKGTileMatrixSet * tileMatrixSet = [self tileMatrixSet:projectionObject];
    SFPProjection * projection = [tileMatrixSetDao projection:tileMatrixSet];
    return projection;
}

-(GPKGTileMatrixSet *) tileMatrixSet: (GPKGTileMatrix *) tileMatrix{
    GPKGTileMatrixSetDao * dao = [self tileMatrixSetDao];
    GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *)[dao queryForIdObject:tileMatrix.tableName];
    return tileMatrixSet;
}

-(GPKGTileMatrixSetDao *) tileMatrixSetDao{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:self.database];
}

-(GPKGContents *) contents: (GPKGTileMatrix *) tileMatrix{
    GPKGContentsDao * dao = [self contentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForIdObject:tileMatrix.tableName];
    return contents;
}

-(GPKGContentsDao *) contentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
