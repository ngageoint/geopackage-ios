//
//  GPKGFeatureShapes.m
//  Pods
//
//  Created by Brian Osborn on 9/14/17.
//
//

#import "GPKGFeatureShapes.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@interface GPKGFeatureShapes ()

@property (nonatomic, strong) NSMutableDictionary *databases;

@end

@implementation GPKGFeatureShapes

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.databases = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSMutableDictionary *) tablesInDatabase: (NSString *) database{
    
    NSMutableDictionary * tables = [self.databases objectForKey:database];
    if(tables == nil){
        tables = [[NSMutableDictionary alloc] init];
        [self.databases setObject:tables forKey:database];
    }
    return tables;
}

-(NSMutableDictionary *) featureIdsInDatabase: (NSString *) database andTable: (NSString *) table{
    
    NSMutableDictionary * tables = [self tablesInDatabase:database];
    NSMutableDictionary * featureIds = [self featureIdsInTables:tables withTable:table];
    return featureIds;
}

-(NSMutableDictionary *) featureIdsInTables: (NSMutableDictionary *) tables withTable: (NSString *) table{
    
    NSMutableDictionary * featureIds = [tables objectForKey:table];
    if(featureIds == nil){
        featureIds = [[NSMutableDictionary alloc] init];
        [tables setObject:featureIds forKey:table];
    }
    return featureIds;
}

-(NSMutableArray *) shapesInDatabase: (NSString *) database andTable: (NSString *) table withFeatureId: (NSNumber *) featureId{
    
    NSMutableDictionary * featureIds = [self featureIdsInDatabase:database andTable:table];
    NSMutableArray *shapes = [self shapesInFeatureIds:featureIds withFeatureId:featureId];
    return shapes;
}

-(NSMutableArray *) shapesInFeatureIds: (NSMutableDictionary *) featureIds withFeatureId: (NSNumber *) featureId{
    
    NSMutableArray *shapes = [featureIds objectForKey:featureId];
    if(shapes == nil){
        shapes = [[NSMutableArray alloc] init];
        [featureIds setObject:shapes forKey:featureId];
    }
    return shapes;
}

-(void) addMapShape: (GPKGMapShape *) mapShape withFeatureId: (NSNumber *) featureId toDatabase: (NSString *) database andTable: (NSString *) table{
    
    NSMutableArray * shapes = [self shapesInDatabase:database andTable:table withFeatureId:featureId];
    [shapes addObject:mapShape];
}

-(NSArray<GPKGMapShape *> *) mapShapesWithFeatureId: (NSNumber *) featureId inDatabase: (NSString *) database andTable: (NSString *) table{
    return [self shapesInDatabase:database andTable:table withFeatureId:featureId];
}

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView{
    
    int count = 0;
    
    CLLocationCoordinate2D center = mapView.region.center;
    MKCoordinateSpan span = mapView.region.span;
    double latitudeFromCenter = span.latitudeDelta * .5;
    double longitudeFromCenter = span.longitudeDelta * .5;
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:center.longitude - longitudeFromCenter andMaxLongitudeDouble:center.longitude + longitudeFromCenter andMinLatitudeDouble:center.latitude - latitudeFromCenter andMaxLatitudeDouble:center.latitude + latitudeFromCenter];
    //GPKGProjection *wgs84 = [GPKGProjectionFactory projectionWithEpsgInt: PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
    
    for(NSString * database in [self.databases allKeys]){
        
        NSMutableDictionary * tables = [self tablesInDatabase:database];
        
        //GPKGGeoPackage * geoPackage = [self.geoPackages objectForKey:database];
        
        for(NSString * table in [tables allKeys]){
            
            NSMutableDictionary * featureIds = [self featureIdsInTables:tables withTable:table];
            
            
            //GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
            //GPKGGeometryColumns *geometryColumns = [geometryColumnsDao queryForTableName:table];
            //GPKGProjection *projection = [geometryColumnsDao getProjection:geometryColumns];
            
            //GPKGProjectionTransform * projectionTransform = [[GPKGProjectionTransform alloc] initWithFromProjection:wgs84 andToProjection:projection];
            //GPKGBoundingBox * projectedBoundingBox = [projectionTransform transformWithBoundingBox:boundingBox];
            
            for(NSNumber *featureId in [featureIds allKeys]){
                
                NSMutableArray *mapShapes = [self shapesInFeatureIds:featureIds withFeatureId:featureId];
                
                for(GPKGMapShape *mapShape in mapShapes){
                    GPKGBoundingBox *mapShapeBoundingBox = [mapShape boundingBox];
                    if(![GPKGTileBoundingBoxUtils overlapWithBoundingBox:mapShapeBoundingBox andBoundingBox:boundingBox]){
                        [mapShape removeFromMapView:mapView];
                    }
                }
                [mapShapes removeAllObjects];
                count++;
            }
            
        }
        
    }
    
    
    return count;
}


@end
