//
//  GPKGFeatureRowData.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/15/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureRowData.h"
#import "WKBGeometryJSONCompatible.h"

@interface GPKGFeatureRowData ()

@property (nonatomic, strong) NSDictionary *values;
@property (nonatomic, strong) NSString *geometryColumn;

@end

@implementation GPKGFeatureRowData

-(instancetype) initWithValues: (NSDictionary *) values andGeometryColumnName: (NSString *) geometryColumn{
    self = [super init];
    if(self){
        self.values = values;
        self.geometryColumn = geometryColumn;
    }
    return self;
}

-(NSDictionary *) getValues{
    return self.values;
}

-(NSString *) getGeometryColumn{
    return self.geometryColumn;
}

-(GPKGGeometryData *) getGeometryData{
    return (GPKGGeometryData *) [self.values objectForKey:self.geometryColumn];
}

-(WKBGeometry *) getGeometry{
    return [self getGeometryData].geometry;
}

-(NSObject *) jsonCompatible{
    return [self jsonCompatibleWithPoints:YES andGeometries:YES];
}

-(NSObject *) jsonCompatibleWithPoints: (BOOL) includePoints{
    return [self jsonCompatibleWithPoints:includePoints andGeometries:NO];
}

-(NSObject *) jsonCompatibleWithGeometries: (BOOL) includeGeometries{
    return [self jsonCompatibleWithPoints:includeGeometries andGeometries:includeGeometries];
}

-(NSObject *) jsonCompatibleWithPoints: (BOOL) includePoints andGeometries: (BOOL) includeGeometries{
    
    NSMutableDictionary * jsonValues = [[NSMutableDictionary alloc] init];
    
    for(NSString * key in [self.values allKeys]){
        NSObject * jsonValue = nil;
        NSObject * value = [self.values objectForKey:key];
        if([key isEqualToString:self.geometryColumn]){
            GPKGGeometryData * geometryData = (GPKGGeometryData *) value;
            if(geometryData.geometry != nil){
                if(includeGeometries || (includePoints && geometryData.geometry.geometryType == WKB_POINT)){
                    jsonValue = [WKBGeometryJSONCompatible getJSONCompatibleGeometry:geometryData.geometry];
                }
            }
        }else{
            jsonValue = value;
        }
        if(jsonValue != nil){
            [jsonValues setObject:jsonValue forKey:key];
        }
    }
    
    return jsonValues;
}

@end
