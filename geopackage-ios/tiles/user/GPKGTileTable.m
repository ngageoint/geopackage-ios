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

-(instancetype) initWithTable: (NSString *) tableName{
    return [self initWithTable:tableName andColumns:[GPKGTileTable createRequiredColumns]];
}

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
    return [self dataTypeWithDefault:GPKG_CDT_TILES_NAME];
}

-(void) validateContents:(GPKGContents *)contents{
    // Verify the Contents have a tiles data type
    if(![contents isTilesTypeOrUnknown]){
        [NSException raise:@"Invalid Contents Data Type" format:@"The Contents of a Tile Table must have a data type of %@. actual type: %@", GPKG_CDT_TILES_NAME, contents.dataType];
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
    return [self createRequiredColumnsWithAutoincrement:DEFAULT_AUTOINCREMENT];
}

+(NSArray *) createRequiredColumnsWithAutoincrement: (BOOL) autoincrement{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    [GPKGUtils addObject:[GPKGTileColumn createIdColumnWithAutoincrement:autoincrement] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createZoomLevelColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileColumnColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileRowColumn] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileDataColumn] toArray:columns];
    
    return columns;
}

+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex{
    return [self createRequiredColumnsWithStartingIndex:startingIndex andAutoincrement:DEFAULT_AUTOINCREMENT];
}

+(NSArray *) createRequiredColumnsWithStartingIndex: (int) startingIndex andAutoincrement: (BOOL) autoincrement{
    NSMutableArray *columns = [[NSMutableArray alloc] init];
    [GPKGUtils addObject:[GPKGTileColumn createIdColumnWithIndex:startingIndex++ andAutoincrement:autoincrement] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createZoomLevelColumnWithIndex:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileColumnColumnWithIndex:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileRowColumnWithIndex:startingIndex++] toArray:columns];
    [GPKGUtils addObject:[GPKGTileColumn createTileDataColumnWithIndex:startingIndex++] toArray:columns];

    return columns;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGTileTable *tileTable = [super mutableCopyWithZone:zone];
    return tileTable;
}

@end
