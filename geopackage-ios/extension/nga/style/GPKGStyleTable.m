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
    
    [columns addObject:[GPKGAttributesColumn createPrimaryKeyColumnWithName:GPKG_ST_COLUMN_ID]];
    [columns addObject:[GPKGAttributesColumn createColumnWithName:GPKG_ST_COLUMN_NAME andDataType:GPKG_DT_TEXT]];
    [columns addObject:[GPKGAttributesColumn createColumnWithName:GPKG_ST_COLUMN_DESCRIPTION andDataType:GPKG_DT_TEXT]];
    [columns addObject:[GPKGAttributesColumn createColumnWithName:GPKG_ST_COLUMN_COLOR andDataType:GPKG_DT_TEXT]];
    [columns addObject:[GPKGAttributesColumn createColumnWithName:GPKG_ST_COLUMN_OPACITY andDataType:GPKG_DT_REAL]];
    [columns addObject:[GPKGAttributesColumn createColumnWithName:GPKG_ST_COLUMN_WIDTH andDataType:GPKG_DT_REAL]];
    [columns addObject:[GPKGAttributesColumn createColumnWithName:GPKG_ST_COLUMN_FILL_COLOR andDataType:GPKG_DT_TEXT]];
    [columns addObject:[GPKGAttributesColumn createColumnWithName:GPKG_ST_COLUMN_FILL_OPACITY andDataType:GPKG_DT_REAL]];
    
    return columns;
}

-(int) nameColumnIndex{
    return [self columnIndexWithColumnName:GPKG_ST_COLUMN_NAME];
}

-(GPKGAttributesColumn *) nameColumn{
    return (GPKGAttributesColumn *)[self columnWithColumnName:GPKG_ST_COLUMN_NAME];
}

-(int) descriptionColumnIndex{
    return [self columnIndexWithColumnName:GPKG_ST_COLUMN_DESCRIPTION];
}

-(GPKGAttributesColumn *) descriptionColumn{
    return (GPKGAttributesColumn *)[self columnWithColumnName:GPKG_ST_COLUMN_DESCRIPTION];
}

-(int) colorColumnIndex{
    return [self columnIndexWithColumnName:GPKG_ST_COLUMN_COLOR];
}

-(GPKGAttributesColumn *) colorColumn{
    return (GPKGAttributesColumn *)[self columnWithColumnName:GPKG_ST_COLUMN_COLOR];
}

-(int) opacityColumnIndex{
    return [self columnIndexWithColumnName:GPKG_ST_COLUMN_OPACITY];
}

-(GPKGAttributesColumn *) opacityColumn{
    return (GPKGAttributesColumn *)[self columnWithColumnName:GPKG_ST_COLUMN_OPACITY];
}

-(int) widthColumnIndex{
    return [self columnIndexWithColumnName:GPKG_ST_COLUMN_WIDTH];
}

-(GPKGAttributesColumn *) widthColumn{
    return (GPKGAttributesColumn *)[self columnWithColumnName:GPKG_ST_COLUMN_WIDTH];
}

-(int) fillColorColumnIndex{
    return [self columnIndexWithColumnName:GPKG_ST_COLUMN_FILL_COLOR];
}

-(GPKGAttributesColumn *) fillColorColumn{
    return (GPKGAttributesColumn *)[self columnWithColumnName:GPKG_ST_COLUMN_FILL_COLOR];
}

-(int) fillOpacityColumnIndex{
    return [self columnIndexWithColumnName:GPKG_ST_COLUMN_FILL_OPACITY];
}

-(GPKGAttributesColumn *) fillOpacityColumn{
    return (GPKGAttributesColumn *)[self columnWithColumnName:GPKG_ST_COLUMN_FILL_OPACITY];
}

@end
