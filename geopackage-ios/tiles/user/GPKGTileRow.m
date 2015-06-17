//
//  GPKGTileRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileRow.h"
#import "GPKGImageConverter.h"

@implementation GPKGTileRow

-(instancetype) initWithTileTable: (GPKGTileTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumnTypes:columnTypes andValues:values];
    if(self != nil){
        self.tileTable = table;
    }
    return self;
}

-(instancetype) initWithTileTable: (GPKGTileTable *) table{
    self = [super initWithTable:table];
    if(self != nil){
        self.tileTable = table;
    }
    return self;
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{
    return value;
}

-(int) getZoomLevelColumnIndex{
    return self.tileTable.zoomLevelIndex;
}

-(GPKGTileColumn *) getZoomLevelColumn{
    return [self.tileTable getZoomLevelColumn];
}

-(int) getZoomLevel{
    return [(NSNumber *)[self getValueWithIndex:[self getZoomLevelColumnIndex]] intValue];
}

-(void) setZoomLevel: (int) zoomLevel{
    [self setValueWithIndex:[self getZoomLevelColumnIndex] andValue:[NSNumber numberWithInt:zoomLevel]];
}

-(int) getTileColumnColumnIndex{
    return self.tileTable.tileColumnIndex;
}

-(GPKGTileColumn *) getTileColumnColumn{
    return [self.tileTable getTileColumnColumn];
}

-(int) getTileColumn{
    return [(NSNumber *)[self getValueWithIndex:[self getTileColumnColumnIndex]] intValue];
}

-(void) setTileColumn: (int) tileColumn{
    [self setValueWithIndex:[self getTileColumnColumnIndex] andValue:[NSNumber numberWithInt:tileColumn]];
}

-(int) getTileRowColumnIndex{
    return self.tileTable.tileRowIndex;
}

-(GPKGTileColumn *) getTileRowColumn{
    return [self.tileTable getTileRowColumn];
}

-(int) getTileRow{
    return [(NSNumber *)[self getValueWithIndex:[self getTileRowColumnIndex]] intValue];
}

-(void) setTileRow: (int) tileRow{
    [self setValueWithIndex:[self getTileRowColumnIndex] andValue:[NSNumber numberWithInt:tileRow]];
}

-(int) getTileDataColumnIndex{
    return self.tileTable.tileDataIndex;
}

-(GPKGTileColumn *) getTileDataColumn{
    return [self.tileTable getTileDataColumn];
}

-(NSData *) getTileData{
    return (NSData *)[self getValueWithIndex:[self getTileDataColumnIndex]];
}

-(void) setTileData: (NSData *) tileData{
    [self setValueWithIndex:[self getTileDataColumnIndex] andValue:tileData];
}

-(UIImage *) getTileDataImage{
    return [GPKGImageConverter toImage:[self getTileData]];
}

-(UIImage *) getTileDataImageWithScale: (CGFloat) scale{
    return [GPKGImageConverter toImage:[self getTileData] withScale:scale];
}

-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format{
    [self setTileData:[GPKGImageConverter toData:image andFormat:format]];
}

-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality{
    [self setTileData:[GPKGImageConverter toData:image andFormat:format andQuality:quality]];
}

@end
