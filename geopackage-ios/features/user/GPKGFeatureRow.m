//
//  GPKGFeatureRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureRow.h"

@implementation GPKGFeatureRow

-(instancetype) initWithFeatureTable: (GPKGFeatureTable *) table andColumns: (GPKGFeatureColumns *) columns andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumns:columns andValues:values];
    if(self != nil){
        self.featureTable = table;
        self.featureColumns = columns;
    }
    return self;
}

-(instancetype) initWithFeatureTable: (GPKGFeatureTable *) table{
    self = [super initWithTable:table];
    if(self != nil){
        self.featureTable = table;
        self.featureColumns = [table featureColumns];
    }
    return self;
}

-(int) geometryColumnIndex{
    return [self.featureColumns geometryIndex];
}

-(GPKGFeatureColumn *) geometryColumn{
    return [self.featureColumns geometryColumn];
}

-(NSString *) geometryColumnName{
    return [self.featureColumns geometryColumnName];
}

-(void) setValueWithIndex:(int)index andValue:(NSObject *)value{
    if(index == [self geometryColumnIndex] && [value isKindOfClass:[NSData class]]){
        NSData * data = (NSData *) value;
        value = [GPKGGeometryData createWithData:data];
    }
    [super setValueWithIndex:index andValue:value];
}

-(GPKGGeometryData *) geometry{
    GPKGGeometryData *geometryData = nil;
    NSObject *value = [self valueWithIndex:[self.featureColumns geometryIndex]];
    if(value != nil){
        geometryData = (GPKGGeometryData *) value;
    }
    return geometryData;
}

-(void) setGeometry: (GPKGGeometryData *) geometryData{
    [self setValueWithIndex:[self geometryColumnIndex] andValue:geometryData];
}

-(SFGeometry *) geometryValue{
    GPKGGeometryData *data = [self geometry];
    SFGeometry *geometry = nil;
    if(data != nil){
        geometry = data.geometry;
    }
    return geometry;
}

-(enum SFGeometryType) geometryType{
    SFGeometry *geometry = [self geometryValue];
    enum SFGeometryType geometryType = SF_NONE;
    if(geometry != nil){
        geometryType = geometry.geometryType;
    }
    return geometryType;
}

-(SFGeometryEnvelope *) geometryEnvelope{
    GPKGGeometryData *data = [self geometry];
    SFGeometryEnvelope *envelope = nil;
    if(data != nil){
        envelope = [data getOrBuildEnvelope];
    }
    return envelope;
}

-(NSObject *) toObjectValueWithIndex: (int) index andValue: (NSObject *) value{
    
    NSObject *objectValue = value;
    
    GPKGFeatureColumn * column = (GPKGFeatureColumn *)[self columnWithIndex:index];
    if([column isGeometry] && ![value isKindOfClass:[GPKGGeometryData class]]){
        
        if([value isKindOfClass:[NSData class]]){
            objectValue = [GPKGGeometryData createWithData:(NSData *) value];
        } else{
            [NSException raise:@"Unsupported Geometry Value" format:@"Unsupported geometry column value type. column %@, value type: %@", column.name, NSStringFromClass([value class])];
        }
    }
    
    return objectValue;
}

-(NSObject *) toDatabaseValueWithIndex: (int) index andValue: (NSObject *) value{

    NSObject *dbValue = value;
    
    GPKGFeatureColumn * column = (GPKGFeatureColumn *)[self columnWithIndex:index];
    if([column isGeometry] && ![value isKindOfClass:[NSData class]]){
        
        if([value isKindOfClass:[GPKGGeometryData class]]){
            GPKGGeometryData *geometryData = (GPKGGeometryData *) value;
            dbValue = [geometryData toData];
        } else{
            [NSException raise:@"Unsupported Geometry Value" format:@"Unsupported geometry column value type. column %@, value type: %@", column.name, NSStringFromClass([value class])];
        }
    }
    
    return dbValue;
}

-(NSObject *) copyValue: (NSObject *) value forColumn: (GPKGUserColumn *) column{
    
    NSObject *copyValue = nil;
    
    GPKGFeatureColumn *featureColumn = (GPKGFeatureColumn *) column;
    if([featureColumn isGeometry] && ![value isKindOfClass:[GPKGGeometryData class]]){
     
        if([value isKindOfClass:[GPKGGeometryData class]]){
            GPKGGeometryData *geometryData = (GPKGGeometryData *) value;
            @try {
                NSData *data = [geometryData toData];
                NSData *copyData = [data mutableCopy];
                copyValue = [GPKGGeometryData createWithData:copyData];
            } @catch (NSException *e) {
                NSLog(@"Failed to copy Geometry Data. column: %@, error: %@", column.name, [e description]);
            }
        }else{
            copyValue = [super copyValue:value forColumn:column];
        }
        
    }else{
        copyValue = [super copyValue:value forColumn:column];
    }
    
    return copyValue;
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGFeatureRow *featureRow = [super mutableCopyWithZone:zone];
    featureRow.featureTable = _featureTable;
    featureRow.featureColumns = _featureColumns;
    return featureRow;
}

@end
