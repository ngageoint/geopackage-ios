//
//  GPKGAttributesColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesColumn.h"

@implementation GPKGAttributesColumn

+(GPKGAttributesColumn *) createPrimaryKeyColumnWithIndex: (int) index
                                                  andName: (NSString *) name{
    return [[GPKGAttributesColumn alloc] initWithIndex:index andName:name andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:nil andPrimaryKey:true];
}

+(GPKGAttributesColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                     andNotNull: (BOOL) notNull
                                andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:nil andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGAttributesColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                         andMax: (NSNumber *) max
                                     andNotNull: (BOOL) notNull
                                andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGAttributesColumn alloc] initWithIndex:index andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false];
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

@end
