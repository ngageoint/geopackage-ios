//
//  GPKGFeatureColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureColumn.h"

@implementation GPKGFeatureColumn

+(GPKGFeatureColumn *) createPrimaryKeyColumnWithIndex: (int) index
                                               andName: (NSString *) name{
    return [[GPKGFeatureColumn alloc] initWithIndex:index andName:name andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:nil andPrimaryKey:true andGeometryType:WKB_NONE];
}

+(GPKGFeatureColumn *) createGeometryColumnWithIndex: (int) index
                                             andName: (NSString *) name
                                     andGeometryType: (enum WKBGeometryType) type
                                          andNotNull: (BOOL) notNull
                                     andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGFeatureColumn alloc] initWithIndex:index andName:name andDataType:GPKG_DT_GEOMETRY andMax:nil andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false andGeometryType:type];
}

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:nil andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                      andMax: (NSNumber *) max
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGFeatureColumn alloc] initWithIndex:index andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false andGeometryType:WKB_NONE];
}

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey
              andGeometryType: (enum WKBGeometryType) geometryType{
    self = [super initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
    if(self != nil){
        self.geometryType = geometryType;
        if(geometryType == WKB_NONE && dataType == GPKG_DT_GEOMETRY){
            [NSException raise:@"Data or Geometry Type" format:@"Data or Geometry Type is required to create column: %@", name];
        }
    }
    return self;
}

-(NSString *) getTypeName{
    NSString * type = nil;
    if([self isGeometry]){
        type = [WKBGeometryTypes name:self.geometryType];
    }else {
        type = [super getTypeName];
    }
    return type;
}

-(BOOL) isGeometry
{
    return self.geometryType != WKB_NONE;
}

@end
