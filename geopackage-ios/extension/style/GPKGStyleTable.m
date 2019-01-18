//
//  GPKGStyleTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleTable.h"

NSString * const GPKG_ST_TABLE_NAME = @"nga_style";
NSString * const GPKG_ST_COLUMN_ID = @"id";
NSString * const GPKG_ST_COLUMN_NAME = @"name";
NSString * const GPKG_ST_COLUMN_DESCRIPTION = @"description";
NSString * const GPKG_ST_COLUMN_COLOR = @"color";
NSString * const GPKG_ST_COLUMN_OPACITY = @"opacity";
NSString * const GPKG_ST_COLUMN_WIDTH = @"width";
NSString * const GPKG_ST_COLUMN_FILL_COLOR = @"fill_color";
NSString * const GPKG_ST_COLUMN_FILL_OPACITY = @"fill_opacity";

@implementation GPKGStyleTable

-(instancetype) init{
    self = [super initWithTable:GPKG_ST_TABLE_NAME andColumns:[GPKGStyleTable createColumns]];
    return self;
}

-(instancetype) initWithTable: (GPKGAttributesTable *) table{
    self = [self init];
    if(self != nil){
        [self setContents:table.contents];
    }
    return self;
}

/**
 * Create the style columns
 *
 * @return columns
 */
+(NSArray *) createColumns{
    
    NSMutableArray<GPKGAttributesColumn *> *columns = [[NSMutableArray alloc] init];
    int index = 0;
    
    [columns addObject:[GPKGAttributesColumn createPrimaryKeyColumnWithIndex:index++ andName:GPKG_ST_COLUMN_ID]];
    [columns addObject:[GPKGAttributesColumn createColumnWithIndex:index++ andName:GPKG_ST_COLUMN_NAME andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGAttributesColumn createColumnWithIndex:index++ andName:GPKG_ST_COLUMN_DESCRIPTION andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGAttributesColumn createColumnWithIndex:index++ andName:GPKG_ST_COLUMN_COLOR andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGAttributesColumn createColumnWithIndex:index++ andName:GPKG_ST_COLUMN_OPACITY andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGAttributesColumn createColumnWithIndex:index++ andName:GPKG_ST_COLUMN_WIDTH andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGAttributesColumn createColumnWithIndex:index++ andName:GPKG_ST_COLUMN_FILL_COLOR andDataType:GPKG_DT_TEXT andNotNull:NO andDefaultValue:nil]];
    [columns addObject:[GPKGAttributesColumn createColumnWithIndex:index++ andName:GPKG_ST_COLUMN_FILL_OPACITY andDataType:GPKG_DT_REAL andNotNull:NO andDefaultValue:nil]];
    
    return columns;
}

-(int) nameColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_ST_COLUMN_NAME];
}

-(GPKGAttributesColumn *) nameColumn{
    return (GPKGAttributesColumn *)[self getColumnWithColumnName:GPKG_ST_COLUMN_NAME];
}

-(int) descriptionColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_ST_COLUMN_DESCRIPTION];
}

-(GPKGAttributesColumn *) descriptionColumn{
    return (GPKGAttributesColumn *)[self getColumnWithColumnName:GPKG_ST_COLUMN_DESCRIPTION];
}

-(int) colorColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_ST_COLUMN_COLOR];
}

-(GPKGAttributesColumn *) colorColumn{
    return (GPKGAttributesColumn *)[self getColumnWithColumnName:GPKG_ST_COLUMN_COLOR];
}

-(int) opacityColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_ST_COLUMN_OPACITY];
}

-(GPKGAttributesColumn *) opacityColumn{
    return (GPKGAttributesColumn *)[self getColumnWithColumnName:GPKG_ST_COLUMN_OPACITY];
}

-(int) widthColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_ST_COLUMN_WIDTH];
}

-(GPKGAttributesColumn *) widthColumn{
    return (GPKGAttributesColumn *)[self getColumnWithColumnName:GPKG_ST_COLUMN_WIDTH];
}

-(int) fillColorColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_ST_COLUMN_FILL_COLOR];
}

-(GPKGAttributesColumn *) fillColorColumn{
    return (GPKGAttributesColumn *)[self getColumnWithColumnName:GPKG_ST_COLUMN_FILL_COLOR];
}

-(int) fillOpacityColumnIndex{
    return [self getColumnIndexWithColumnName:GPKG_ST_COLUMN_FILL_OPACITY];
}

-(GPKGAttributesColumn *) fillOpacityColumn{
    return (GPKGAttributesColumn *)[self getColumnWithColumnName:GPKG_ST_COLUMN_FILL_OPACITY];
}

@end
