//
//  GPKGFeatureColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureColumn.h"

@implementation GPKGFeatureColumn

+(GPKGFeatureColumn *) createPrimaryKeyColumnWithName: (NSString *) name{
    return [self createPrimaryKeyColumnWithIndex:NO_INDEX andName:name];
}

+(GPKGFeatureColumn *) createPrimaryKeyColumnWithIndex: (int) index
                                               andName: (NSString *) name{
    return [[GPKGFeatureColumn alloc] initWithIndex:index andName:name andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:nil andPrimaryKey:true andGeometryType:SF_NONE];
}

+(GPKGFeatureColumn *) createGeometryColumnWithName: (NSString *) name
                                    andGeometryType: (enum SFGeometryType) type{
    return [self createGeometryColumnWithIndex:NO_INDEX andName:name andGeometryType:type];
}

+(GPKGFeatureColumn *) createGeometryColumnWithIndex: (int) index andName: (NSString *) name
                                         andGeometryType: (enum SFGeometryType) type{
    return [self createGeometryColumnWithIndex:index andName:name andGeometryType:type andNotNull:NO andDefaultValue:nil];
}

+(GPKGFeatureColumn *) createGeometryColumnWithName: (NSString *) name
                                    andGeometryType: (enum SFGeometryType) type
                                         andNotNull: (BOOL) notNull
                                    andDefaultValue: (NSObject *) defaultValue{
    return [self createGeometryColumnWithIndex:NO_INDEX andName:name andGeometryType:type andNotNull:NO andDefaultValue:nil];
}

+(GPKGFeatureColumn *) createGeometryColumnWithIndex: (int) index
                                             andName: (NSString *) name
                                     andGeometryType: (enum SFGeometryType) type
                                          andNotNull: (BOOL) notNull
                                     andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGFeatureColumn alloc] initWithIndex:index andName:name andDataType:GPKG_DT_GEOMETRY andMax:nil andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false andGeometryType:type];
}

+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
                                andDataType: (enum GPKGDataType) type{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type];
}

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type{
    return [self createColumnWithIndex:index andName:name andDataType:type andNotNull:NO andDefaultValue:nil];
}

+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
                                andDataType: (enum GPKGDataType) type
                                 andNotNull: (BOOL) notNull{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andNotNull:notNull];
}

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                  andNotNull: (BOOL) notNull{
    return [self createColumnWithIndex:index andName:name andDataType:type andNotNull:notNull andDefaultValue:nil];
}

+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
                                andDataType: (enum GPKGDataType) type
                                 andNotNull: (BOOL) notNull
                            andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:nil andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
                                andDataType: (enum GPKGDataType) type
                                     andMax: (NSNumber *) max{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andMax:max];
}

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                      andMax: (NSNumber *) max{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:max andNotNull:NO andDefaultValue:nil];
}

+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
                                andDataType: (enum GPKGDataType) type
                                     andMax: (NSNumber *) max
                                 andNotNull: (BOOL) notNull
                            andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                      andMax: (NSNumber *) max
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGFeatureColumn alloc] initWithIndex:index andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false andGeometryType:SF_NONE];
}

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey
              andGeometryType: (enum SFGeometryType) geometryType{
    self = [super initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
    if(self != nil){
        self.geometryType = geometryType;
        if((geometryType == SF_NONE || geometryType < 0) && dataType == GPKG_DT_GEOMETRY){
            [NSException raise:@"Data or Geometry Type" format:@"Data or Geometry Type is required to create column: %@", name];
        }
    }
    return self;
}

-(NSString *) getTypeName{
    NSString * type = nil;
    if([self isGeometry]){
        type = [SFGeometryTypes name:self.geometryType];
    }else {
        type = [super getTypeName];
    }
    return type;
}

-(BOOL) isGeometry
{
    return self.geometryType != SF_NONE && self.geometryType >= 0;
}

@end
