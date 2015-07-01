//
//  GPKGTileDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileTable.h"
#import "GPKGTileRow.h"
#import "GPKGTileMatrix.h"
#import "GPKGTileGrid.h"

@interface GPKGTileDao : GPKGUserDao

@property (nonatomic, strong) GPKGTileMatrixSet * tileMatrixSet;
@property (nonatomic, strong) NSArray * tileMatrices;
@property (nonatomic, strong) NSDictionary * zoomLevelToTileMatrix;
@property (nonatomic) int minZoom;
@property (nonatomic) int maxZoom;
@property (nonatomic, strong) NSArray * widths;
@property (nonatomic, strong) NSArray * heights;

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGTileTable *) table andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet andTileMatrices: (NSArray *) tileMatrices;

-(GPKGTileTable *) getTileTable;

-(GPKGTileRow *) getTileRow: (GPKGResultSet *) results;

-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

-(GPKGTileRow *) newRow;

-(void) adjustTileMatrixLengths;

-(GPKGTileMatrix *) getTileMatrixWithZoomLevel: (int) zoomLevel;

-(GPKGTileRow *) queryForTileWithColumn: (int) column andRow: (int) row andZoomLevel: (int) zoomLevel;

-(GPKGResultSet *) queryforTileWithZoomLevel: (int) zoomLevel;

-(GPKGResultSet *) queryForTileDescending: (int) zoomLevel;

-(GPKGResultSet *) queryForTilesInColumn: (int) column andZoomLevel: (int) zoomLevel;

-(GPKGResultSet *) queryForTilesInRow: (int) row andZoomLevel: (int) zoomLevel;

-(NSNumber *) getZoomLevelWithLength: (double) length;

-(GPKGResultSet *) queryByTileGrid: (GPKGTileGrid *) tileGrid andZoomLevel: (int) zoomLevel;

-(int) deleteTileWithColumn: (int) column andRow: (int) row andZoomLevel: (int) zoomLevel;

-(int) countWithZoomLevel: (int) zoomLevel;

-(BOOL) isStandardWebMercatorFormat;

@end
