//
//  GPKGFeatureRowData.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/15/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureRowData.h"
#import "SFGFeatureConverter.h"

@interface GPKGFeatureRowData ()

@property (nonatomic, strong) NSDictionary *values;
@property (nonatomic, strong) NSString *idColumn;
@property (nonatomic, strong) NSString *geometryColumn;

@end

@implementation GPKGFeatureRowData

-(instancetype) initWithValues: (NSDictionary *) values{
    self = [self initWithValues:values andGeometryColumnName:nil];
    return self;
}

-(instancetype) initWithValues: (NSDictionary *) values andGeometryColumnName: (NSString *) geometryColumn{
    self = [self initWithValues:values andIdColumnName:nil andGeometryColumnName:geometryColumn];
    return self;
}

-(instancetype) initWithValues: (NSDictionary *) values andIdColumnName: (NSString *) idColumn andGeometryColumnName: (NSString *) geometryColumn{
    self = [super init];
    if(self){
        _values = values;
        _idColumn = idColumn;
        _geometryColumn = geometryColumn;
    }
    return self;
}

-(NSDictionary *) values{
    return _values;
}

-(NSString *) idColumn{
    return _idColumn;
}

-(NSNumber *) id{
    NSNumber *id = nil;
    if(_idColumn != nil){
        id = (NSNumber *) [_values objectForKey:_idColumn];
    }
    return id;
}

-(NSString *) geometryColumn{
    return _geometryColumn;
}

-(GPKGGeometryData *) geometryData{
    GPKGGeometryData *geometryData = nil;
    if(_geometryColumn != nil){
        geometryData = (GPKGGeometryData *) [self.values objectForKey:_geometryColumn];
    }
    return geometryData;
}

-(SFGeometry *) geometry{
    SFGeometry *geometry = nil;
    GPKGGeometryData *geometryData = [self geometryData];
    if(geometryData != nil){
        geometry = geometryData.geometry;
    }
    return geometry;
}

-(enum SFGeometryType) geometryType{
    enum SFGeometryType geometryType = SF_NONE;
    SFGeometry *geometry = [self geometry];
    if(geometry != nil){
        geometryType = geometry.geometryType;
    }
    return geometryType;
}

-(SFGeometryEnvelope *) geometryEnvelope{
    SFGeometryEnvelope *envelope = nil;
    GPKGGeometryData *geometryData = [self geometryData];
    if(geometryData != nil){
        envelope = [geometryData getOrBuildEnvelope];
    }
    return envelope;
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
    
    NSMutableDictionary *jsonValues = [NSMutableDictionary dictionaryWithDictionary:_values];
    
    if(_geometryColumn != nil && [jsonValues objectForKey:_geometryColumn] != nil){
        
        if(includeGeometries || includePoints){
            SFGeometry *geometry = [self geometry];
            if(geometry != nil){
                if(includeGeometries || (includePoints && geometry.geometryType == SF_POINT)){
                    [jsonValues setObject:[SFGFeatureConverter simpleGeometryToMutableTree:geometry] forKey:_geometryColumn];
                }else{
                    [jsonValues setObject:[NSNull null] forKey:_geometryColumn];
                }
            }
        }else{
            [jsonValues setObject:[NSNull null] forKey:_geometryColumn];
        }
        
    }

    return jsonValues;
}

@end
