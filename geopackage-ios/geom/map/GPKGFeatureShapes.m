//
//  GPKGFeatureShapes.m
//  Pods
//
//  Created by Brian Osborn on 9/14/17.
//
//

#import "GPKGFeatureShapes.h"
#import "PROJProjectionFactory.h"
#import "PROJProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGMapUtils.h"

@interface GPKGFeatureShapes ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableDictionary *> *databases;

@end

@implementation GPKGFeatureShapes

-(instancetype) init{
    self = [super init];
    if(self != nil){
        _databases = [NSMutableDictionary dictionary];
    }
    return self;
}

-(NSMutableDictionary<NSString *, NSMutableDictionary *> *) databases{
    return _databases;
}

-(int) databasesCount{
    return (int) _databases.count;
}

-(NSMutableDictionary<NSString *, NSMutableDictionary *> *) tablesInDatabase: (NSString *) database{
    
    NSMutableDictionary * tables = [_databases objectForKey:database];
    if(tables == nil){
        tables = [NSMutableDictionary dictionary];
        [_databases setObject:tables forKey:database];
    }
    return tables;
}

-(int) tablesCountInDatabase: (NSString *) database{
    return (int)[self tablesInDatabase:database].count;
}

-(NSMutableDictionary<NSNumber *, GPKGFeatureShape *> *) featureIdsInDatabase: (NSString *) database withTable: (NSString *) table{
    
    NSMutableDictionary * tables = [self tablesInDatabase:database];
    NSMutableDictionary * featureIds = [self featureIdsInTables:tables withTable:table];
    return featureIds;
}

-(int) featureIdsCountInDatabase: (NSString *) database withTable: (NSString *) table{
    return (int) [self featureIdsInDatabase:database withTable:table].count;
}

-(NSMutableDictionary<NSNumber *, NSArray *> *) featureIdsInTables: (NSMutableDictionary *) tables withTable: (NSString *) table{
    
    NSMutableDictionary * featureIds = [tables objectForKey:table];
    if(featureIds == nil){
        featureIds = [NSMutableDictionary dictionary];
        [tables setObject:featureIds forKey:table];
    }
    return featureIds;
}

-(GPKGFeatureShape *) featureShapeInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId{
    
    NSMutableDictionary * featureIds = [self featureIdsInDatabase:database withTable:table];
    GPKGFeatureShape *featureShape = [self featureShapeInFeatureIds:featureIds withFeatureId:featureId];
    return featureShape;
}

-(int) featureShapeCountInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId{
    return [[self featureShapeInDatabase:database withTable:table withFeatureId:featureId] count];
}

-(GPKGFeatureShape *) featureShapeInFeatureIds: (NSMutableDictionary *) featureIds withFeatureId: (NSNumber *) featureId{
    
    GPKGFeatureShape *featureShape = [featureIds objectForKey:featureId];
    if(featureShape == nil){
        featureShape = [[GPKGFeatureShape alloc] initWithId:[featureId intValue]];
        [featureIds setObject:featureShape forKey:featureId];
    }
    return featureShape;
}

-(void) addMapShape: (GPKGMapShape *) mapShape withFeatureId: (NSNumber *) featureId toDatabase: (NSString *) database withTable: (NSString *) table{
    GPKGFeatureShape *featureShape = [self featureShapeInDatabase:database withTable:table withFeatureId:featureId];
    [featureShape addShape:mapShape];
}

-(void) addMapMetadataShape: (GPKGMapShape *) mapShape withFeatureId: (NSNumber *) featureId toDatabase: (NSString *) database withTable: (NSString *) table{
    GPKGFeatureShape *featureShape = [self featureShapeInDatabase:database withTable:table withFeatureId:featureId];
    [featureShape addMetadataShape:mapShape];
}

-(BOOL) existsWithFeatureId: (NSNumber *) featureId inDatabase: (NSString *) database withTable: (NSString *) table{
    BOOL exists = NO;
    NSMutableDictionary * tables = [_databases objectForKey:database];
    if(tables != nil){
        
        NSMutableDictionary * featureIds = [tables objectForKey:table];
        if(featureIds != nil){
            GPKGFeatureShape *shapes = [featureIds objectForKey:featureId];
            exists = shapes != nil && [shapes hasShapes];
        }
        
    }
    return exists;
}

-(int) removeShapesFromMapView: (MKMapView *) mapView{
    return [self removeShapesFromMapView:mapView withExclusions:nil];
}

-(int) removeShapesFromMapView: (MKMapView *) mapView withExclusion: (enum GPKGMapShapeType) excludedType{
    NSMutableSet *excludedTypes = [NSMutableSet set];
    [excludedTypes addObject:[NSNumber numberWithInt:excludedType]];
    return [self removeShapesFromMapView:mapView withExclusions:excludedTypes];
}

-(int) removeShapesFromMapView: (MKMapView *) mapView withExclusions: (NSSet<NSNumber *> *) excludedTypes{
    
    int count = 0;
    
    NSMutableArray<NSString *> *deleteDatabases = [NSMutableArray array];
    
    for(NSString *database in [self.databases allKeys]){
        
        count += [self removeShapesFromMapView:mapView inDatabase:database withExclusions:excludedTypes];
        
        if([self tablesCountInDatabase:database] <= 0){
            [deleteDatabases addObject:database];
        }
    }
    
    for(NSString *database in deleteDatabases){
        [_databases removeObjectForKey:database];
    }
    
    return count;
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database{
    return [self removeShapesFromMapView:mapView inDatabase:database withExclusions:nil];
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withExclusion: (enum GPKGMapShapeType) excludedType{
    NSMutableSet *excludedTypes = [NSMutableSet set];
    [excludedTypes addObject:[NSNumber numberWithInt:excludedType]];
    return [self removeShapesFromMapView:mapView inDatabase:database withExclusions:excludedTypes];
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withExclusions: (NSSet<NSNumber *> *) excludedTypes{

    int count = 0;
    
    NSMutableDictionary<NSString *, NSMutableDictionary *> *tables = [self tablesInDatabase:database];
    
    if(tables != nil){
        
        NSMutableArray<NSString *> *deleteTables = [NSMutableArray array];
        
        for(NSString *table in [tables allKeys]){
            
            count += [self removeShapesFromMapView:mapView inDatabase:database withTable:table withExclusions:excludedTypes];
            
            if([self featureIdsCountInDatabase:database withTable:table] <= 0){
                [deleteTables addObject:table];
            }
        }
        
        for(NSString *table in deleteTables){
            [tables removeObjectForKey:table];
        }
        
    }
    
    return count;
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table{
    return [self removeShapesFromMapView:mapView inDatabase:database withTable:table withExclusions:nil];
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table withExclusion: (enum GPKGMapShapeType) excludedType{
    NSMutableSet *excludedTypes = [NSMutableSet set];
    [excludedTypes addObject:[NSNumber numberWithInt:excludedType]];
    return [self removeShapesFromMapView:mapView inDatabase:database withTable:table withExclusions:excludedTypes];
}

-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table withExclusions: (NSSet<NSNumber *> *) excludedTypes{

    int count = 0;
    
    NSMutableDictionary<NSNumber *, GPKGFeatureShape *> *featureIds = [self featureIdsInDatabase:database withTable:table];
    
    if (featureIds != nil) {
        
        NSMutableArray *deleteFeatureIds = [NSMutableArray array];
        
        for(NSNumber *featureId in [featureIds allKeys]){
            
            GPKGFeatureShape *featureShape = [self featureShapeInFeatureIds:featureIds withFeatureId:featureId];
            
            if(featureShape != nil){
                
                NSMutableArray *deleteMapShapes = [NSMutableArray array];
                
                NSMutableArray<GPKGMapShape *> *mapShapes = [featureShape shapes];
                for(GPKGMapShape *mapShape in mapShapes){
                    if(excludedTypes == nil || ![excludedTypes containsObject:[NSNumber numberWithInt:mapShape.shapeType]]){
                        [mapShape removeFromMapView:mapView];
                        [deleteMapShapes addObject:mapShape];
                    }
                }
                
                [mapShapes removeObjectsInArray:deleteMapShapes];
                
            }
            
            if (featureShape == nil || ![featureShape hasShapes]) {
                if(featureShape != nil) {
                    [featureShape removeMetadataShapesFromMapView:mapView];
                }
                [deleteFeatureIds addObject:featureId];
                count++;
            }
            
        }
        
        [featureIds removeObjectsForKeys:deleteFeatureIds];
    }
    
    return count;
}

-(int) removeShapesNotWithinMapView: (MKMapView *) mapView{
 
    int count = 0;
    
    GPKGBoundingBox *boundingBox = [GPKGMapUtils boundingBoxOfMapView:mapView];
    
    for(NSString *database in [_databases allKeys]){
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
    
    NSMutableDictionary *tables = [self tablesInDatabase:database];
    
    if(tables != nil){
        
        for(NSString *table in [tables allKeys]){
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
    
    NSMutableDictionary * featureIds = [self featureIdsInDatabase:database withTable:table];
    
    if(featureIds != nil){
    
        NSMutableArray *deleteFeatureIds = [NSMutableArray array];
        
        for(NSNumber *featureId in [featureIds allKeys]){
            
            GPKGFeatureShape *featureShape = [self featureShapeInFeatureIds:featureIds withFeatureId:featureId];
            
            if(featureShape != nil){
            
                BOOL delete = YES;
                for(GPKGMapShape *mapShape in [featureShape shapes]){
                    GPKGBoundingBox *mapShapeBoundingBox = [mapShape boundingBox];
                    BOOL allowEmpty = mapShape.geometryType == SF_POINT;
                    if([GPKGTileBoundingBoxUtils overlapWithBoundingBox:mapShapeBoundingBox andBoundingBox:boundingBox withMaxLongitude:PROJ_WGS84_HALF_WORLD_LON_WIDTH andAllowEmpty:allowEmpty] != nil){
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
            
            GPKGFeatureShape *featureShape = [self featureShapeInFeatureIds:featureIds withFeatureId:deleteFeatureId];
            
            if(featureShape != nil){
                [featureShape removeFromMapView:mapView];
                [featureIds removeObjectForKey:deleteFeatureId];
            }
            count++;
        }
        
    }
    
    return count;
}

-(BOOL) removeFeatureShapeFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId{
    
    BOOL removed = NO;
    
    NSMutableDictionary<NSNumber *, GPKGFeatureShape *> *featureIds = [self featureIdsInDatabase:database withTable:table];
    if(featureIds != nil){
        GPKGFeatureShape *featureShape = [featureIds objectForKey:featureId];
        if(featureShape != nil){
            [featureIds removeObjectForKey:featureId];
            [featureShape removeFromMapView:mapView];
            removed = YES;
        }
    }
    
    return removed;
}

-(void) clear{
    [_databases removeAllObjects];
}

@end
