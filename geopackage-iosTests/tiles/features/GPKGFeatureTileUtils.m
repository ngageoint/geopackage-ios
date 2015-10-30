//
//  GPKGFeatureTileUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/30/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTileUtils.h"
#import "GPKGProjectionConstants.h"
#import "WKBPolygon.h"

@implementation GPKGFeatureTileUtils

+(GPKGFeatureDao *) createFeatureDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] init];
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_tiles"];
    [geometryColumns setColumnName:@"gome"];
    [geometryColumns setGeometryType:WKB_GEOMETRY];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andBoundingBox:boundingBox andSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
    
    return featureDao;
}

+(int) insertFeaturesWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    
    int count = 0;
    
    count +=5;
    [self insertPointWithFeatureDao:featureDao andX:0 andY:0];
    [self insertPointWithFeatureDao:featureDao andX:0 andY:PROJ_WEB_MERCATOR_MAX_LAT_RANGE - 1];
    [self insertPointWithFeatureDao:featureDao andX:0 andY:PROJ_WEB_MERCATOR_MIN_LAT_RANGE + 1];
    [self insertPointWithFeatureDao:featureDao andX:-179 andY:0];
    [self insertPointWithFeatureDao:featureDao andX:179 andY:0];
    
    count += 4;
    [self insertFourPointsWithFeatureDao:featureDao andX:179 andY:PROJ_WEB_MERCATOR_MAX_LAT_RANGE - 1];
    count += 4;
    [self insertFourPointsWithFeatureDao:featureDao andX:90 andY:45];
    
    count+=4;
    NSArray * points = [[NSArray alloc] initWithObjects:
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:135.0], [[NSDecimalNumber alloc] initWithDouble:67.5], nil],
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:90.0], [[NSDecimalNumber alloc] initWithDouble:45.0], nil],
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:135.0], [[NSDecimalNumber alloc] initWithDouble:45.0], nil],
                         nil];
    [self insertFourLinesWithFeatureDao:featureDao andPoints:points];
    
    count+=4;
    NSArray * outerRing = [[NSArray alloc] initWithObjects:
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:60.0], [[NSDecimalNumber alloc] initWithDouble:35.0], nil],
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:65.0], [[NSDecimalNumber alloc] initWithDouble:15.0], nil],
                        [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:15.0], [[NSDecimalNumber alloc] initWithDouble:20.0], nil],
                           [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:20.0], [[NSDecimalNumber alloc] initWithDouble:40.0], nil],
                        nil];
    NSArray * innerRing = [[NSArray alloc] initWithObjects:
                           [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:50.0], [[NSDecimalNumber alloc] initWithDouble:30.0], nil],
                           [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:48.0], [[NSDecimalNumber alloc] initWithDouble:22.0], nil],
                           [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:30.0], [[NSDecimalNumber alloc] initWithDouble:23.0], nil],
                           [[NSArray alloc] initWithObjects:[[NSDecimalNumber alloc] initWithDouble:25.0], [[NSDecimalNumber alloc] initWithDouble:34.0], nil],
                           nil];
    NSArray * lines = [[NSArray alloc] initWithObjects:outerRing, innerRing, nil];
    [self insertFourPolygonsWithFeatureDao:featureDao andLines:lines];
    
    return count;
}

+(void) insertFourPointsWithFeatureDao: (GPKGFeatureDao *) featureDao andX: (double) x andY: (double) y{
    [self insertPointWithFeatureDao:featureDao andX:x andY:y];
    [self insertPointWithFeatureDao:featureDao andX:x andY:-1 * y];
    [self insertPointWithFeatureDao:featureDao andX:-1 * x andY:y];
    [self insertPointWithFeatureDao:featureDao andX:-1 * x andY:-1 * y];
}

+(void) insertFourLinesWithFeatureDao: (GPKGFeatureDao *) featureDao andPoints: (NSArray *) points{
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:false andNegativeX:false]];
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:true andNegativeX:false]];
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:false andNegativeX:true]];
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:true andNegativeX:true]];
}

+(void) insertFourPolygonsWithFeatureDao: (GPKGFeatureDao *) featureDao andLines: (NSArray *) lines{
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:false andNegativeX:false]];
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:true andNegativeX:false]];
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:false andNegativeX:true]];
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:true andNegativeX:true]];
}

+(NSArray *) convertPoints: (NSArray *) points withNegativeY: (BOOL) negativeY andNegativeX: (BOOL) negativeX{
    
    NSMutableArray * newPoints = [[NSMutableArray alloc] init];
    for(NSArray * point in points){
        NSMutableArray * newPoint = [[NSMutableArray alloc] init];
        
        double x = [(NSDecimalNumber *)[point objectAtIndex:0] doubleValue];
        if(negativeX){
            x *= -1;
        }
        [newPoint addObject:[[NSDecimalNumber alloc] initWithDouble:x]];
        
        double y = [(NSDecimalNumber *)[point objectAtIndex:1] doubleValue];
        if(negativeY){
            y *= -1;
        }
        [newPoint addObject:[[NSDecimalNumber alloc] initWithDouble:y]];
        
        [newPoints addObject:newPoint];
    }
    
    return newPoints;
}

+(NSArray *) convertLines: (NSArray *) lines withNegativeY: (BOOL) negativeY andNegativeX: (BOOL) negativeX{
    
    NSMutableArray * newLines = [[NSMutableArray alloc] init];
    for(NSArray * line in lines){
        [newLines addObject:[self convertPoints:line withNegativeY:negativeY andNegativeX:negativeX]];
    }
    return newLines;
}

+(long long) insertPointWithFeatureDao: (GPKGFeatureDao *) featureDao andX: (double) x andY: (double) y{
    GPKGFeatureRow * featureRow = [featureDao newRow];
    [self setPointWithFeatureRow:featureRow andX:x andY:y];
    return [featureDao insert:featureRow];
}

+(void) setPointWithFeatureRow: (GPKGFeatureRow *) featureRow andX: (double) x andY: (double) y{
    GPKGGeometryData * geomData = [[GPKGGeometryData alloc] initWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    WKBPoint * point = [[WKBPoint alloc] initWithHasZ:false andHasM:false andX:[[NSDecimalNumber alloc] initWithDouble:x] andY:[[NSDecimalNumber alloc] initWithDouble:y]];
    [geomData setGeometry:point];
    [featureRow setGeometry:geomData];
}

+(long long) insertLineWithFeatureDao: (GPKGFeatureDao *) featureDao andPoints: (NSArray *) points{
    GPKGFeatureRow * featureRow = [featureDao newRow];
    GPKGGeometryData * geomData = [[GPKGGeometryData alloc] initWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    WKBLineString * lineString = [self getLineStringWithPoints:points];
    [geomData setGeometry:lineString];
    [featureRow setGeometry:geomData];
    return [featureDao insert:featureRow];
}

+(WKBLineString *) getLineStringWithPoints: (NSArray *) points{
    WKBLineString * lineString = [[WKBLineString alloc] initWithHasZ:false andHasM:false];
    for(NSArray * point in points){
        NSDecimalNumber * x = [point objectAtIndex:0];
        NSDecimalNumber * y = [point objectAtIndex:1];
        WKBPoint * point = [[WKBPoint alloc] initWithHasZ:false andHasM:false andX:x andY:y];
        [lineString addPoint:point];
    }
    return lineString;
}

+(long long) insertPolygonWithFeatureDao: (GPKGFeatureDao *) featureDao andLines: (NSArray *) lines{
    GPKGFeatureRow * featureRow = [featureDao newRow];
    GPKGGeometryData * geomData = [[GPKGGeometryData alloc] initWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    WKBPolygon * polygon = [[WKBPolygon alloc] initWithHasZ:false andHasM:false];
    for(NSArray * ring in lines){
        WKBLineString * lineString = [self getLineStringWithPoints:ring];
        [polygon addRing:lineString];
    }
    [geomData setGeometry:polygon];
    [featureRow setGeometry:geomData];
    return [featureDao insert:featureRow];
}

+(void) updateLastChangeWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    GPKGContents * contents = [geometryColumnsDao getContents:featureDao.geometryColumns];
    [contents setLastChange:[NSDate date]];
    GPKGContentsDao * contentsDao = [geoPackage getContentsDao];
    [contentsDao update:contents];
}

@end
