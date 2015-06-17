//
//  GPKGTileRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserRow.h"
#import "GPKGTileTable.h"
#import "GPKGTileColumn.h"
#import <UIKit/UIKit.h>
#import "GPKGCompressFormats.h"

@interface GPKGTileRow : GPKGUserRow

@property (nonatomic, strong) GPKGTileTable *tileTable;

-(instancetype) initWithTileTable: (GPKGTileTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

-(instancetype) initWithTileTable: (GPKGTileTable *) table;

-(int) getZoomLevelColumnIndex;

-(GPKGTileColumn *) getZoomLevelColumn;

-(int) getZoomLevel;

-(void) setZoomLevel: (int) zoomLevel;

-(int) getTileColumnColumnIndex;

-(GPKGTileColumn *) getTileColumnColumn;

-(int) getTileColumn;

-(void) setTileColumn: (int) tileColumn;

-(int) getTileRowColumnIndex;

-(GPKGTileColumn *) getTileRowColumn;

-(int) getTileRow;

-(void) setTileRow: (int) tileRow;

-(int) getTileDataColumnIndex;

-(GPKGTileColumn *) getTileDataColumn;

-(NSData *) getTileData;

-(void) setTileData: (NSData *) tileData;

-(UIImage *) getTileDataImage;

-(UIImage *) getTileDataImageWithScale: (CGFloat) scale;

-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format;

-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality;

@end
