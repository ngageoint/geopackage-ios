//
//  GPKGFeatureColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"
#import "WKBGeometryTypes.h"

@interface GPKGFeatureColumn : GPKGUserColumn

@property (nonatomic) enum WKBGeometryType geometryType;

+(GPKGFeatureColumn *) createPrimaryKeyColumnWithIndex: (int) index
                      andName: (NSString *) name;

+(GPKGFeatureColumn *) createGeometryColumnWithIndex: (int) index
                      andName: (NSString *) name
                      andGeometryType: (enum WKBGeometryType) type
                      andNotNull: (BOOL) notNull
                      andDefaultValue: (NSObject *) defaultValue;

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                      andName: (NSString *) name
                      andDataType: (enum GPKGDataType) type
                      andNotNull: (BOOL) notNull
                      andDefaultValue: (NSObject *) defaultValue;

+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
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
                      andPrimaryKey: (BOOL) primaryKey
                      andGeometryType: (enum WKBGeometryType) geometryType;

-(BOOL) isGeometry;



@end
