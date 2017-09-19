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
#import "GPKGMapUtils.h"

@interface GPKGFeatureShapes ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *databases;

@end

@implementation GPKGFeatureShapes

-(instancetype) init{
    self = [super init];
    if(self != nil){
        _databases = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSDictionary<NSString *, NSDictionary *> *) databases{
    return _databases;
}

-(int) databasesCount{
    return (int) _databases.count;
}

-(NSDictionary<NSString *, NSDictionary *> *) tablesInDatabase: (NSString *) database{
    
    NSMutableDictionary * tables = [_databases objectForKey:database];
    if(tables == nil){
        tables = [[NSMutableDictionary alloc] init];
        [_databases setObject:tables forKey:database];
    }
    return tables;
}

-(int) tablesCountInDatabase: (NSString *) database{
    return (int)[self tablesInDatabase:database].count;
}

-(NSDictionary<NSString *, NSArray *> *) featureIdsInDatabase: (NSString *) database withTable: (NSString *) table{
    
    NSMutableDictionary * tables = (NSMutableDictionary *)[self tablesInDatabase:database];
    NSMutableDictionary * featureIds = [self featureIdsInTables:tables withTable:table];
    return featureIds;
}

-(int) featureIdsCountInDatabase: (NSString *) database withTable: (NSString *) table{
    return (int) [self featureIdsInDatabase:database withTable:table].count;
}

-(NSMutableDictionary<NSString *, NSArray *> *) featureIdsInTables: (NSMutableDictionary *) tables withTable: (NSString *) table{
    
    NSMutableDictionary * featureIds = [tables objectForKey:table];
    if(featureIds == nil){
        featureIds = [[NSMutableDictionary alloc] init];
        [tables setObject:featureIds forKey:table];
    }
    return featureIds;
}

-(NSArray<GPKGMapShape *> *) shapesInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId{
    
    NSMutableDictionary * featureIds = (NSMutableDictionary *)[self featureIdsInDatabase:database withTable:table];
    NSMutableArray *shapes = [self shapesInFeatureIds:featureIds withFeatureId:featureId];
    return shapes;
}

-(int) shapesCountInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId{
    return (int) [self shapesInDatabase:database withTable:table withFeatureId:featureId].count;
}

-(NSMutableArray<GPKGMapShape *> *) shapesInFeatureIds: (NSMutableDictionary *) featureIds withFeatureId: (NSNumber *) featureId{
    
    NSMutableArray *shapes = [featureIds objectForKey:featureId];
    if(shapes == nil){
        shapes = [[NSMutableArray alloc] init];
        [featureIds setObject:shapes forKey:featureId];
    }
    return shapes;
}

-(void) addMapShape: (GPKGMapShape *) mapShape withFeatureId: (NSNumber *) featureId toDatabase: (NSString *) database withTable: (NSString *) table{
    
    NSMutableArray * shapes = (NSMutableArray *)[self shapesInDatabase:database withTable:table withFeatureId:featureId];
    [shapes addObject:mapShape];
}

-(BOOL) existsWithFeatureId: (NSNumber *) featureId inDatabase: (NSString *) database withTable: (NSString *) table{
    BOOL exists = NO;
    NSMutableDictionary * tables = [_databases objectForKey:database];
    if(tables != nil){
        
        NSMutableDictionary * featureIds = [tables objectForKey:table];
        if(featureIds != nil){
            NSMutableArray *shapes = [featureIds objectForKey:featureId];
            exists = shapes != nil && shapes.count > 0;
        }
        
    }
    return exists;
}

-(int) removeShapesFromMapView: (MKMapView *) mapView{
    
    int count = 0;
    
    for(NSString * database in [_databases allKeys]){
        
        count += [self removeShapesFromMapView:mapView inDatabase:database];
    }
    
    [self clear];
    
    return count;
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database{
    
    int count = 0;
    
    NSMutableDictionary * tables = (NSMutableDictionary *)[self tablesInDatabase:database];
    
    if(tables != nil){
    
        for(NSString * table in [tables allKeys]){
            
            count += [self removeShapesFromMapView:mapView inDatabase:database withTable:table];
        }
        
        [tables removeAllObjects];
        
    }
    
    return count;
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table{
    
    int count = 0;
    
    NSMutableDictionary * featureIds = (NSMutableDictionary *)[self featureIdsInDatabase:database withTable:table];
    
    if(featureIds != nil){
    
        for(NSNumber *featureId in [featureIds allKeys]){
            
            NSMutableArray *mapShapes = [self shapesInFeatureIds:featureIds withFeatureId:featureId];
            
            if(mapShapes != nil){
            
                for(GPKGMapShape *mapShape in mapShapes){
                    
                    [mapShape removeFromMapView:mapView];
                }
            
            }
            count++;
        }
        
        [featureIds removeAllObjects];
        
    }
    
    return count;
}

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView{
 
    int count = 0;
    
    GPKGBoundingBox *boundingBox = [GPKGMapUtils boundingBoxOfMapView:mapView];
    
    for(NSString * database in [_databases allKeys]){
        
        count += [self removeShapesNotWithinMapView:mapView withBoundingBox:boundingBox inDatabase:database];
        
    }
    
    return count;
}

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView inDatabase: (NSString *) database{
    
    GPKGBoundingBox *boundingBox = [GPKGMapUtils boundingBoxOfMapView:mapView];
    
    int count =  [self removeShapesNotWithinMapView:mapView withBoundingBox:boundingBox inDatabase:database];
    
    return count;
}

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView withBoundingBox: (GPKGBoundingBox *) boundingBox inDatabase: (NSString *) database{
    
    int count = 0;
    
    NSMutableDictionary * tables = (NSMutableDictionary *)[self tablesInDatabase:database];
    
    if(tables != nil){
        
        for(NSString * table in [tables allKeys]){
            count += [self removeShapesNotWithinMapView:mapView withBoundingBox:boundingBox inDatabase:database withTable:table];
        }
        
    }
    
    return count;
}

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table{
    
    GPKGBoundingBox *boundingBox = [GPKGMapUtils boundingBoxOfMapView:mapView];
    
    int count = [self removeShapesNotWithinMapView:mapView withBoundingBox:boundingBox inDatabase:database withTable:table];
    
    return count;
}

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView withBoundingBox: (GPKGBoundingBox *) boundingBox inDatabase: (NSString *) database withTable: (NSString *) table{
    
    int count = 0;
    
    NSMutableDictionary * featureIds = (NSMutableDictionary *)[self featureIdsInDatabase:database withTable:table];
    
    if(featureIds != nil){
    
        NSMutableArray *deleteFeatureIds = [[NSMutableArray alloc] init];
        
        for(NSNumber *featureId in [featureIds allKeys]){
            
            NSMutableArray *mapShapes = [self shapesInFeatureIds:featureIds withFeatureId:featureId];
            
            if(mapShapes != nil){
            
                BOOL delete = YES;
                for(GPKGMapShape *mapShape in mapShapes){
                    GPKGBoundingBox *mapShapeBoundingBox = [mapShape boundingBox];
                    if([GPKGTileBoundingBoxUtils overlapWithBoundingBox:mapShapeBoundingBox andBoundingBox:boundingBox andMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH] != nil){
                        delete = NO;
                        break;
                    }
                }
                if(delete){
                    [deleteFeatureIds addObject:featureId];
                }
                
            }
            
        }
        
        for(NSNumber * deleteFeatureId in deleteFeatureIds){
            
            NSMutableArray *mapShapes = [self shapesInFeatureIds:featureIds withFeatureId:deleteFeatureId];
            
            if(mapShapes != nil){
            
                for(GPKGMapShape *mapShape in mapShapes){
                    [mapShape removeFromMapView:mapView];
                }
                
                [featureIds removeObjectForKey:deleteFeatureId];
                
            }
            count++;
        }
        
    }
    
    return count;
}

-(void) clear{
    [_databases removeAllObjects];
}

@end
