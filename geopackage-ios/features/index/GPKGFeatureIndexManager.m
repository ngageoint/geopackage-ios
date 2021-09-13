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
        self.indexLocationQueryOrder = [NSMutableArray arrayWithObjects:
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
    NSArray *featureIndexTypes = [NSArray arrayWithObjects:[GPKGFeatureIndexTypes name:featureIndexType], nil];
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
    
    NSMutableArray *queryOrder = [NSMutableArray array];
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
    return [self indexWithFeatureIndexType:[self verifyIndexLocation] andForce:NO];
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
    return [self indexWithFeatureIndexType:type andForce:NO];
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
    BOOL indexed = NO;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self indexWithFeatureIndexType:type andFeatureRow:row]){
            indexed = YES;
        }
    }
    return indexed;
}

-(BOOL) indexWithFeatureIndexType:(enum GPKGFeatureIndexType) type andFeatureRow: (GPKGFeatureRow *) row{
    BOOL indexed = NO;
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
            indexed = YES;
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
    BOOL deleted = NO;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self deleteIndexWithFeatureIndexType:type]){
            deleted = YES;
        }
    }
    return deleted;
}

-(BOOL) deleteIndexWithFeatureIndexType:(enum GPKGFeatureIndexType) type{
    if(type == GPKG_FIT_NONE){
        [NSException raise:@"No Feature Index Type" format:@"Feature Index Type is required to delete index"];
    }
    BOOL deleted = NO;
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
    BOOL deleted = NO;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self deleteIndexWithFeatureIndexType:type andFeatureRow:row]){
            deleted = YES;
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
    BOOL deleted = NO;
    for(NSString *typeName in types){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self deleteIndexWithFeatureIndexType:type andGeomId:geomId]){
            deleted = YES;
        }
    }
    return deleted;
}

-(BOOL) deleteIndexWithFeatureIndexType: (enum GPKGFeatureIndexType) type andGeomId: (int) geomId{
    if(type == GPKG_FIT_NONE){
        [NSException raise:@"No Feature Index Type" format:@"Feature Index Type is required to delete index"];
    }
    BOOL deleted = NO;
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
    NSArray *retain = [NSArray arrayWithObjects:[GPKGFeatureIndexTypes name:type], nil];
    return [self retainIndexWithFeatureIndexTypes:retain];
}

-(BOOL) retainIndexWithFeatureIndexTypes: (NSArray<NSString *> *) types{
    NSMutableArray *delete = [NSMutableArray array];
    for(NSString *indexLocationType in self.indexLocationQueryOrder){
        if(![types containsObject:indexLocationType]){
            [delete addObject:indexLocationType];
        }
    }
    return [self deleteIndexWithFeatureIndexTypes:delete];
}

-(NSArray<NSString *> *) indexedTypes{
    NSMutableArray<NSString *> *indexed = [NSMutableArray array];
    for(NSString *typeName in self.indexLocationQueryOrder){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        if([self isIndexedWithFeatureIndexType:type]){
            [indexed addObject:typeName];
        }
    }
    return indexed;
}

-(BOOL) isIndexed{
    BOOL indexed = NO;
    for(NSString *typeName in self.indexLocationQueryOrder){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        indexed = [self isIndexedWithFeatureIndexType:type];
        if(indexed){
            break;
        }
    }
    return indexed;
}

-(BOOL) isIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    BOOL indexed = NO;
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
    NSDate *lastIndexed = nil;
    for(NSString *typeName in self.indexLocationQueryOrder){
        enum GPKGFeatureIndexType type = [GPKGFeatureIndexTypes fromName:typeName];
        lastIndexed = [self lastIndexedWithFeatureIndexType:type];
        if(lastIndexed != nil){
            break;
        }
    }
    return lastIndexed;
}

-(NSDate *) lastIndexedWithFeatureIndexType: (enum GPKGFeatureIndexType) type{
    NSDate *lastIndexed = nil;
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
    return [self queryWithDistinct:NO];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct{
    return [self queryWithDistinct:distinct andColumns:[self.featureDao columnNames]];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns{
    return [self queryWithDistinct:NO andColumns:columns];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns{
    GPKGFeatureIndexResults *results = nil;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        GPKGResultSet *geoPackageResults = [self.featureTableIndex queryFeaturesWithDistinct:distinct andColumns:columns];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geoPackageResults];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        GPKGResultSet *geometryMetadataResults = [self.featureIndexer queryFeaturesWithDistinct:distinct andColumns:columns];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geometryMetadataResults];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        GPKGResultSet *rTreeResults = [self.rTreeIndexTableDao queryFeaturesWithDistinct:distinct andColumns:columns];
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
        GPKGResultSet *resultSet = [self.manualFeatureQuery queryWithDistinct:distinct andColumns:columns];
        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:resultSet];
    }
    return results;
}

-(int) countWithColumn: (NSString *) column{
    return [self countWithDistinct:NO andColumn:column];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column{
    int count = -1;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        count = [self.featureTableIndex countFeaturesWithDistinct:distinct andColumn:column];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        count = [self.featureIndexer countFeaturesWithDistinct:distinct andColumn:column];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        count = [self.rTreeIndexTableDao countFeaturesWithDistinct:distinct andColumn:column];
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
                NSLog(@"Failed to count from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (count == -1) {
        count = [self.manualFeatureQuery countWithGeometries];
    }
    return count;
}

-(int) count{
    int count = -1;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        count = [self.featureTableIndex count];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        count = [self.featureIndexer count];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        count = [self.rTreeIndexTableDao count];
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
                NSLog(@"Failed to count from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (count == -1) {
        count = [self.manualFeatureQuery countWithGeometries];
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryWithDistinct:distinct andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:nil andFieldValues:fieldValues];
}

-(int) countWithColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:column andFieldValues:fieldValues];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self countWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWhere: (NSString *) where{
    return [self queryWithDistinct:NO andWhere:where];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self queryWithColumns:columns andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:nil];
}

-(int) countWhere: (NSString *) where{
    return [self countWithDistinct:NO andColumn:nil andWhere:where];
}

-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where{
    return [self countWithDistinct:NO andColumn:column andWhere:where];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where{
    return [self countWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andColumns:[self.featureDao columnNames] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexResults *results = nil;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        GPKGResultSet *geoPackageResults = [self.featureTableIndex queryFeaturesWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geoPackageResults];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        GPKGResultSet *geometryMetadataResults = [self.featureIndexer queryFeaturesWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geometryMetadataResults];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        GPKGResultSet *rTreeResults = [self.rTreeIndexTableDao queryFeaturesWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
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
        GPKGResultSet *resultSet = [self.manualFeatureQuery queryWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:resultSet];
    }
    return results;
}

-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:nil andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = -1;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        count = [self.featureTableIndex countFeaturesWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        count = [self.featureIndexer countFeaturesWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        count = [self.rTreeIndexTableDao countFeaturesWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
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
                NSLog(@"Failed to count from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (count == -1) {
        count = [self.manualFeatureQuery countWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
    }
    return count;
}

-(GPKGBoundingBox *) boundingBox{
    GPKGBoundingBox *bounds = nil;
    BOOL success = NO;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        bounds = [self.featureTableIndex boundingBox];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        bounds = [self.featureIndexer boundingBox];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        bounds = [self.rTreeIndexTableDao boundingBox];
                    }
                    break;
                default:
                    {
                        [NSException raise:@"Unsupported Type" format:@"Unsupported feature index type: %@", [GPKGFeatureIndexTypes name:type]];
                    }
            }
            success = YES;
            break;
        } @catch (NSException *exception) {
            if (self.continueOnError) {
                NSLog(@"Failed to get bounding box from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (!success) {
        bounds = [self.manualFeatureQuery boundingBox];
    }
    return bounds;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    GPKGBoundingBox *bounds = nil;
    BOOL success = NO;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        bounds = [self.featureTableIndex boundingBoxInProjection:projection];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        bounds = [self.featureIndexer boundingBoxInProjection:projection];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        bounds = [self.rTreeIndexTableDao boundingBoxInProjection:projection];
                    }
                    break;
                default:
                    {
                        [NSException raise:@"Unsupported Type" format:@"Unsupported feature index type: %@", [GPKGFeatureIndexTypes name:type]];
                    }
            }
            success = YES;
            break;
        } @catch (NSException *exception) {
            if (self.continueOnError) {
                NSLog(@"Failed to get bounding box from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (!success) {
        bounds = [self.manualFeatureQuery boundingBoxInProjection:projection];
    }
    return bounds;
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope]];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countWithDistinct:distinct andColumn:column andEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:distinct andColumn:column andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox andWhere:where];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox andWhere:where];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox andWhere:where];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countWithDistinct:distinct andColumn:column andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithColumns:columns andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:distinct andColumn:column andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithDistinct:NO andEnvelope:envelope];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithEnvelope:envelope andWhere:nil andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:nil andWhereArgs:nil];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countWithDistinct:NO andColumn:nil andEnvelope:envelope];
}

-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countWithDistinct:NO andColumn:column andEnvelope:envelope];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope{
    int count = -1;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        if(column != nil){
                            count = [self.featureTableIndex countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope];
                        }else{
                            count = [self.featureTableIndex countWithEnvelope:envelope];
                        }
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        if(column != nil){
                            count = [self.featureIndexer countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope];
                        }else{
                            count = [self.featureIndexer countWithEnvelope:envelope];
                        }
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        if(column != nil){
                            count = [self.rTreeIndexTableDao countWithDistinct:distinct andColumn:column andEnvelope:envelope];
                        }else{
                            count = [self.rTreeIndexTableDao countWithEnvelope:envelope];
                        }
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
                NSLog(@"Failed to count from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (count == -1) {
        if(column != nil){
            [NSException raise:@"Unsupported Count" format:@"Count by column and envelope is unsupported as a manual feature query. column: %@", column];
        }else{
            count = [self.manualFeatureQuery countWithEnvelope:envelope];
        }
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andEnvelope:envelope andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:nil andEnvelope:envelope andFieldValues:fieldValues];
}

-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:column andEnvelope:envelope andFieldValues:fieldValues];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self countWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andEnvelope:envelope andWhere:where];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return[self countWithDistinct:NO andColumn:nil andEnvelope:envelope andWhere:where];
}

-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return[self countWithDistinct:NO andColumn:column andEnvelope:envelope andWhere:where];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self countWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andColumns:[self.featureDao columnNames] andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexResults *results = nil;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        GPKGResultSet *geoPackageResults = [self.featureTableIndex queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geoPackageResults];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        GPKGResultSet *geometryMetadataResults = [self.featureIndexer queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
                        results = [[GPKGFeatureIndexFeatureResults alloc] initWithDao:self.featureDao andResults:geometryMetadataResults];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        GPKGResultSet *rTreeResults = [self.rTreeIndexTableDao queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
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
        results = [self.manualFeatureQuery queryWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
    }
    return results;
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:nil andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = -1;
    for(NSNumber *typeNumber in [self location]){
        enum GPKGFeatureIndexType type = (enum GPKGFeatureIndexType)[typeNumber intValue];
        @try {
            switch(type){
                case GPKG_FIT_GEOPACKAGE:
                    {
                        count = [self.featureTableIndex countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
                    }
                    break;
                case GPKG_FIT_METADATA:
                    {
                        count = [self.featureIndexer countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
                    }
                    break;
                case GPKG_FIT_RTREE:
                    {
                        count = [self.rTreeIndexTableDao countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
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
                NSLog(@"Failed to count from feature index: %@. error: %@", [GPKGFeatureIndexTypes name:type], exception);
            } else {
                [exception raise];
            }
        }
    }
    if (count == -1) {
        if(column != nil){
            [NSException raise:@"Unsupported Count" format:@"Count by column and envelope is unsupported as a manual feature query. column: %@", column];
        }else{
            count = [self.manualFeatureQuery countWithEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
        }
    }
    return count;
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andBoundingBox:featureBoundingBox];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self countWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox];
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self countWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self countWithDistinct:distinct andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGFeatureIndexResults *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexResults *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self countWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGFeatureIndexLocation *) location{
    return [[GPKGFeatureIndexLocation alloc] initWithFeatureIndexManager:self];
}

-(enum GPKGFeatureIndexType) indexedType{
    
    enum GPKGFeatureIndexType indexType = GPKG_FIT_NONE;
    
    // Check for an indexed type
    for (NSString *typeName in self.indexLocationQueryOrder) {
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
