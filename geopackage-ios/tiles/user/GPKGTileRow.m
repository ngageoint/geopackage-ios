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

-(instancetype) initWithTileTable: (GPKGTileTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumns:columns andValues:values];
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

-(int) zoomLevelColumnIndex{
    return _tileTable.zoomLevelIndex;
}

-(GPKGTileColumn *) zoomLevelColumn{
    return [self.tileTable zoomLevelColumn];
}

-(int) zoomLevel{
    return [(NSNumber *)[self valueWithIndex:[self zoomLevelColumnIndex]] intValue];
}

-(void) setZoomLevel: (int) zoomLevel{
    [self setValueWithIndex:[self zoomLevelColumnIndex] andValue:[NSNumber numberWithInt:zoomLevel]];
}

-(int) tileColumnColumnIndex{
    return _tileTable.tileColumnIndex;
}

-(GPKGTileColumn *) tileColumnColumn{
    return [self.tileTable tileColumnColumn];
}

-(int) tileColumn{
    return [(NSNumber *)[self valueWithIndex:[self tileColumnColumnIndex]] intValue];
}

-(void) setTileColumn: (int) tileColumn{
    [self setValueWithIndex:[self tileColumnColumnIndex] andValue:[NSNumber numberWithInt:tileColumn]];
}

-(int) tileRowColumnIndex{
    return _tileTable.tileRowIndex;
}

-(GPKGTileColumn *) tileRowColumn{
    return [self.tileTable tileRowColumn];
}

-(int) tileRow{
    return [(NSNumber *)[self valueWithIndex:[self tileRowColumnIndex]] intValue];
}

-(void) setTileRow: (int) tileRow{
    [self setValueWithIndex:[self tileRowColumnIndex] andValue:[NSNumber numberWithInt:tileRow]];
}

-(int) tileDataColumnIndex{
    return _tileTable.tileDataIndex;
}

-(GPKGTileColumn *) tileDataColumn{
    return [self.tileTable tileDataColumn];
}

-(NSData *) tileData{
    return (NSData *)[self valueWithIndex:[self tileDataColumnIndex]];
}

-(void) setTileData: (NSData *) tileData{
    [self setValueWithIndex:[self tileDataColumnIndex] andValue:tileData];
}

-(UIImage *) tileDataImage{
    return [GPKGImageConverter toImage:[self tileData]];
}

-(UIImage *) tileDataImageWithScale: (CGFloat) scale{
    return [GPKGImageConverter toImage:[self tileData] withScale:scale];
}

-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format{
    [self setTileData:[GPKGImageConverter toData:image andFormat:format]];
}

-(void) setTileDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality{
    [self setTileData:[GPKGImageConverter toData:image andFormat:format andQuality:quality]];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGTileRow *tileRow = [super mutableCopyWithZone:zone];
    tileRow.tileTable = _tileTable;
    return tileRow;
}

@end
