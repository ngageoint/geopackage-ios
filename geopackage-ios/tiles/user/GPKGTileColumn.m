//
//  GPKGTileColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileColumn.h"
#import "GPKGTileTable.h"

@implementation GPKGTileColumn

+(GPKGTileColumn *) createIdColumn{
    return [self createIdColumnWithAutoincrement:DEFAULT_AUTOINCREMENT];
}

+(GPKGTileColumn *) createIdColumnWithAutoincrement: (BOOL) autoincrement{
    return [self createIdColumnWithIndex:NO_INDEX andAutoincrement:autoincrement];
}

+(GPKGTileColumn *) createIdColumnWithIndex: (int) index{
    return [self createIdColumnWithIndex:index andAutoincrement:DEFAULT_AUTOINCREMENT];
}

+(GPKGTileColumn *) createIdColumnWithIndex: (int) index andAutoincrement: (BOOL) autoincrement{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TC_COLUMN_ID andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:NO andDefaultValue:nil andPrimaryKey:YES andAutoincrement:autoincrement];
}

+(GPKGTileColumn *) createZoomLevelColumn{
    return [self createZoomLevelColumnWithIndex:NO_INDEX];
}

+(GPKGTileColumn *) createZoomLevelColumnWithIndex: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TC_COLUMN_ZOOM_LEVEL andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:YES andDefaultValue:nil andPrimaryKey:NO andAutoincrement:NO];
}

+(GPKGTileColumn *) createTileColumnColumn{
    return [self createTileColumnColumnWithIndex:NO_INDEX];
}

+(GPKGTileColumn *) createTileColumnColumnWithIndex: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TC_COLUMN_TILE_COLUMN andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:YES andDefaultValue:nil andPrimaryKey:NO andAutoincrement:NO];
}

+(GPKGTileColumn *) createTileRowColumn{
    return [self createTileRowColumnWithIndex:NO_INDEX];
}

+(GPKGTileColumn *) createTileRowColumnWithIndex: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TC_COLUMN_TILE_ROW andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:YES andDefaultValue:nil andPrimaryKey:NO andAutoincrement:NO];
}

+(GPKGTileColumn *) createTileDataColumn{
    return [self createTileDataColumnWithIndex:NO_INDEX];
}

+(GPKGTileColumn *) createTileDataColumnWithIndex: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TC_COLUMN_TILE_DATA andDataType:GPKG_DT_BLOB andMax:nil andNotNull:YES andDefaultValue:nil andPrimaryKey:NO andAutoincrement:NO];
}

+(GPKGTileColumn *) createColumnWithName: (NSString *) name
                             andDataType: (enum GPKGDataType) type{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type];
}

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                  andName: (NSString *) name
                              andDataType: (enum GPKGDataType) type{
    return [self createColumnWithIndex:index andName:name andDataType:type andNotNull:NO andDefaultValue:nil];
}

+(GPKGTileColumn *) createColumnWithName: (NSString *) name
                             andDataType: (enum GPKGDataType) type
                              andNotNull: (BOOL) notNull{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andNotNull:notNull];
}

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                  andName: (NSString *) name
                              andDataType: (enum GPKGDataType) type
                               andNotNull: (BOOL) notNull{
    return [self createColumnWithIndex:index andName:name andDataType:type andNotNull:notNull andDefaultValue:nil];
}

+(GPKGTileColumn *) createColumnWithName: (NSString *) name
                             andDataType: (enum GPKGDataType) type
                              andNotNull: (BOOL) notNull
                         andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:nil andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGTileColumn *) createColumnWithName: (NSString *) name
                             andDataType: (enum GPKGDataType) type
                                  andMax: (NSNumber *) max{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andMax:max];
}

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                  andName: (NSString *) name
                              andDataType: (enum GPKGDataType) type
                                   andMax: (NSNumber *) max{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:max andNotNull:NO andDefaultValue:nil];
}

+(GPKGTileColumn *) createColumnWithName: (NSString *) name
                             andDataType: (enum GPKGDataType) type
                                  andMax: (NSNumber *) max
                              andNotNull: (BOOL) notNull
                         andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                      andMax: (NSNumber *) max
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:NO andAutoincrement:NO];
}

+(GPKGTileColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn{
    return [[GPKGTileColumn alloc] initWithTableColumn:tableColumn];
}

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey
                andAutoincrement: (BOOL) autoincrement{
    self = [super initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey andAutoincrement:autoincrement];
    return self;
}

-(instancetype) initWithTableColumn: (GPKGTableColumn *) tableColumn{
    self = [super initWithTableColumn:tableColumn];
    return self;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGTileColumn *tileColumn = [super mutableCopyWithZone:zone];
    return tileColumn;
}

@end
