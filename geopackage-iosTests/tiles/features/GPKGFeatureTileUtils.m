//
//  GPKGFeatureTileUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/30/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTileUtils.h"
#import "PROJProjectionConstants.h"

@implementation GPKGFeatureTileUtils

+(GPKGFeatureDao *) createFeatureDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGBoundingBox *boundingBox = [GPKGBoundingBox worldWGS84];
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_tiles"];
    [geometryColumns setColumnName:@"gome"];
    [geometryColumns setGeometryType:SF_GEOMETRY];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andBoundingBox:boundingBox]];
    
    GPKGFeatureDao *featureDao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
    
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
    NSArray *points = [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:135.0], [[NSDecimalNumber alloc] initWithDouble:67.5], nil],
                        [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:90.0], [[NSDecimalNumber alloc] initWithDouble:45.0], nil],
                        [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:135.0], [[NSDecimalNumber alloc] initWithDouble:45.0], nil],
                         nil];
    [self insertFourLinesWithFeatureDao:featureDao andPoints:points];
    
    count+=4;
    NSArray *outerRing = [NSArray arrayWithObjects:
                        [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:60.0], [[NSDecimalNumber alloc] initWithDouble:35.0], nil],
                        [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:65.0], [[NSDecimalNumber alloc] initWithDouble:15.0], nil],
                        [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:15.0], [[NSDecimalNumber alloc] initWithDouble:20.0], nil],
                           [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:20.0], [[NSDecimalNumber alloc] initWithDouble:40.0], nil],
                        nil];
    NSArray *innerRing = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:50.0], [[NSDecimalNumber alloc] initWithDouble:30.0], nil],
                           [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:48.0], [[NSDecimalNumber alloc] initWithDouble:22.0], nil],
                           [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:30.0], [[NSDecimalNumber alloc] initWithDouble:23.0], nil],
                           [NSArray arrayWithObjects:[[NSDecimalNumber alloc] initWithDouble:25.0], [[NSDecimalNumber alloc] initWithDouble:34.0], nil],
                           nil];
    NSArray *lines = [NSArray arrayWithObjects:outerRing, innerRing, nil];
    [self insertFourPolygonsWithFeatureDao:featureDao andLines:lines];
    
    return count;
}

+(GPKGFeatureTiles *) createFeatureTilesWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao andUseIcon: (BOOL) useIcon andGeodesic: (BOOL) geodesic{
    
    GPKGFeatureTiles *featureTiles = [[GPKGFeatureTiles alloc] initWithFeatureDao:featureDao andGeodesic:geodesic];
    
    if(useIcon){
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(5.f, 5.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGRect rect = CGRectMake(0, 0, 5, 5);
        CGContextSetFillColorWithColor(ctx, [UIColor blueColor].CGColor);
        CGContextFillEllipseInRect(ctx, rect);
        CGContextRestoreGState(ctx);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        GPKGFeatureTilePointIcon *pointIcon = [[GPKGFeatureTilePointIcon alloc] initWithIcon:image];
        [pointIcon centerIcon];
        [featureTiles setPointIcon:pointIcon];
    }else{
        [featureTiles setPointColor:[UIColor yellowColor]];
    }
    [featureTiles setLineColor:[UIColor greenColor]];
    [featureTiles setPolygonColor:[UIColor redColor]];
    [featureTiles setFillPolygon:[UIColor redColor]];
    [featureTiles setPolygonFillColor:[UIColor redColor]];
    
    [featureTiles calculateDrawOverlap];
    
    return featureTiles;
}

+(void) insertFourPointsWithFeatureDao: (GPKGFeatureDao *) featureDao andX: (double) x andY: (double) y{
    [self insertPointWithFeatureDao:featureDao andX:x andY:y];
    [self insertPointWithFeatureDao:featureDao andX:x andY:-1 * y];
    [self insertPointWithFeatureDao:featureDao andX:-1 * x andY:y];
    [self insertPointWithFeatureDao:featureDao andX:-1 * x andY:-1 * y];
}

+(void) insertFourLinesWithFeatureDao: (GPKGFeatureDao *) featureDao andPoints: (NSArray *) points{
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:NO andNegativeX:NO]];
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:YES andNegativeX:NO]];
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:NO andNegativeX:YES]];
    [self insertLineWithFeatureDao:featureDao andPoints:[self convertPoints:points withNegativeY:YES andNegativeX:YES]];
}

+(void) insertFourPolygonsWithFeatureDao: (GPKGFeatureDao *) featureDao andLines: (NSArray *) lines{
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:NO andNegativeX:NO]];
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:YES andNegativeX:NO]];
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:NO andNegativeX:YES]];
    [self insertPolygonWithFeatureDao:featureDao andLines:[self convertLines:lines withNegativeY:YES andNegativeX:YES]];
}

+(NSArray *) convertPoints: (NSArray *) points withNegativeY: (BOOL) negativeY andNegativeX: (BOOL) negativeX{
    
    NSMutableArray *newPoints = [NSMutableArray array];
    for(NSArray *point in points){
        NSMutableArray *newPoint = [NSMutableArray array];
        
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
    
    NSMutableArray *newLines = [NSMutableArray array];
    for(NSArray *line in lines){
        [newLines addObject:[self convertPoints:line withNegativeY:negativeY andNegativeX:negativeX]];
    }
    return newLines;
}

+(long long) insertPointWithFeatureDao: (GPKGFeatureDao *) featureDao andX: (double) x andY: (double) y{
    GPKGFeatureRow *featureRow = [featureDao newRow];
    [self setPointWithFeatureRow:featureRow andX:x andY:y];
    return [featureDao insert:featureRow];
}

+(void) setPointWithFeatureRow: (GPKGFeatureRow *) featureRow andX: (double) x andY: (double) y{
    GPKGGeometryData *geomData = [GPKGGeometryData createWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM] andGeometry:
                                  [SFPoint pointWithXValue:x andYValue:y]];
    [featureRow setGeometry:geomData];
}

+(long long) insertLineWithFeatureDao: (GPKGFeatureDao *) featureDao andPoints: (NSArray *) points{
    GPKGFeatureRow *featureRow = [featureDao newRow];
    GPKGGeometryData *geomData = [GPKGGeometryData createWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM] andGeometry:
                                   [self lineStringWithPoints:points]];
    [featureRow setGeometry:geomData];
    return [featureDao insert:featureRow];
}

+(SFLineString *) lineStringWithPoints: (NSArray *) points{
    SFLineString *lineString = [SFLineString lineStringWithHasZ:NO andHasM:NO];
    for(NSArray *point in points){
        NSDecimalNumber *x = [point objectAtIndex:0];
        NSDecimalNumber *y = [point objectAtIndex:1];
        SFPoint *point = [SFPoint pointWithHasZ:NO andHasM:NO andX:x andY:y];
        [lineString addPoint:point];
    }
    return lineString;
}

+(long long) insertPolygonWithFeatureDao: (GPKGFeatureDao *) featureDao andLines: (NSArray *) lines{
    GPKGFeatureRow *featureRow = [featureDao newRow];
    SFPolygon *polygon = [SFPolygon polygon];
    GPKGGeometryData *geomData = [[GPKGGeometryData alloc] initWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM] andGeometry:polygon];
    for(NSArray *ring in lines){
        SFLineString *lineString = [self lineStringWithPoints:ring];
        [polygon addRing:lineString];
    }
    [featureRow setGeometry:geomData];
    return [featureDao insert:featureRow];
}

+(void) updateLastChangeWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    GPKGContents *contents = [featureDao contents];
    [contents setLastChange:[NSDate date]];
    GPKGContentsDao *contentsDao = [geoPackage contentsDao];
    [contentsDao update:contents];
}

@end
