//
//  GPKGIconTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGIconTable.h"

NSString * const GPKG_IT_TABLE_NAME = @"nga_icon";
NSString * const GPKG_IT_COLUMN_NAME = @"nga_icon";
NSString * const GPKG_IT_COLUMN_DESCRIPTION = @"description";
NSString * const GPKG_IT_COLUMN_WIDTH = @"width";
NSString * const GPKG_IT_COLUMN_HEIGHT = @"height";
NSString * const GPKG_IT_COLUMN_ANCHOR_U = @"anchor_u";
NSString * const GPKG_IT_COLUMN_ANCHOR_V = @"anchor_v";

@implementation GPKGIconTable

-(instancetype) init{
    self = [super initWithTable:GPKG_IT_TABLE_NAME andColumns:[GPKGIconTable createColumns]];
    return self;
}

-(instancetype) initWithTable: (GPKGUserCustomTable *) table{
    self = [super initWithTable:table];
    return self;
}

/**
 * Create the icon columns
 *
 * @return columns
 */
+(NSArray *) createColumns{
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [NSMutableArray array];
    [columns addObjectsFromArray:[self createRequiredColumns]];
    
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_IT_COLUMN_NAME andDataType:GPKG_DT_TEXT]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_IT_COLUMN_DESCRIPTION andDataType:GPKG_DT_TEXT]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_IT_COLUMN_WIDTH andDataType:GPKG_DT_REAL]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_IT_COLUMN_HEIGHT andDataType:GPKG_DT_REAL]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_IT_COLUMN_ANCHOR_U andDataType:GPKG_DT_REAL]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:GPKG_IT_COLUMN_ANCHOR_V andDataType:GPKG_DT_REAL]];
    
    return columns;
}

-(int) nameColumnIndex{
    return [self columnIndexWithColumnName:GPKG_IT_COLUMN_NAME];
}

-(GPKGUserCustomColumn *) nameColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_IT_COLUMN_NAME];
}

-(int) descriptionColumnIndex{
    return [self columnIndexWithColumnName:GPKG_IT_COLUMN_DESCRIPTION];
}

-(GPKGUserCustomColumn *) descriptionColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_IT_COLUMN_DESCRIPTION];
}

-(int) widthColumnIndex{
    return [self columnIndexWithColumnName:GPKG_IT_COLUMN_WIDTH];
}

-(GPKGUserCustomColumn *) widthColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_IT_COLUMN_WIDTH];
}

-(int) heightColumnIndex{
    return [self columnIndexWithColumnName:GPKG_IT_COLUMN_HEIGHT];
}

-(GPKGUserCustomColumn *) heightColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_IT_COLUMN_HEIGHT];
}

-(int) anchorUColumnIndex{
    return [self columnIndexWithColumnName:GPKG_IT_COLUMN_ANCHOR_U];
}

-(GPKGUserCustomColumn *) anchorUColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_IT_COLUMN_ANCHOR_U];
}

-(int) anchorVColumnIndex{
    return [self columnIndexWithColumnName:GPKG_IT_COLUMN_ANCHOR_V];
}

-(GPKGUserCustomColumn *) anchorVColumn{
    return (GPKGUserCustomColumn *)[self columnWithColumnName:GPKG_IT_COLUMN_ANCHOR_V];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGIconTable *iconTable = [super mutableCopyWithZone:zone];
    return iconTable;
}

@end
