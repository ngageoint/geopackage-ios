//
//  GPKGTileColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"

@interface GPKGTileColumn : GPKGUserColumn

+(GPKGTileColumn *) createIdColumn: (int) index;

+(GPKGTileColumn *) createZoomLevelColumn: (int) index;

+(GPKGTileColumn *) createTileColumnColumn: (int) index;

+(GPKGTileColumn *) createTileRowColumn: (int) index;

+(GPKGTileColumn *) createTileDataColumn: (int) index;

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue;

+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                      andMax: (NSNumber *) max
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue;

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey;

@end
