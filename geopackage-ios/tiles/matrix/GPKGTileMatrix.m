//
//  GPKGTileMatrix.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileMatrix.h"

NSString * const TM_TABLE_NAME = @"gpkg_tile_matrix";
NSString * const TM_COLUMN_PK1 = @"table_name";
NSString * const TM_COLUMN_PK2 = @"zoom_level";
NSString * const TM_COLUMN_TABLE_NAME = @"table_name";
NSString * const TM_COLUMN_ZOOM_LEVEL = @"zoom_level";
NSString * const TM_COLUMN_MATRIX_WIDTH = @"matrix_width";
NSString * const TM_COLUMN_MATRIX_HEIGHT = @"matrix_height";
NSString * const TM_COLUMN_TILE_WIDTH = @"tile_width";
NSString * const TM_COLUMN_TILE_HEIGHT = @"tile_height";
NSString * const TM_COLUMN_PIXEL_X_SIZE = @"pixel_x_size";
NSString * const TM_COLUMN_PIXEL_Y_SIZE = @"pixel_y_size";

@implementation GPKGTileMatrix

-(void) setContents: (GPKGContents *) contents{
    if(contents != nil){
        // Verify the Contents have a tiles data type (Spec Requirement 42)
        enum GPKGContentsDataType dataType = contents.getContentsDataType;
        if(dataType != TILES){
            [NSException raise:@"Contents Type" format:@"The Contents of a Tile Matrix must have a data type of tiles"];
        }
        self.tableName = contents.tableName;
    }else{
        self.tableName = nil;
    }
}

-(void) setZoomLevel:(NSNumber *)zoomLevel{
    [self validateValuesWithColumn:TM_COLUMN_ZOOM_LEVEL andValue:zoomLevel andAllowZero:true];
    _zoomLevel = zoomLevel;
}

-(void) setMatrixWidth:(NSNumber *)matrixWidth{
    [self validateValuesWithColumn:TM_COLUMN_MATRIX_WIDTH andValue:matrixWidth andAllowZero:false];
    _matrixWidth = matrixWidth;
}

-(void) setMatrixHeight:(NSNumber *)matrixHeight{
    [self validateValuesWithColumn:TM_COLUMN_MATRIX_HEIGHT andValue:matrixHeight andAllowZero:false];
    _matrixHeight = matrixHeight;
}

-(void) setTileWidth:(NSNumber *)tileWidth{
    [self validateValuesWithColumn:TM_COLUMN_TILE_WIDTH andValue:tileWidth andAllowZero:false];
    _tileWidth = tileWidth;
}

-(void) setTileHeight:(NSNumber *)tileHeight{
    [self validateValuesWithColumn:TM_COLUMN_TILE_HEIGHT andValue:tileHeight andAllowZero:false];
    _tileHeight = tileHeight;
}

-(void) setPixelXSize:(NSDecimalNumber *)pixelXSize{
    [self validateValuesWithColumn:TM_COLUMN_PIXEL_X_SIZE andValue:pixelXSize];
    _pixelXSize = pixelXSize;
}

-(void) setPixelYSize:(NSDecimalNumber *)pixelYSize{
    [self validateValuesWithColumn:TM_COLUMN_PIXEL_Y_SIZE andValue:pixelYSize];
    _pixelYSize = pixelYSize;
}

-(void) validateValuesWithColumn: (NSString *) column andValue: (NSNumber *) value andAllowZero: (BOOL) allowZero{
    int intValue = [value intValue];
    if(intValue < 0 || (intValue == 0 && !allowZero)){
        [NSException raise:@"Illegal Value" format:@"%@ value must be greater than %@0: %@", column, (allowZero ? @"or equal to " : @""), value];
    }
}

-(void) validateValuesWithColumn: (NSString *) column andValue: (NSDecimalNumber *) value{
    double doubleValue = [value doubleValue];
    if(doubleValue < 0.0){
        [NSException raise:@"Illegal Value" format:@"%@ value must be greater than 0: %@", column, value];
    }
}

@end
