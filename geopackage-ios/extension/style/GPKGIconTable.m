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
    
    NSMutableArray<GPKGUserCustomColumn *> *columns = [[NSMutableArray alloc] init];
    [columns addObjectsFromArray:[self createRequiredColumns]];
    
    int index = (int)columns.count;
    [columns addObject:[GPKGUserCustomColumn createColumnWithIndex:index++ andName:GPKG_IT_COLUMN_NAME andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithIndex:index++ andName:GPKG_IT_COLUMN_DESCRIPTION andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithIndex:index++ andName:GPKG_IT_COLUMN_WIDTH andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithIndex:index++ andName:GPKG_IT_COLUMN_HEIGHT andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithIndex:index++ andName:GPKG_IT_COLUMN_ANCHOR_U andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithIndex:index++ andName:GPKG_IT_COLUMN_ANCHOR_V andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    
    return columns;
}

-(int) nameColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_IT_COLUMN_NAME];
}

-(GPKGUserCustomColumn *) nameColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_IT_COLUMN_NAME];
}

-(int) descriptionColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_IT_COLUMN_DESCRIPTION];
}

-(GPKGUserCustomColumn *) descriptionColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_IT_COLUMN_DESCRIPTION];
}

-(int) widthColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_IT_COLUMN_WIDTH];
}

-(GPKGUserCustomColumn *) widthColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_IT_COLUMN_WIDTH];
}

-(int) heightColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_IT_COLUMN_HEIGHT];
}

-(GPKGUserCustomColumn *) heightColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_IT_COLUMN_HEIGHT];
}

-(int) anchorUColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_IT_COLUMN_ANCHOR_U];
}

-(GPKGUserCustomColumn *) anchorUColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_IT_COLUMN_ANCHOR_U];
}

-(int) anchorVColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_IT_COLUMN_ANCHOR_V];
}

-(GPKGUserCustomColumn *) anchorVColumn{
    return (GPKGUserCustomColumn *)[self getColumnWithColumnName:GPKG_IT_COLUMN_ANCHOR_V];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGIconTable *iconTable = [super mutableCopyWithZone:zone];
    return iconTable;
}

@end
