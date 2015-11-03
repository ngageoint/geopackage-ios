//
//  GPKGFeatureIndexManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexManager.h"
#import "GPKGFeatureIndexGeoPackageResults.h"
#import "GPKGFeatureIndexMetadataResults.h"

@interface GPKGFeatureIndexManager ()

@property (nonatomic, strong) GPKGFeatureTableIndex *featureTableIndex;
@property (nonatomic, strong) GPKGFeatureIndexer *featureIndexer;
@property (nonatomic, strong) NSMutableArray *indexLocationQueryOrder;

@end

@implementation GPKGFeatureIndexManager

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        self.featureIndexer = [[GPKGFeatureIndexer alloc] initWithFeatureDao:featureDao];

        self.indexLocation = GPKG_FIT_NONE;
        self.indexLocationQueryOrder = [[NSMutableArray alloc] initWithObjects:
                                        [GPKGFeatureIndexTypes name:GPKG_FIT_GEOPACKAGE],
                                        [GPKGFeatureIndexTypes name:GPKG_FIT_METADATA],
                                        nil];
    }
    return self;
}

-(void) close{
    [self.featureTableIndex close];
    [self.featureIndexer close];
}

-(GPKGFeatureTableIndex *) getFeatureTableIndex{
    return self.featureTableIndex;
}

-(GPKGFeatureIndexer *) getFeatureIndexer{
    return self.featureIndexer;
}

-(void) prioritizeQueryLocationWithType: (enum GPKGFeatureIndexType) featureIndexType{
    NSArray * featureIndexTypes = [[NSArray alloc] initWithObjects:[GPKGFeatureIndexTypes name:featureIndexType], nil];
    return [self prioritizeQueryLocationWithTypes:featureIndexTypes];
}

-(void) prioritizeQueryLocationWithTypes: (NSArray *) featureIndexTypes{
    
    // In reverse order for the types provided, remove each (if it exists) and add at the front
    for(int i = (int)featureIndexTypes.count - 1; i >= 0; i--){
        NSString * featureIndexType = featureIndexTypes[i];
        [self.indexLocationQueryOrder removeObject:featureIndexType];
        [self.indexLocationQueryOrder insertObject:featureIndexType atIndex:0];
    }
}

-(void) setProgress: (NSObject<GPKGProgress> *) progress{
    [self.featureTableIndex setProgress:progress];
    [self.featureIndexer setProgress:progress];
}

-(int) index{
    return [self indexWithFeatureIndexType:[self verifyIndexLocation] andForce:false];
}

-(int) indexWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    return [self indexWithFeatureIndexType:type andForce:false];
}

-(int) indexWithForce: (BOOL) force{
    return [self indexWithFeatureIndexType:[self verifyIndexLocation] andForce:force];
}

-(int) indexWithFeatureIndexType:(enum GPKGFeatureIndexType) type andForce: (BOOL) force{
    
    if(type == GPKG_FIT_NONE){
        [NSException raise:@"No Feature Index Type" format:@"Feature Index Type is required to index"];
    }
    int count = 0;
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex indexWithForce:force];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer indexWithForce:force];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    
    return count;
}

-(BOOL) indexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self indexWithFeatureIndexType:[self verifyIndexLocation] andFeatureRow:row];
}

-(BOOL) indexWithFeatureIndexType:(enum GPKGFeatureIndexType) type andFeatureRow: (GPKGFeatureRow *) row{
    BOOL indexed = false;
    if(type == GPKG_FIT_NONE){
        [NSException raise:@"No Feature Index Type" format:@"Feature Index Type is required to index"];
    }
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            indexed = [self.featureTableIndex indexFeatureRow:row];
            break;
        case GPKG_FIT_METADATA:
            indexed = [self.featureIndexer indexFeatureRow:row];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return indexed;
}

-(BOOL) deleteIndex{
    return [self deleteIndexWithFeatureIndexType:[self verifyIndexLocation]];
}

-(BOOL) deleteIndexWithFeatureIndexType:(enum GPKGFeatureIndexType) type{
    if(type == GPKG_FIT_NONE){
        [NSException raise:@"No Feature Index Type" format:@"Feature Index Type is required to delete index"];
    }
    BOOL deleted = false;
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            deleted = [self.featureTableIndex deleteIndex];
            break;
        case GPKG_FIT_METADATA:
            deleted = [self.featureIndexer deleteIndex];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return deleted;
}

-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithFeatureIndexType:[self verifyIndexLocation] andFeatureRow:row];
}

-(BOOL) deleteIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type andFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithFeatureIndexType:type andGeomId:[[row getId] intValue]];
}

-(BOOL) deleteIndexWithGeomId: (int) geomId{
    return [self deleteIndexWithFeatureIndexType:[self verifyIndexLocation] andGeomId:geomId];
}

-(BOOL) deleteIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type andGeomId: (int) geomId{
    if(type == GPKG_FIT_NONE){
        [NSException raise:@"No Feature Index Type" format:@"Feature Index Type is required to delete index"];
    }
    BOOL deleted = false;
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            deleted = [self.featureTableIndex deleteIndexWithGeomId:geomId] > 0;
            break;
        case GPKG_FIT_METADATA:
            deleted = [self.featureIndexer deleteIndexWithGeomId:[NSNumber numberWithInt:geomId]];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return deleted;
}

-(BOOL) isIndexed{
    BOOL indexed = false;
    for(NSString * typeName in self.indexLocationQueryOrder){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        indexed = [self isIndexedWithFeatureIndexType:type];
        if(indexed){
            break;
        }
    }
    return indexed;
}

-(BOOL) isIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    BOOL indexed = false;
    if(type == GPKG_FIT_NONE){
        indexed = [self isIndexed];
    }else{
        switch(type){
            case GPKG_FIT_GEOPACKAGE:
                indexed = [self.featureTableIndex isIndexed];
                break;
            case GPKG_FIT_METADATA:
                indexed = [self.featureIndexer isIndexed];
                break;
            default:
                [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
        }
    }
    return indexed;
}

-(NSDate *) getLastIndexed{
    NSDate * lastIndexed = nil;
    for(NSString * typeName in self.indexLocationQueryOrder){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        lastIndexed = [self getLastIndexedWithFeatureIndexType:type];
        if(lastIndexed != nil){
            break;
        }
    }
    return lastIndexed;
}

-(NSDate *) getLastIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    NSDate * lastIndexed = nil;
    if(type == GPKG_FIT_NONE){
        lastIndexed = [self getLastIndexed];
    }else{
        switch(type){
            case GPKG_FIT_GEOPACKAGE:
                lastIndexed = [self.featureTableIndex getLastIndexed];
                break;
            case GPKG_FIT_METADATA:
                lastIndexed = [self.featureIndexer getLastIndexed];
                break;
            default:
                [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
        }
    }
    return lastIndexed;
}

-(GPKGFeatureIndexResults *) query{
    GPKGFeatureIndexResults * results = nil;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            {
                GPKGResultSet * geometryIndexResults = [self.featureTableIndex query];
                results = [[GPKGFeatureIndexGeoPackageResults alloc] initWithFeatureTableIndex:self.featureTableIndex andResults:geometryIndexResults];
            }
            break;
        case GPKG_FIT_METADATA:
            {
                GPKGResultSet * geometryMetadataResults = [self.featureIndexer query];
                results = [[GPKGFeatureIndexMetadataResults alloc] initWithFeatureTableIndex:self.featureIndexer andResults:geometryMetadataResults];
            }
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return results;
}

-(int) count{
    int count = 0;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex count];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer count];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGFeatureIndexResults * results = nil;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            {
                GPKGResultSet * geometryIndexResults = [self.featureTableIndex queryWithBoundingBox:boundingBox];
                results = [[GPKGFeatureIndexGeoPackageResults alloc] initWithFeatureTableIndex:self.featureTableIndex andResults:geometryIndexResults];
            }
            break;
        case GPKG_FIT_METADATA:
            {
                GPKGResultSet * geometryMetadataResults = [self.featureIndexer queryWithBoundingBox:boundingBox];
                results = [[GPKGFeatureIndexMetadataResults alloc] initWithFeatureTableIndex:self.featureIndexer andResults:geometryMetadataResults];
            }
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    int count = 0;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex countWithBoundingBox:boundingBox];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer countWithBoundingBox:boundingBox];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope{
    GPKGFeatureIndexResults * results = nil;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            {
                GPKGResultSet * geometryIndexResults = [self.featureTableIndex queryWithGeometryEnvelope:envelope];
                results = [[GPKGFeatureIndexGeoPackageResults alloc] initWithFeatureTableIndex:self.featureTableIndex andResults:geometryIndexResults];
            }
            break;
        case GPKG_FIT_METADATA:
            {
                GPKGResultSet * geometryMetadataResults = [self.featureIndexer queryWithEnvelope:envelope];
                results = [[GPKGFeatureIndexMetadataResults alloc] initWithFeatureTableIndex:self.featureIndexer andResults:geometryMetadataResults];
            }
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return results;
}

-(int) countWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope{
    int count = 0;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex countWithGeometryEnvelope:envelope];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer countWithEnvelope:envelope];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    GPKGFeatureIndexResults * results = nil;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
        {
            GPKGResultSet * geometryIndexResults = [self.featureTableIndex queryWithBoundingBox:boundingBox andProjection:projection];
            results = [[GPKGFeatureIndexGeoPackageResults alloc] initWithFeatureTableIndex:self.featureTableIndex andResults:geometryIndexResults];
        }
            break;
        case GPKG_FIT_METADATA:
        {
            GPKGResultSet * geometryMetadataResults = [self.featureIndexer queryWithBoundingBox:boundingBox andProjection:projection];
            results = [[GPKGFeatureIndexMetadataResults alloc] initWithFeatureTableIndex:self.featureIndexer andResults:geometryMetadataResults];
        }
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    int count = 0;
    enum GPKGFeatureIndexType type = [self getIndexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex countWithBoundingBox:boundingBox andProjection:projection];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer countWithBoundingBox:boundingBox andProjection:projection];
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return count;
}

-(enum GPKGFeatureIndexType) verifyIndexLocation{
    if(self.indexLocation == GPKG_FIT_NONE){
        [NSException raise:@"No Index Location" format:@"Index Location is not set, set the location or call an index method specifying the location"];
    }
    return self.indexLocation;
}

-(enum GPKGFeatureIndexType) getIndexedType{
    
    enum GPKGFeatureIndexType indexType = GPKG_FIT_NONE;
    
    // Check for an indexed type
    for (NSString * typeName in self.indexLocationQueryOrder) {
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName: typeName];
        if([self isIndexedWithFeatureIndexType:type]){
            indexType = type;
            break;
        }
    }
    
    // Verify features are indexed
    if(indexType == GPKG_FIT_NONE){
        [NSException raise:@"Features Not Indexed" format:@"Features are not indexed. GeoPackage: %@, Table: %@", [self.featureTableIndex getGeoPackage].name, [self.featureTableIndex getTableName]];
    }
    
    return indexType;
}

@end
