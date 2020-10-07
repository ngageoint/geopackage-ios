//
//  GPKGTileTableMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileTableMetadata.h"
#import "GPKGContentsDataTypes.h"

@implementation GPKGTileTableMetadata

static enum GPKGContentsDataType defaultDataType = GPKG_CDT_TILES;

+(GPKGTileTableMetadata *) create{
    return [[GPKGTileTableMetadata alloc] init];
}

+(GPKGTileTableMetadata *) createWithAutoincrement: (BOOL) autoincrement{
    return [[GPKGTileTableMetadata alloc] initWithTable:nil andAutoincrement:autoincrement andContentsBoundingBox:nil andContentsSrsId:nil andTileBoundingBox:nil andTileSrsId:nil];
}

+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithTable:tableName andContentsBoundingBox:nil andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithTable:tableName andAutoincrement:autoincrement andContentsBoundingBox:nil andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithTable:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithTable:tableName andAutoincrement:autoincrement andContentsBoundingBox:contentsBoundingBox andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithTable:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithTable:tableName andAutoincrement:autoincrement andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithDataType:dataType andTable:tableName andContentsBoundingBox:nil andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithDataType:dataType andTable:tableName andAutoincrement:autoincrement andContentsBoundingBox:nil andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithDataType:dataType andTable:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithDataType:dataType andTable:tableName andAutoincrement:autoincrement andContentsBoundingBox:contentsBoundingBox andContentsSrsId:nil andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithDataType:dataType andTable:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [[GPKGTileTableMetadata alloc] initWithDataType:dataType andTable:tableName andAutoincrement:autoincrement andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [self initWithDataType:nil andTable:tableName andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    self = [super init];
    if(self != nil){
        self.dataType = dataType;
        self.tableName = tableName;
        self.contentsBoundingBox = contentsBoundingBox;
        self.contentsSrsId = contentsSrsId;
        self.tileBoundingBox = tileBoundingBox;
        self.tileSrsId = tileSrsId;
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    return [self initWithDataType:nil andTable:tableName andAutoincrement:autoincrement andContentsBoundingBox:contentsBoundingBox andContentsSrsId:contentsSrsId andTileBoundingBox:tileBoundingBox andTileSrsId:tileSrsId];
}

-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId{
    self = [super init];
    if(self != nil){
        self.dataType = dataType;
        self.tableName = tableName;
        self.autoincrement = autoincrement;
        self.contentsBoundingBox = contentsBoundingBox;
        self.contentsSrsId = contentsSrsId;
        self.tileBoundingBox = tileBoundingBox;
        self.tileSrsId = tileSrsId;
    }
    return self;
}

-(NSString *) defaultDataType{
    return [GPKGContentsDataTypes name:defaultDataType];
}

-(NSArray<GPKGUserColumn *> *) buildColumns{
    
    NSArray<GPKGUserColumn *> *tileColumns = [self columns];
    
    if(tileColumns == nil){
        tileColumns = [GPKGTileTable createRequiredColumnsWithAutoincrement:self.autoincrement];
    }
    
    return tileColumns;
}

-(GPKGBoundingBox *) contentsBoundingBox{
    return _contentsBoundingBox != nil ? _contentsBoundingBox : self.tileBoundingBox;
}

-(NSNumber *) contentsSrsId{
    return _contentsSrsId != nil ? _contentsSrsId : self.tileSrsId;
}

@end
