//
//  GPKGTileTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileTable.h"
#import "GPKGUtils.h"
#import "GPKGTileColumn.h"
#import "GPKGContentsDataTypes.h"
#import "GPKGUniqueConstraint.h"

NSString * const GPKG_TT_COLUMN_ID = @"id";
NSString * const GPKG_TT_COLUMN_ZOOM_LEVEL = @"zoom_level";
NSString * const GPKG_TT_COLUMN_TILE_COLUMN = @"tile_column";
NSString * const GPKG_TT_COLUMN_TILE_ROW = @"tile_row";
NSString * const GPKG_TT_COLUMN_TILE_DATA = @"tile_data";

@implementation GPKGTileTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super initWithTable:tableName andColumns:columns];
    if(self != nil){
        
        NSNumber * zoomLevel = nil;
        NSNumber * tileColumn = nil;
        NSNumber * tileRow = nil;
        NSNumber * tileData = nil;
        
        // Build a unique constraint on zoom level, tile column, and tile data
        GPKGUniqueConstraint *uniqueConstraint = [[GPKGUniqueConstraint alloc] init];
        
        // Find the required columns
        for (GPKGTileColumn * column in columns) {
            
            NSString * columnName = column.name;
            int columnIndex = column.index;
            
            if ([columnName isEqualToString:GPKG_TT_COLUMN_ZOOM_LEVEL]) {
                [self duplicateCheckWithIndex:columnIndex andPreviousIndex:zoomLevel andColumn:GPKG_TT_COLUMN_ZOOM_LEVEL];
                [self typeCheckWithExpected:GPKG_DT_INTEGER andColumn:column];
                zoomLevel = [NSNumber numberWithInt:columnIndex];
                [uniqueConstraint addColumn:column];
            } else if ([columnName isEqualToString:GPKG_TT_COLUMN_TILE_COLUMN]) {
                [self duplicateCheckWithIndex:columnIndex andPreviousIndex:tileColumn andColumn:GPKG_TT_COLUMN_TILE_COLUMN];
                [self typeCheckWithExpected:GPKG_DT_INTEGER andColumn:column];
                tileColumn = [NSNumber numberWithInt:columnIndex];
                [uniqueConstraint addColumn:column];
            } else if ([columnName isEqualToString:GPKG_TT_COLUMN_TILE_ROW]) {
                [self duplicateCheckWithIndex:columnIndex andPreviousIndex:tileRow andColumn:GPKG_TT_COLUMN_TILE_ROW];
                [self typeCheckWithExpected:GPKG_DT_INTEGER andColumn:column];
                tileRow = [NSNumber numberWithInt:columnIndex];
                [uniqueConstraint addColumn:column];
            } else if ([columnName isEqualToString:GPKG_TT_COLUMN_TILE_DATA]) {
                [self duplicateCheckWithIndex:columnIndex andPreviousIndex:tileData andColumn:GPKG_TT_COLUMN_TILE_DATA];
                [self typeCheckWithExpected:GPKG_DT_BLOB andColumn:column];
                tileData = [NSNumber numberWithInt:columnIndex];
            }
        }
        
        // Verify the required columns were found
        [self missingCheckWithIndex:zoomLevel andColumn:GPKG_TT_COLUMN_ZOOM_LEVEL];
        self.zoomLevelIndex = [zoomLevel intValue];
        
        [self missingCheckWithIndex:tileColumn andColumn:GPKG_TT_COLUMN_TILE_COLUMN];
        self.tileColumnIndex = [tileColumn intValue];
        
        [self missingCheckWithIndex:tileRow andColumn:GPKG_TT_COLUMN_TILE_ROW];
        self.tileRowIndex = [tileRow intValue];
        
        [self missingCheckWithIndex:tileData andColumn:GPKG_TT_COLUMN_TILE_DATA];
        self.tileDataIndex = [tileData intValue];
        
        // Add the unique constraint
        [self addConstraint:uniqueConstraint];

    }
    return self;
}

-(NSString *) dataType{
    return GPKG_CDT_TILES_NAME;
}

-(void) validateContents:(GPKGContents *)contents{
    // Verify the Contents have a tiles data type
    enum GPKGContentsDataType dataType = [contents getContentsDataType];
    if (dataType != GPKG_CDT_TILES && dataType != GPKG_CDT_GRIDDED_COVERAGE) {
        [NSException raise:@"Invalid Contents Data Type" format:@"The Contents of a Tile Table must have a data type of %@ or %@", GPKG_CDT_TILES_NAME, GPKG_CDT_GRIDDED_COVERAGE_NAME];
    }
}

-(GPKGTileColumn *) getZoomLevelColumn{
    return (GPKGTileColumn *) [self getColumnWithIndex:self.zoomLevelIndex];
}

-(GPKGTileColumn *) getTileColumnColumn{
    return (GPKGTileColumn *) [self getColumnWithIndex:self.tileColumnIndex];
}

-(GPKGTileColumn *) getTileRowColumn{
    return (GPKGTileColumn *) [self getColumnWithIndex:self.tileRowIndex];
}

-(GPKGTileColumn *) getTileDataColumn{
    return (GPKGTileColumn *) [self getColumnWithIndex:self.tileDataIndex];
}

+(NSArray *) createRequiredColumns{
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    [GPKGUtils addObject:[GPKGTileColumn createIdColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createZoomLevelColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileColumnColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileRowColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileDataColumn] toArray:columns];
    
    return columns;
}

+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex{
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    [GPKGUtils addObject:[GPKGTileColumn createIdColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createZoomLevelColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileColumnColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileRowColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileDataColumn:startingIndex++] toArray:columns];

    return columns;
}

-(NSArray<GPKGTileColumn *> *) tileColumns{
    return (NSArray<GPKGTileColumn *> *) [super columns];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGTileTable *tileTable = [super mutableCopyWithZone:zone];
    tileTable.zoomLevelIndex = _zoomLevelIndex;
    tileTable.tileColumnIndex = _tileColumnIndex;
    tileTable.tileRowIndex = _tileRowIndex;
    tileTable.tileDataIndex = _tileDataIndex;
    return tileTable;
}

@end
