//
//  GPKGTileTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileTable.h"
#import "GPKGUtils.h"
#import "GPKGTileColumn.h"
#import "GPKGContentsDataTypes.h"
#import "GPKGUniqueConstraint.h"

@implementation GPKGTileTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super initWithColumns:[[GPKGTileColumns alloc] initWithTable:tableName andColumns:columns]];
    
    if(self != nil){
        
        // Build a unique constraint on zoom level, tile column, and tile data
        GPKGUniqueConstraint *uniqueConstraint = [[GPKGUniqueConstraint alloc] init];
        [uniqueConstraint addColumn:[[self tileColumns] zoomLevelColumn]];
        [uniqueConstraint addColumn:[[self tileColumns] tileColumnColumn]];
        [uniqueConstraint addColumn:[[self tileColumns] tileRowColumn]];
        
        // Add the unique constraint
        [self addConstraint:uniqueConstraint];
        
    }
    
    return self;
}

-(NSString *) dataType{
    return GPKG_CDT_TILES_NAME;
}

-(void) validateContents:(GPKGContents *)contents{
    // Verify the Contents have a tiles data type
    enum GPKGContentsDataType dataType = [contents contentsDataType];
    if (dataType != GPKG_CDT_TILES && dataType != GPKG_CDT_GRIDDED_COVERAGE) {
        [NSException raise:@"Invalid Contents Data Type" format:@"The Contents of a Tile Table must have a data type of %@ or %@", GPKG_CDT_TILES_NAME, GPKG_CDT_GRIDDED_COVERAGE_NAME];
    }
}

-(GPKGTileColumns *) tileColumns{
    return (GPKGTileColumns *) [super columns];
}

-(GPKGUserColumns *) createUserColumnsWithColumns: (NSArray<GPKGUserColumn *> *) columns{
    return [[GPKGTileColumns alloc] initWithTable:[self tableName] andColumns:columns andCustom:YES];
}

-(int) zoomLevelIndex{
    return [[self tileColumns] zoomLevelIndex];
}

-(GPKGTileColumn *) zoomLevelColumn{
    return [[self tileColumns] zoomLevelColumn];
}

-(int) tileColumnIndex{
    return [[self tileColumns] tileColumnIndex];
}

-(GPKGTileColumn *) tileColumnColumn{
    return [[self tileColumns] tileColumnColumn];
}

-(int) tileRowIndex{
    return [[self tileColumns] tileRowIndex];
}

-(GPKGTileColumn *) tileRowColumn{
    return [[self tileColumns] tileRowColumn];
}

-(int) tileDataIndex{
    return [[self tileColumns] tileDataIndex];
}

-(GPKGTileColumn *) tileDataColumn{
    return [[self tileColumns] tileDataColumn];
}

+(NSArray *) createRequiredColumns{
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    [GPKGUtils addObject:[GPKGTileColumn createIdColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createZoomLevelColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileColumnColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileRowColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileDataColumn] toArray:columns];
    
    return columns;
}

+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex{
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    [GPKGUtils addObject:[GPKGTileColumn createIdColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createZoomLevelColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileColumnColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileRowColumn:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileDataColumn:startingIndex++] toArray:columns];

    return columns;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGTileTable *tileTable = [super mutableCopyWithZone:zone];
    return tileTable;
}

@end
