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
    return [self createIdColumn:NO_INDEX];
}

+(GPKGTileColumn *) createIdColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_ID andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:false andDefaultValue:nil andPrimaryKey:true ];
}

+(GPKGTileColumn *) createZoomLevelColumn{
    return [self createZoomLevelColumn:NO_INDEX];
}

+(GPKGTileColumn *) createZoomLevelColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_ZOOM_LEVEL andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:[NSNumber numberWithInt:0] andPrimaryKey:false ];
}

+(GPKGTileColumn *) createTileColumnColumn{
    return [self createTileColumnColumn:NO_INDEX];
}

+(GPKGTileColumn *) createTileColumnColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_TILE_COLUMN andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:[NSNumber numberWithInt:0] andPrimaryKey:false ];
}

+(GPKGTileColumn *) createTileRowColumn{
    return [self createTileRowColumn:NO_INDEX];
}

+(GPKGTileColumn *) createTileRowColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_TILE_ROW andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:[NSNumber numberWithInt:0] andPrimaryKey:false ];
}

+(GPKGTileColumn *) createTileDataColumn{
    return [self createTileDataColumn:NO_INDEX];
}

+(GPKGTileColumn *) createTileDataColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_TILE_DATA andDataType:GPKG_DT_BLOB andMax:nil andNotNull:true andDefaultValue:nil andPrimaryKey:false ];
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
    return [[GPKGTileColumn alloc] initWithIndex:index andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false];
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
                andPrimaryKey: (BOOL) primaryKey{
    self = [super initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
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
