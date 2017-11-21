//
//  GPKGFeatureShapes.h
//  Pods
//
//  Created by Brian Osborn on 9/14/17.
//
//

#import <Foundation/Foundation.h>
#import "GPKGMapShape.h"

/**
 *  Mantains a collection of feature map shapes by database, table name, and feature id
 */
@interface GPKGFeatureShapes : NSObject

/**
 *  Initializer
 *
 *  @return new feature shapes
 */
-(instancetype) init;

/**
 *  Get the mapping between databases and tables
 *
 *  @return databases to tables mapping
 */
-(NSDictionary<NSString *, NSDictionary *> *) databases;

/**
 *  Get the databases count
 *
 *  @return databases count
 */
-(int) databasesCount;

/**
 *  Get the mapping between tables and feature ids for the database
 *
 *  @param database GeoPackage database
 *
 *  @return tables to feature ids mapping
 */
-(NSDictionary<NSString *, NSDictionary *> *) tablesInDatabase: (NSString *) database;

/**
 *  Get the tables count for the database
 *
 *  @param database GeoPackage database
 *
 *  @return tables count
 */
-(int) tablesCountInDatabase: (NSString *) database;

/**
 *  Get the mapping between feature ids and map shapes for the database and table
 *
 *  @param database GeoPackage database
 *  @param table table name
 *
 *  @return feature ids to map shapes mapping
 */
-(NSDictionary<NSString *, NSArray *> *) featureIdsInDatabase: (NSString *) database withTable: (NSString *) table;

/**
 *  Get the feature ids count for the database and table
 *
 *  @param database GeoPackage database
 *  @param table table name
 *
 *  @return feature ids count
 */
-(int) featureIdsCountInDatabase: (NSString *) database withTable: (NSString *) table;

/**
 *  Get the map shapes for the database, table, and feature id
 *
 *  @param database GeoPackage database
 *  @param table table name
 *  @param featureId feature id
 *
 *  @return map shapes
 */
-(NSArray<GPKGMapShape *> *) shapesInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId;

/**
 *  Get the map shapes count for the database, table, and feature id
 *
 *  @param database GeoPackage database
 *  @param table table name
 *  @param featureId feature id
 *
 *  @return map shapes count
 */
-(int) shapesCountInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId;

/**
 *  Add a map shape with the feature id, database, and table
 *
 *  @param mapShape map shape
 *  @param featureId feature id
 *  @param database GeoPackage database
 *  @param table table name
 */
-(void) addMapShape: (GPKGMapShape *) mapShape withFeatureId: (NSNumber *) featureId toDatabase: (NSString *) database withTable: (NSString *) table;

/**
 *  Check if map shapes exist for the feature id, database, and table
 *
 *  @param featureId feature id
 *  @param database GeoPackage database
 *  @param table table name
 */
-(BOOL) existsWithFeatureId: (NSNumber *) featureId inDatabase: (NSString *) database withTable: (NSString *) table;

/**
 *  Remove all map shapes from the map view
 *
 *  @param mapView map view
 *  
 *  @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView;

/**
 *  Remove all map shapes in the database from the map view
 *
 *  @param mapView map view
 *  @param database GeoPackage database
 *
 *  @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database;

/**
 *  Remove all map shapes in the database and table from the map view
 *
 *  @param mapView map view
 *  @param database GeoPackage database
 *  @param table table name
 *
 *  @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table;

/**
 *  Remove all map shapes that are not visible in the map view
 *
 *  @param mapView map view
 *
 *  @return count of removed features
 */
-(int) removeShapesNotWithinMapView: (MKMapView *) mapView;

/**
 *  Remove all map shapes in the database that are not visible in the map view
 *
 *  @param mapView map view
 *  @param database GeoPackage database
 *
 *  @return count of removed features
 */
-(int) removeShapesNotWithinMapView: (MKMapView *) mapView inDatabase: (NSString *) database;

/**
 *  Remove all map shapes in the database and table that are not visible in the map view
 *
 *  @param mapView map view
 *  @param database GeoPackage database
 *  @param table table name
 *
 *  @return count of removed features
 */
-(int) removeShapesNotWithinMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table;

-(void) clear;

@end
