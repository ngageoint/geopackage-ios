//
//  GPKGFeatureRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureRow.h"

@implementation GPKGFeatureRow

-(instancetype) initWithFeatureTable: (GPKGFeatureTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumnTypes:columnTypes andValues:values];
    if(self != nil){
        self.featureTable = table;
    }
    return self;
}

-(instancetype) initWithFeatureTable: (GPKGFeatureTable *) table{
    self = [super initWithTable:table];
    if(self != nil){
        self.featureTable = table;
    }
    return self;
}

-(int) getGeometryColumnIndex{
    return self.featureTable.geometryIndex;
}

-(GPKGFeatureColumn *) getGeometryColumn{
    return [self.featureTable getGeometryColumn];
}

-(GPKGGeometryData *) getGeometry{
    GPKGGeometryData * geometryData = nil;
    NSObject * value = [self getValueWithIndex:self.featureTable.geometryIndex];
    if(value != nil){
        geometryData = (GPKGGeometryData *) value;
    }
    return geometryData;
}

-(void) setGeometry: (GPKGGeometryData *) geometryData{
    [self setValueWithIndex:self.featureTable.geometryIndex andValue:geometryData];
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    
    NSObject * objectValue = value;
    
    GPKGFeatureColumn * column = (GPKGFeatureColumn *)[self getColumnWithIndex:index];
    if([column isGeometry] && ![value isKindOfClass:[GPKGGeometryData class]]){
        
        if([value isKindOfClass:[NSData class]]){
            objectValue = [[GPKGGeometryData alloc] initWithData:(NSData *) value];
        } else{
            [NSException raise:@"Unsupported Geometry Value" format:@"Unsupported geometry column value type. column %@, value type: %@", column.name, NSStringFromClass([value class])];
        }
    }
    
    return objectValue;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{

    NSObject * dbValue = value;
    
    GPKGFeatureColumn * column = (GPKGFeatureColumn *)[self getColumnWithIndex:index];
    if([column isGeometry] && ![value isKindOfClass:[NSData class]]){
        
        if([value isKindOfClass:[GPKGGeometryData class]]){
            GPKGGeometryData * geometryData = (GPKGGeometryData *) value;
            dbValue = [geometryData toData];
        } else{
            [NSException raise:@"Unsupported Geometry Value" format:@"Unsupported geometry column value type. column %@, value type: %@", column.name, NSStringFromClass([value class])];
        }
    }
    
    return dbValue;
}

@end
