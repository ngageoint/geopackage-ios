//
//  GPKGFeatureShapes.h
//  Pods
//
//  Created by Brian Osborn on 9/14/17.
//
//

#import <Foundation/Foundation.h>
#import "GPKGMapShape.h"
#import "GPKGFeatureShape.h"

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
-(NSMutableDictionary<NSString *, NSMutableDictionary *> *) databases;

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
-(NSMutableDictionary<NSString *, NSMutableDictionary *> *) tablesInDatabase: (NSString *) database;

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
-(NSMutableDictionary<NSNumber *, GPKGFeatureShape *> *) featureIdsInDatabase: (NSString *) database withTable: (NSString *) table;

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
 *  Get the feature shape for the database, table, and feature id
 *
 *  @param database GeoPackage database
 *  @param table table name
 *  @param featureId feature id
 *
 *  @return feature shape
 */
-(GPKGFeatureShape *) featureShapeInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId;

/**
 *  Get the feature shape count for the database, table, and feature id
 *
 *  @param database GeoPackage database
 *  @param table table name
 *  @param featureId feature id
 *
 *  @return map shapes count
 */
-(int) featureShapeCountInDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId;

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
 *  Add a map metadata shape with the feature id, database, and table
 *
 *  @param mapShape map shape
 *  @param featureId feature id
 *  @param database GeoPackage database
 *  @param table table name
 */
-(void) addMapMetadataShape: (GPKGMapShape *) mapShape withFeatureId: (NSNumber *) featureId toDatabase: (NSString *) database withTable: (NSString *) table;

/**
 *  Check if map shapes exist for the feature id, database, and table
 *
 *  @param featureId feature id
 *  @param database GeoPackage database
 *  @param table table name
 */
-(BOOL) existsWithFeatureId: (NSNumber *) featureId inDatabase: (NSString *) database withTable: (NSString *) table;

/**
 * Remove all map shapes from the map
 *
 * @param mapView map view
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView;

/**
 * Remove all map shapes from the map, excluding shapes with the excluded type
 *
 * @param mapView      map view
 * @param excludedType Map Shape Type to exclude from map removal
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView withExclusion: (enum GPKGMapShapeType) excludedType;

/**
 * Remove all map shapes from the map, excluding shapes with the excluded types
 *
 * @param mapView       map view
 * @param excludedTypes Map Shape Types to exclude from map removal
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView withExclusions: (NSSet<NSNumber *> *) excludedTypes;

/**
 * Remove all map shapes in the database from the map
 *
 * @param mapView  map view
 * @param database GeoPackage database
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database;

/**
 * Remove all map shapes in the database from the map, excluding shapes with the excluded type
 *
 * @param mapView      map view
 * @param database     GeoPackage database
 * @param excludedType Map Shape Type to exclude from map removal
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withExclusion: (enum GPKGMapShapeType) excludedType;

/**
 * Remove all map shapes in the database from the map, excluding shapes with the excluded types
 *
 * @param mapView       map view
 * @param database      GeoPackage database
 * @param excludedTypes Map Shape Types to exclude from map removal
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withExclusions: (NSSet<NSNumber *> *) excludedTypes;

/**
 * Remove all map shapes in the database and table from the map
 *
 * @param mapView  map view
 * @param database GeoPackage database
 * @param table    table name
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table;

/**
 * Remove all map shapes in the database and table from the map, excluding shapes with the excluded type
 *
 * @param mapView      map view
 * @param database     GeoPackage database
 * @param table        table name
 * @param excludedType Map Shape Type to exclude from map removal
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table withExclusion: (enum GPKGMapShapeType) excludedType;

/**
 * Remove all map shapes in the database and table from the map, excluding shapes with the excluded types
 *
 * @param mapView       map view
 * @param database      GeoPackage database
 * @param table         table name
 * @param excludedTypes Map Shape Types to exclude from map removal
 * @return count of removed features
 */
-(int) removeShapesFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table withExclusions: (NSSet<NSNumber *> *) excludedTypes;

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
 *  @param mapView  map view
 *  @param database GeoPackage database
 *
 *  @return count of removed features
 */
-(int) removeShapesNotWithinMapView: (MKMapView *) mapView inDatabase: (NSString *) database;

/**
 * Remove all map shapes in the database that are not visible in the bounding box
 *
 * @param mapView     map view
 * @param boundingBox bounding box
 * @param database    GeoPackage database
 * @return count of removed features
 */
-(int) removeShapesNotWithinMapView: (MKMapView *) mapView withBoundingBox: (GPKGBoundingBox *) boundingBox inDatabase: (NSString *) database;

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

/**
 * Remove all map shapes in the database and table that are not visible in the bounding box
 *
 * @param mapView     map view
 * @param boundingBox bounding box
 * @param database    GeoPackage database
 * @param table table name
 * @return count of removed features
 */
-(int) removeShapesNotWithinMapView: (MKMapView *) mapView withBoundingBox: (GPKGBoundingBox *) boundingBox inDatabase: (NSString *) database withTable: (NSString *) table;

/**
 * Remove the feature shape from the database and table
 *
 * @param database  GeoPackage database
 * @param table     table name
 * @param featureId feature id
 * @return true if removed
 */
-(BOOL) removeFeatureShapeFromMapView: (MKMapView *) mapView inDatabase: (NSString *) database withTable: (NSString *) table withFeatureId: (NSNumber *) featureId;

/**
 * Clear
 */
-(void) clear;

@end
