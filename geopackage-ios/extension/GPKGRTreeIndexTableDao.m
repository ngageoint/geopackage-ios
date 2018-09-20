//
//  GPKGRTreeIndexTableDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRTreeIndexTableDao.h"
#import "GPKGSqlUtils.h"
#import "GPKGRTreeIndexExtension.h"

@interface GPKGRTreeIndexTableDao()

@property (nonatomic, strong) GPKGRTreeIndexExtension *rTree;
@property (nonatomic, strong) GPKGFeatureDao *featureDao;

@end

@implementation GPKGRTreeIndexTableDao

-(instancetype) initWithExtension: (GPKGRTreeIndexExtension *) rTree andDao: (GPKGUserCustomDao *) dao andFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super initWithDao:dao andTable:[dao table]];
    if(self != nil){
        self.rTree = rTree;
        self.featureDao = featureDao;
        self.projection = featureDao.projection;
        self.tolerance = .00000000000001;
    }
    return self;
}

-(BOOL) has{
    return [self.rTree hasWithFeatureTable:[self.featureDao getFeatureTable]];
}

-(GPKGExtensions *) create{
    GPKGExtensions *extension = nil;
    if(![self has]){
        extension = [self.rTree createWithFeatureTable:[self.featureDao getFeatureTable]];
        if(self.progress != nil){
            [self.progress addProgress:[self count]];
        }
    }
    return extension;
}

-(void) delete{
    [self.rTree deleteWithFeatureTable:[self.featureDao getFeatureTable]];
}

-(GPKGRTreeIndexExtension *) rTreeIndexExtension{
    return _rTree;
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(GPKGRTreeIndexTableRow *) row: (GPKGResultSet *) resultSet{
    return [self rowFromUserCustomRow:(GPKGUserCustomRow *)[self getRow:resultSet]];
}

-(GPKGRTreeIndexTableRow *) rowFromUserCustomRow: (GPKGUserCustomRow *) row{
    return [[GPKGRTreeIndexTableRow alloc] initWithUserCustomRow:row];
}

-(GPKGFeatureRow *) featureRowFromRTreeRow: (GPKGRTreeIndexTableRow *) row{
    return (GPKGFeatureRow *)[self.featureDao queryForIdObject:[row idNumber]];
}

-(GPKGFeatureRow *) featureRow: (GPKGResultSet *) resultSet{
    GPKGRTreeIndexTableRow *row = [self row:resultSet];
    return [self featureRowFromRTreeRow:row];
}

-(GPKGFeatureRow *) featureRowFromUserCustomRow: (GPKGUserCustomRow *) row{
    return [self featureRowFromRTreeRow:[self rowFromUserCustomRow:row]];
}

-(GPKGResultSet *) rawQuery:(NSString *)sql andArgs:(NSArray *)selectionArgs{
    [self validateRTree];
    
    GPKGResultSet *resultSet = [self.database rawQuery:sql andArgs:selectionArgs];
    
    return resultSet;
}

-(GPKGResultSet *) queryForAll{
    [self validateRTree];
    return [super queryForAll];
}

-(GPKGResultSet *) queryWhere:(NSString *)where andWhereArgs:(NSArray *)whereArgs{
    [self validateRTree];
    return [super queryWhere:where andWhereArgs:whereArgs];
}

-(int) count{
    [self validateRTree];
    return [super count];
}

-(int) countWhere:(NSString *)where andWhereArgs:(NSArray *)whereArgs{
    [self validateRTree];
    return [super countWhere:where andWhereArgs:whereArgs];
}

-(GPKGBoundingBox *) getBoundingBox{
    
    GPKGBoundingBox *boundingBox = nil;
    
    NSString *sql = [NSString stringWithFormat:@"SELECT MIN(%@), MIN(%@), MAX(%@), MAX(%@) FROM %@", GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_X, GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_Y, GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_X,GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_Y, [GPKGSqlUtils quoteWrapName:self.tableName]];
    NSArray *dataTypes = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], nil];
    
     NSArray<NSNumber *> *results = (NSArray<NSNumber *> *) [self querySingleRowResultsWithSql:sql andArgs:nil andDataTypes:dataTypes];
    
    if(results != nil && results.count > 0){
    
        double minLongitude = [[results objectAtIndex:0] doubleValue];
        double minLatitude = [[results objectAtIndex:1] doubleValue];
        double maxLongitude = [[results objectAtIndex:2] doubleValue];
        double maxLatitude = [[results objectAtIndex:3] doubleValue];

        boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
     
    }
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    GPKGBoundingBox *boundingBox = [self getBoundingBox];
    if (boundingBox != nil && projection != nil) {
        SFPProjectionTransform *transform = [[SFPProjectionTransform alloc] initWithFromProjection:self.projection andToProjection:projection];
        if(![transform isSameProjection]){
            boundingBox = [boundingBox transform:transform];
        }
    }
    return boundingBox;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryWithEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self boundingBox:boundingBox inProjection:projection];
    return [self queryWithBoundingBox:featureBoundingBox];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countWithEnvelope:[boundingBox buildEnvelope]];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self boundingBox:boundingBox inProjection:projection];
    return [self countWithBoundingBox:featureBoundingBox];
}

-(GPKGResultSet *) queryWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryWithMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue]];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countWithMinX:[envelope.minX doubleValue] andMinY:[envelope.minY doubleValue] andMaxX:[envelope.maxX doubleValue] andMaxY:[envelope.maxY doubleValue]];
}

-(GPKGResultSet *) queryWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    NSString *where = [self buildWhereWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    NSArray *whereArgs = [self buildWhereArgsWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    return [self queryWhere:where andWhereArgs:whereArgs];
}

-(int) countWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    NSString *where = [self buildWhereWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    NSArray *whereArgs = [self buildWhereArgsWithMinX:minX andMinY:minY andMaxX:maxX andMaxY:maxY];
    return [self countWhere:where andWhereArgs:whereArgs];
}

/**
 * Validate that the RTree extension exists for the table and column
 */
-(void) validateRTree{
    if (![self has]) {
        [NSException raise:@"RTree Extension" format:@"RTree Extension not found for feature table: %@", self.featureDao.tableName];
    }
}

/**
 * Build a where clause from the bounds for overlapping ranges
 *
 * @param minX min x
 * @param minY min y
 * @param maxX max x
 * @param maxY max y
 * @return where clause
 */
-(NSString *) buildWhereWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{

    NSMutableString *where = [[NSMutableString alloc] init];
    [where appendString:[self buildWhereWithField:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_X andValue:[NSNumber numberWithDouble:maxX] andOperation:@"<="]];
    [where appendString:@" AND "];
    [where appendString:[self buildWhereWithField:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_Y andValue:[NSNumber numberWithDouble:maxY] andOperation:@"<="]];
    [where appendString:@" AND "];
    [where appendString:[self buildWhereWithField:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_X andValue:[NSNumber numberWithDouble:minX] andOperation:@">="]];
    [where appendString:@" AND "];
    [where appendString:[self buildWhereWithField:GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_Y andValue:[NSNumber numberWithDouble:minY] andOperation:@">="]];
    
    return where;
}

/**
 * Build where arguments from the bounds to match the order in
 * {@link #buildWhereArgs(double, double, double, double)}
 *
 * @param minX min x
 * @param minY min y
 * @param maxX max x
 * @param maxY max y
 * @return where clause args
 */
-(NSArray *) buildWhereArgsWithMinX: (double) minX andMinY: (double) minY andMaxX: (double) maxX andMaxY: (double) maxY{
    
    minX -= self.tolerance;
    maxX += self.tolerance;
    minY -= self.tolerance;
    maxY += self.tolerance;
    
    return [self buildWhereArgsWithValueArray:[[NSArray alloc] initWithObjects:[NSNumber numberWithDouble:maxX], [NSNumber numberWithDouble:maxY], [NSNumber numberWithDouble:minX], [NSNumber numberWithDouble:minY], nil]];
}

@end
