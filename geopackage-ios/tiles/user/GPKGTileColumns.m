//
//  GPKGTileColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileColumns.h"

NSString * const GPKG_TC_COLUMN_ID = @"id";
NSString * const GPKG_TC_COLUMN_ZOOM_LEVEL = @"zoom_level";
NSString * const GPKG_TC_COLUMN_TILE_COLUMN = @"tile_column";
NSString * const GPKG_TC_COLUMN_TILE_ROW = @"tile_row";
NSString * const GPKG_TC_COLUMN_TILE_DATA = @"tile_data";

@implementation GPKGTileColumns

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    return [self initWithTable:tableName andColumns:columns andCustom:NO];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom{
    self = [super initWithTable:tableName andColumns:columns andCustom:custom];
    if(self != nil){
        _zoomLevelIndex = -1;
        _tileColumnIndex = -1;
        _tileRowIndex = -1;
        _tileDataIndex = -1;
        [self updateColumns];
    }
    return self;
}

-(instancetype) initWithTileColumns: (GPKGTileColumns *) tileColumns{
    self = [super initWithUserColumns:tileColumns];
    if(self != nil){
        _zoomLevelIndex = tileColumns.zoomLevelIndex;
        _tileColumnIndex = tileColumns.tileColumnIndex;
        _tileRowIndex = tileColumns.tileRowIndex;
        _tileDataIndex = tileColumns.tileDataIndex;
    }
    return self;
}

-(void) updateColumns{
    [super updateColumns];
    
    // Find the required columns
    
    NSNumber *zoomLevel = [self columnIndexWithColumnName:GPKG_TC_COLUMN_ZOOM_LEVEL andRequired:NO];
    if(!self.custom){
        [self missingCheckWithIndex:zoomLevel andColumn:GPKG_TC_COLUMN_ZOOM_LEVEL];
    }
    if(zoomLevel != nil){
        int zoomLevelIndex = [zoomLevel intValue];
        [self typeCheckWithExpected:GPKG_DT_INTEGER andColumn:[self columnWithIndex:zoomLevelIndex]];
        _zoomLevelIndex = zoomLevelIndex;
    }
    
    NSNumber *tileColumn = [self columnIndexWithColumnName:GPKG_TC_COLUMN_TILE_COLUMN andRequired:NO];
    if(!self.custom){
        [self missingCheckWithIndex:tileColumn andColumn:GPKG_TC_COLUMN_TILE_COLUMN];
    }
    if(tileColumn != nil){
        int tileColumnIndex = [tileColumn intValue];
        [self typeCheckWithExpected:GPKG_DT_INTEGER andColumn:[self columnWithIndex:tileColumnIndex]];
        _tileColumnIndex = tileColumnIndex;
    }
    
    NSNumber *tileRow = [self columnIndexWithColumnName:GPKG_TC_COLUMN_TILE_ROW andRequired:NO];
    if(!self.custom){
        [self missingCheckWithIndex:tileRow andColumn:GPKG_TC_COLUMN_TILE_ROW];
    }
    if(tileRow != nil){
        int tileRowIndex = [tileRow intValue];
        [self typeCheckWithExpected:GPKG_DT_INTEGER andColumn:[self columnWithIndex:tileRowIndex]];
        _tileRowIndex = tileRowIndex;
    }
    
    NSNumber *tileData = [self columnIndexWithColumnName:GPKG_TC_COLUMN_TILE_DATA andRequired:NO];
    if(!self.custom){
        [self missingCheckWithIndex:tileData andColumn:GPKG_TC_COLUMN_TILE_DATA];
    }
    if(tileData != nil){
        int tileDataIndex = [tileData intValue];
        [self typeCheckWithExpected:GPKG_DT_BLOB andColumn:[self columnWithIndex:tileDataIndex]];
        _tileDataIndex = tileDataIndex;
    }
    
}

-(BOOL) hasZoomLevelColumn{
    return self.zoomLevelIndex >= 0;
}

-(GPKGTileColumn *) zoomLevelColumn{
    GPKGTileColumn *column = nil;
    if([self hasZoomLevelColumn]){
        column = (GPKGTileColumn *) [self columnWithIndex:self.zoomLevelIndex];
    }
    return column;
}

-(BOOL) hasTileColumnColumn{
    return self.tileColumnIndex >= 0;
}

-(GPKGTileColumn *) tileColumnColumn{
    GPKGTileColumn *column = nil;
    if([self hasTileColumnColumn]){
        column = (GPKGTileColumn *) [self columnWithIndex:self.tileColumnIndex];
    }
    return column;
}

-(BOOL) hasTileRowColumn{
    return self.tileRowIndex >= 0;
}

-(GPKGTileColumn *) tileRowColumn{
    GPKGTileColumn *column = nil;
    if([self hasTileRowColumn]){
        column = (GPKGTileColumn *) [self columnWithIndex:self.tileRowIndex];
    }
    return column;
}

-(BOOL) hasTileDataColumn{
    return self.tileDataIndex >= 0;
}

-(GPKGTileColumn *) tileDataColumn{
    GPKGTileColumn *column = nil;
    if([self hasTileDataColumn]){
        column = (GPKGTileColumn *) [self columnWithIndex:self.tileDataIndex];
    }
    return column;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGTileColumns *tileColumns = [super mutableCopyWithZone:zone];
    return tileColumns;
}

@end
