//
//  GPKGTileTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGTileColumn.h"

extern NSString * const GPKG_TT_COLUMN_ID;
extern NSString * const GPKG_TT_COLUMN_ZOOM_LEVEL;
extern NSString * const GPKG_TT_COLUMN_TILE_COLUMN;
extern NSString * const GPKG_TT_COLUMN_TILE_ROW;
extern NSString * const GPKG_TT_COLUMN_TILE_DATA;

@interface GPKGTileTable : GPKGUserTable

@property (nonatomic) int zoomLevelIndex;
@property (nonatomic) int tileColumnIndex;
@property (nonatomic) int tileRowIndex;
@property (nonatomic) int tileDataIndex;

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

-(GPKGTileColumn *) getZoomLevelColumn;

-(GPKGTileColumn *) getTileColumnColumn;

-(GPKGTileColumn *) getTileRowColumn;

-(GPKGTileColumn *) getTileDataColumn;

+(NSArray *) createRequiredColumns;

+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex;

@end
