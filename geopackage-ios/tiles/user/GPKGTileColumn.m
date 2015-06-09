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

+(GPKGTileColumn *) createIdColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_ID andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:false andDefaultValue:nil andPrimaryKey:true ];
}

+(GPKGTileColumn *) createZoomLevelColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_ZOOM_LEVEL andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:[NSNumber numberWithInt:0] andPrimaryKey:false ];
}

+(GPKGTileColumn *) createTileColumnColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_TILE_COLUMN andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:[NSNumber numberWithInt:0] andPrimaryKey:false ];
}

+(GPKGTileColumn *) createTileRowColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_TILE_ROW andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:[NSNumber numberWithInt:0] andPrimaryKey:false ];
}

+(GPKGTileColumn *) createTileDataColumn: (int) index{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:GPKG_TT_COLUMN_TILE_DATA andDataType:GPKG_DT_BLOB andMax:nil andNotNull:true andDefaultValue:nil andPrimaryKey:false ];
}

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:nil andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                      andMax: (NSNumber *) max
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGTileColumn alloc] initWithIndex:index andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false];
}

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey{
    self = [super initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
    if(self != nil){
        if(dataType == GPKG_DT_GEOMETRY){
            [NSException raise:@"Data Type" format:@"Data Type is required to create column: %@", name];
        }
    }
    return self;
}

@end
