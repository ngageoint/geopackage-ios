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
#import "GPKGManualFeatureQuery.h"
#import "GPKGFeatureIndexRTreeResults.h"
#import "GPKGFeatureIndexFeatureResults.h"

@interface GPKGFeatureIndexManager ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic, strong) GPKGFeatureTableIndex *featureTableIndex;
@property (nonatomic, strong) GPKGFeatureIndexer *featureIndexer;
@property (nonatomic, strong) GPKGRTreeIndexTableDao *rTreeIndexTableDao;
@property (nonatomic, strong) GPKGManualFeatureQuery *manualFeatureQuery;
@property (nonatomic, strong) NSMutableArray *indexLocationQueryOrder;

@end

@implementation GPKGFeatureIndexManager

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTable: (NSString *) featureTable{
    return [self initWithGeoPackage:geoPackage andFeatureDao:[geoPackage featureDaoWithTableName:featureTable]];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
        self.featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        self.featureIndexer = [[GPKGFeatureIndexer alloc] initWithFeatureDao:featureDao];
        GPKGRTreeIndexExtension *rTreeExtension = [[GPKGRTreeIndexExtension alloc] initWithGeoPackage:geoPackage];
        self.rTreeIndexTableDao = [rTreeExtension tableDaoWithFeatureDao:featureDao];
        self.manualFeatureQuery = [[GPKGManualFeatureQuery alloc] initWithFeatureDao:featureDao];

        self.indexLocation = GPKG_FIT_NONE;
        self.indexLocationQueryOrder = [[NSMutableArray alloc] initWithObjects:
                                        [GPKGFeatureIndexTypes name:GPKG_FIT_RTREE],
                                        [GPKGFeatureIndexTypes name:GPKG_FIT_GEOPACKAGE],
                                        [GPKGFeatureIndexTypes name:GPKG_FIT_METADATA],
                                        nil];
        self.continueOnError = YES;
    }
    return self;
}

-(void) close{
    [self.featureTableIndex close];
    [self.featureIndexer close];
    //[self.rTreeIndexTableDao close];
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(GPKGFeatureTableIndex *) featureTableIndex{
    return _featureTableIndex;
}

-(GPKGFeatureIndexer *) featureIndexer{
    return _featureIndexer;
}

-(GPKGRTreeIndexTableDao *) rTreeIndexTableDao{
    return _rTreeIndexTableDao;
}

-(NSArray *) indexLocationQueryOrder{
    return _indexLocationQueryOrder;
}

-(void) prioritizeQueryLocationWithType: (enum GPKGFeatureIndexType) featureIndexType{
    NSArray * featureIndexTypes = [[NSArray alloc] initWithObjects:[GPKGFeatureIndexTypes name:featureIndexType], nil];
    return [self prioritizeQueryLocationWithTypes:featureIndexTypes];
}

-(void) prioritizeQueryLocationWithTypes: (NSArray *) featureIndexTypes{
    
    // In reverse order for the types provided, remove each (if it exists) and add at the front
    for(int i = (int)featureIndexTypes.count - 1; i >= 0; i--){
        NSString *featureIndexTypeString = featureIndexTypes[i];
        enum GPKGFeatureIndexType featureIndexType = [GPKGFeatureIndexTypes fromName:featureIndexTypeString];
        if((int)featureIndexType >= 0 && featureIndexType != GPKG_FIT_NONE){
            [_indexLocationQueryOrder removeObject:featureIndexTypeString];
            [_indexLocationQueryOrder insertObject:featureIndexTypeString atIndex:0];
        }
    }
}

-(void) setIndexLocationOrderWithTypes: (NSArray *) featureIndexTypes{
    
    NSMutableArray *queryOrder = [[NSMutableArray alloc] init];
    for(int i = 0; i < featureIndexTypes.count; i++){
        NSString *featureIndexTypeString = featureIndexTypes[i];
        enum GPKGFeatureIndexType featureIndexType = [GPKGFeatureIndexTypes fromName:featureIndexTypeString];
        if((int)featureIndexType >= 0 && featureIndexType != GPKG_FIT_NONE){
            [queryOrder addObject:featureIndexTypeString];
        }
    }
    // Update the query order set
    _indexLocationQueryOrder = queryOrder;
}

-(void) setProgress: (NSObject<GPKGProgress> *) progress{
    [self.featureTableIndex setProgress:progress];
    [self.featureIndexer setProgress:progress];
    [self.rTreeIndexTableDao setProgress:progress];
}

-(int) index{
    return [self indexWithFeatureIndexType:[self verifyIndexLocation] andForce:false];
}

-(int) indexFeatureIndexTypes: (NSArray<NSString *> *) types{
    int count = 0;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        int typeCount = [self indexWithFeatureIndexType:type];
        count = MAX(count, typeCount);
    }
    return count;
}

-(int) indexWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    return [self indexWithFeatureIndexType:type andForce:false];
}

-(int) indexWithForce: (BOOL) force{
    return [self indexWithFeatureIndexType:[self verifyIndexLocation] andForce:force];
}

-(int) indexWithForce: (BOOL) force andFeatureIndexTypes: (NSArray<NSString *> *) types{
    int count = 0;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        int typeCount = [self indexWithFeatureIndexType:type andForce:force];
        count = MAX(count, typeCount);
    }
    return count;
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
        case GPKG_FIT_RTREE:
            {
                BOOL rTreeIndexed = [self.rTreeIndexTableDao has];
                if(!rTreeIndexed || force){
                    if(rTreeIndexed){
                        [self.rTreeIndexTableDao delete];
                    }
                    [self.rTreeIndexTableDao create];
                    count = [self.rTreeIndexTableDao count];
                }
            }
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    
    return count;
}

-(BOOL) indexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self indexWithFeatureIndexType:[self verifyIndexLocation] andFeatureRow:row];
}

-(BOOL) indexWithFeatureRow: (GPKGFeatureRow *) row andFeatureIndexTypes: (NSArray<NSString *> *) types{
    BOOL indexed = false;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self indexWithFeatureIndexType:type andFeatureRow:row]){
            indexed = true;
        }
    }
    return indexed;
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
        case GPKG_FIT_RTREE:
            // Updated by triggers, ignore for RTree
            indexed = true;
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return indexed;
}

-(BOOL) deleteIndex{
    return [self deleteIndexWithFeatureIndexType:[self verifyIndexLocation]];
}

-(BOOL) deleteAllIndexes{
    return [self deleteIndexWithFeatureIndexTypes:self.indexLocationQueryOrder];
}

-(BOOL) deleteIndexWithFeatureIndexTypes: (NSArray<NSString *> *) types{
    BOOL deleted = false;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self deleteIndexWithFeatureIndexType:type]){
            deleted = true;
        }
    }
    return deleted;
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
        case GPKG_FIT_RTREE:
            [self.rTreeIndexTableDao delete];
            deleted = YES;
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return deleted;
}

-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithFeatureIndexType:[self verifyIndexLocation] andFeatureRow:row];
}

-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row andFeatureIndexTypes: (NSArray<NSString *> *) types{
    BOOL deleted = false;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self deleteIndexWithFeatureIndexType:type andFeatureRow:row]){
            deleted = true;
        }
    }
    return deleted;
}

-(BOOL) deleteIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type andFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithFeatureIndexType:type andGeomId:[row idValue]];
}

-(BOOL) deleteIndexWithGeomId: (int) geomId{
    return [self deleteIndexWithFeatureIndexType:[self verifyIndexLocation] andGeomId:geomId];
}

-(BOOL) deleteIndexWithGeomId: (int) geomId andFeatureIndexTypes: (NSArray<NSString *> *) types{
    BOOL deleted = false;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self deleteIndexWithFeatureIndexType:type andGeomId:geomId]){
            deleted = true;
        }
    }
    return deleted;
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
        case GPKG_FIT_RTREE:
            // Updated by triggers, ignore for RTree
            deleted = YES;
            break;
        default:
            [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
    }
    return deleted;
}

-(BOOL) retainIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    NSArray *retain = [[NSArray alloc] initWithObjects:[GPKGFeatureIndexTypes name:type], nil];
    return [self retainIndexWithFeatureIndexTypes:retain];
}

-(BOOL) retainIndexWithFeatureIndexTypes: (NSArray<NSString *> *) types{
    NSMutableArray *delete = [[NSMutableArray alloc] init];
    for(NSString *indexLocationType in self.indexLocationQueryOrder){
        if(![types containsObject:indexLocationType]){
            [delete addObject:indexLocationType];
        }
    }
    return [self deleteIndexWithFeatureIndexTypes:delete];
}

-(NSArray<NSString *> *) indexedTypes{
    NSMutableArray<NSString *> *indexed = [[NSMutableArray alloc] init];
    for(NSString *typeName in self.indexLocationQueryOrder){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self isIndexedWithFeatureIndexType:type]){
            [indexed addObject:typeName];
        }
    }
    return indexed;
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
            case GPKG_FIT_RTREE:
                indexed = [self.rTreeIndexTableDao has];
                break;
            default:
                [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
        }
    }
    return indexed;
}

-(NSDate *) lastIndexed{
    NSDate * lastIndexed = nil;
    for(NSString * typeName in self.indexLocationQueryOrder){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        lastIndexed = [self lastIndexedWithFeatureIndexType:type];
        if(lastIndexed != nil){
            break;
        }
    }
    return lastIndexed;
}

-(NSDate *) lastIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    NSDate * lastIndexed = nil;
    if(type == GPKG_FIT_NONE){
        lastIndexed = [self lastIndexed];
    }else{
        switch(type){
            case GPKG_FIT_GEOPACKAGE:
                lastIndexed = [self.featureTableIndex lastIndexed];
                break;
            case GPKG_FIT_METADATA:
                lastIndexed = [self.featureIndexer lastIndexed];
                break;
            case GPKG_FIT_RTREE:
                if([self.rTreeIndexTableDao has]){
                    // Updated by triggers, assume up to date
                    lastIndexed = [NSDate date];
                }
                break;
            default:
                [NSException raise:@"Unsupported Feature Index Type" format:@"Unsupported Feature Index Type: %u", type];
        }
    }
    return lastIndexed;
}

-(GPKGFeatureIndexResults *) query{
    return [self queryWithColumns:[self.featureDao columnNames]];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns{
    GPKGFeatureIndexResults * results = nil;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        GPKGResultSet *geoPackageResults = [self.featureTableIndex queryFeaturesWithColumns:columns];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geoPackageResults];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        GPKGResultSet *geometryMetadataResults = [self.featureIndexer queryFeaturesWithColumns:columns];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geometryMetadataResults];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        GPKGResultSet *rTreeResults = [self.rTreeIndexTableDao queryFeaturesWithColumns:columns];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:rTreeResults];
                    }
                    break;
                default:
                    {
                        [NSException raise:@"Unsupported Type" format:@"Unsupported feature index type: %@", [GPKGFeatureIndexTypes name:type]];
                    }
            }
            break;
        } @catch (NSException *exception) {
            if (self.continueOnError) {
                NSLog(@"Failed to query from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (results == nil) {
        GPKGResultSet *resultSet = [self.manualFeatureQuery queryWithColumns:columns];
        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:resultSet];
    }
    return results;
}

-(int) count{
    int count = 0;
    enum GPKGFeatureIndexType type = [self indexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex count];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer count];
            break;
        case GPKG_FIT_RTREE:
            count = [self.rTreeIndexTableDao count];
            break;
        default:
            count = [self.manualFeatureQuery countWithGeometries];
    }
    return count;
}

-(GPKGBoundingBox *) boundingBox{
    GPKGBoundingBox *bounds = nil;
    enum GPKGFeatureIndexType type = [self indexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            bounds = [self.featureTableIndex boundingBox];
            break;
        case GPKG_FIT_METADATA:
            bounds = [self.featureIndexer boundingBox];
            break;
        case GPKG_FIT_RTREE:
            bounds = [self.rTreeIndexTableDao boundingBox];
            break;
        default:
            bounds = [self.manualFeatureQuery boundingBox];
    }
    return bounds;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    GPKGBoundingBox *bounds = nil;
    enum GPKGFeatureIndexType type = [self indexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            bounds = [self.featureTableIndex boundingBoxInProjection:projection];
            break;
        case GPKG_FIT_METADATA:
            bounds = [self.featureIndexer boundingBoxInProjection:projection];
            break;
        case GPKG_FIT_RTREE:
            bounds = [self.rTreeIndexTableDao boundingBoxInProjection:projection];
            break;
        default:
            bounds = [self.manualFeatureQuery boundingBoxInProjection:projection];
    }
    return bounds;
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGFeatureIndexResults * results = nil;
    enum GPKGFeatureIndexType type = [self indexedType];
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
        case GPKG_FIT_RTREE:
            {
                GPKGResultSet *resultSet = [self.rTreeIndexTableDao queryWithBoundingBox:boundingBox];
                results = [[GPKGFeatureIndexRTreeResults alloc] initWithDao:self.rTreeIndexTableDao andResults:resultSet];
            }
            break;
        default:
            results = [self.manualFeatureQuery queryWithBoundingBox:boundingBox];
    }
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    int count = 0;
    enum GPKGFeatureIndexType type = [self indexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex countWithBoundingBox:boundingBox];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer countWithBoundingBox:boundingBox];
            break;
        case GPKG_FIT_RTREE:
            count = [self.rTreeIndexTableDao countWithBoundingBox:boundingBox];
            break;
        default:
            count = [self.manualFeatureQuery countWithBoundingBox:boundingBox];
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGFeatureIndexResults * results = nil;
    enum GPKGFeatureIndexType type = [self indexedType];
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
        case GPKG_FIT_RTREE:
            {
                GPKGResultSet *resultSet = [self.rTreeIndexTableDao queryWithEnvelope:envelope];
                results = [[GPKGFeatureIndexRTreeResults alloc] initWithDao:self.rTreeIndexTableDao andResults:resultSet];
            }
            break;
        default:
            results = [self.manualFeatureQuery queryWithGeometryEnvelope:envelope];
    }
    return results;
}

-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    int count = 0;
    enum GPKGFeatureIndexType type = [self indexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex countWithGeometryEnvelope:envelope];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer countWithEnvelope:envelope];
            break;
        case GPKG_FIT_RTREE:
            count = [self.rTreeIndexTableDao countWithEnvelope:envelope];
            break;
        default:
            count = [self.manualFeatureQuery countWithGeometryEnvelope:envelope];
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGFeatureIndexResults * results = nil;
    enum GPKGFeatureIndexType type = [self indexedType];
    switch(type){
        case GPKG_FIT_GEOPACKAGE:
            {
                GPKGResultSet * geometryIndexResults = [self.featureTableIndex queryWithBoundingBox:boundingBox inProjection:projection];
                results = [[GPKGFeatureIndexGeoPackageResults alloc] initWithFeatureTableIndex:self.featureTableIndex andResults:geometryIndexResults];
            }
            break;
        case GPKG_FIT_METADATA:
            {
                GPKGResultSet * geometryMetadataResults = [self.featureIndexer queryWithBoundingBox:boundingBox inProjection:projection];
                results = [[GPKGFeatureIndexMetadataResults alloc] initWithFeatureTableIndex:self.featureIndexer andResults:geometryMetadataResults];
            }
            break;
        case GPKG_FIT_RTREE:
            {
                GPKGResultSet *resultSet = [self.rTreeIndexTableDao queryWithBoundingBox:boundingBox inProjection:projection];
                results = [[GPKGFeatureIndexRTreeResults alloc] initWithDao:self.rTreeIndexTableDao andResults:resultSet];
            }
            break;
        default:
            results = [self.manualFeatureQuery queryWithBoundingBox:boundingBox inProjection:projection];
    }
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    int count = 0;
    enum GPKGFeatureIndexType type = [self indexedType];
    switch (type) {
        case GPKG_FIT_GEOPACKAGE:
            count = [self.featureTableIndex countWithBoundingBox:boundingBox inProjection:projection];
            break;
        case GPKG_FIT_METADATA:
            count = [self.featureIndexer countWithBoundingBox:boundingBox inProjection:projection];
            break;
        case GPKG_FIT_RTREE:
            count = [self.rTreeIndexTableDao countWithBoundingBox:boundingBox inProjection:projection];
            break;
        default:
            count = [self.manualFeatureQuery countWithBoundingBox:boundingBox inProjection:projection];
    }
    return count;
}

-(GPKGFeatureIndexLocation *) location{
    return [[GPKGFeatureIndexLocation alloc] initWithFeatureIndexManager:self];
}

-(enum GPKGFeatureIndexType) indexedType{
    
    enum GPKGFeatureIndexType indexType = GPKG_FIT_NONE;
    
    // Check for an indexed type
    for (NSString * typeName in self.indexLocationQueryOrder) {
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName: typeName];
        if([self isIndexedWithFeatureIndexType:type]){
            indexType = type;
            break;
        }
    }
    
    return indexType;
}

/**
 * Verify the index location is set
 *
 * @return feature index type
 */
-(enum GPKGFeatureIndexType) verifyIndexLocation{
    if(_indexLocation == GPKG_FIT_NONE){
        [NSException raise:@"No Index Location" format:@"Index Location is not set, set the location or call an index method specifying the location"];
    }
    return _indexLocation;
}

@end
