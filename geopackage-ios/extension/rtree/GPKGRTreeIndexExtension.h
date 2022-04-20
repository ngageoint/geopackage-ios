//
//  GPKGRTreeIndexExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/18/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGRTreeIndexTableDao.h"

@class GPKGRTreeIndexTableDao;

extern NSString * const GPKG_RTREE_INDEX_EXTENSION_NAME;
extern NSString * const GPKG_RTREE_INDEX_PREFIX;
extern NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_ID;
extern NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_X;
extern NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_X;
extern NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MIN_Y;
extern NSString * const GPKG_RTREE_INDEX_EXTENSION_COLUMN_MAX_Y;

/**
 * RTree Index Extension
 * <p>
 * <a href="https://www.geopackage.org/spec/#extension_rtree">https://www.geopackage.org/spec/#extension_rtree</a>
 */
@interface GPKGRTreeIndexExtension : GPKGBaseExtension

/**
 *  Extension name
 */
@property (nonatomic, strong) NSString *extensionName;

/**
 *  Extension definition URL
 */
@property (nonatomic, strong) NSString *definition;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get a RTree Index Table DAO for the feature table
 *
 *  @param featureTable feature table
 *
 *  @return RTree Index Table DAO
 */
-(GPKGRTreeIndexTableDao *) tableDaoWithFeatureTable: (NSString *) featureTable;

/**
 *  Get a RTree Index Table DAO for the feature dao
 *
 *  @param featureDao feature dao
 *
 *  @return RTree Index Table DAO
 */
-(GPKGRTreeIndexTableDao *) tableDaoWithFeatureDao: (GPKGFeatureDao *) featureDao;
    
/**
 * Get or create the extension
 *
 * @param featureTable
 *            feature table
 * @return extension
 */
-(GPKGExtensions *) extensionCreateWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Get or create the extension
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @return extension
 */
-(GPKGExtensions *) extensionCreateWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 * Determine if the GeoPackage feature table has the extension
 *
 * @param featureTable
 *            feature table
 * @return true if has extension
 */
-(BOOL) hasWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Determine if the GeoPackage table and column has the extension
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @return true if has extension
 */
-(BOOL) hasWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 * Determine if the GeoPackage table has the extension
 *
 * @param tableName
 *            table name
 * @return true if has extension
 */
-(BOOL) hasWithTableName: (NSString *) tableName;

/**
 *  Determine if the GeoPackage has the extension for any table
 *
 *  @return true if has extension
 */
-(BOOL) has;

/**
 * Check if the feature table has the RTree extension and create the
 * functions if needed
 *
 * @param featureTable
 *            feature table
 * @return true if has extension and functions created
 */
-(BOOL) createFunctionsWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Check if the table and column has the RTree extension and create the
 * functions if needed
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @return true if has extension and functions created
 */
-(BOOL) createFunctionsWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 * Check if the GeoPackage has the RTree extension and create the functions
 * if needed
 *
 * @return true if has extension and functions created
 */
-(BOOL) createFunctions;

/**
 * Create the RTree Index extension for the feature table. Creates the SQL
 * functions, loads the tree, and creates the triggers.
 *
 * @param featureTable
 *            feature table
 * @return extension
 */
-(GPKGExtensions *) createWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Create the RTree Index extension for the feature table, geometry column,
 * and id column. Creates the SQL functions, loads the tree, and creates the
 * triggers.
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 * @return extension
 */
-(GPKGExtensions *) createWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create the RTree Index Virtual Table
 *
 * @param featureTable
 *            feature table
 */
-(void) createRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Create the RTree Index Virtual Table
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) createRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Create all connection SQL Functions for min x, max x, min y, max y, and
 * is empty
 */
-(void) createAllFunctions;

/**
 * Create the min x SQL function
 */
-(void) createMinXFunction;

/**
 * Create the max x SQL function
 */
-(void) createMaxXFunction;

/**
 * Create the min y SQL function
 */
-(void) createMinYFunction;

/**
 * Create the max y SQL function
 */
-(void) createMaxYFunction;

/**
 * Create the is empty SQL function
 */
-(void) createIsEmptyFunction;

/**
 * Load the RTree Spatial Index Values
 *
 * @param featureTable
 *            feature table
 */
-(void) loadRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Load the RTree Spatial Index Values
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) loadRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create Triggers to Maintain Spatial Index Values
 *
 * @param featureTable
 *            feature table
 */
-(void) createAllTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Create Triggers to Maintain Spatial Index Values
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) createAllTriggersWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create insert trigger
 *
 * <pre>
 * Conditions: Insertion of non-empty geometry
 * Actions   : Insert record into rtree
 * </pre>
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) createInsertTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create update 1 trigger
 *
 * <pre>
 * Conditions: Update of geometry column to non-empty geometry
 *             No row ID change
 * Actions   : Update record in rtree
 * </pre>
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) createUpdate1TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create update 2 trigger
 *
 * <pre>
 * Conditions: Update of geometry column to empty geometry
 *             No row ID change
 * Actions   : Remove record from rtree
 * </pre>
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) createUpdate2TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create update 3 trigger
 *
 * <pre>
 * Conditions: Update of any column
 *             Row ID change
 *             Non-empty geometry
 * Actions   : Remove record from rtree for old &lt;i&gt;
 *             Insert record into rtree for new &lt;i&gt;
 * </pre>
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) createUpdate3TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create update 4 trigger
 *
 * <pre>
 * Conditions: Update of any column
 *             Row ID change
 *             Empty geometry
 * Actions   : Remove record from rtree for old and new &lt;i&gt;
 * </pre>
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) createUpdate4TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Create delete trigger
 *
 * <pre>
 * Conditions: Row deleted
 * Actions   : Remove record from rtree for old &lt;i&gt;
 * </pre>
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param idColumnName
 *            id column name
 */
-(void) createDeleteTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andIdColumnName: (NSString *) idColumnName;

/**
 * Delete the RTree Index extension for the feature table. Drops the
 * triggers, RTree table, and deletes the extension.
 *
 * @param featureTable
 *            feature table
 */
-(void) deleteWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Delete the RTree Index extension for the table and geometry column. Drops
 * the triggers, RTree table, and deletes the extension.
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) deleteWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Delete all RTree Index extensions for the table. Drops the triggers,
 * RTree tables, and deletes the extensions.
 *
 * @param tableName
 *            table name
 */
-(void) deleteWithTableName: (NSString *) tableName;

/**
 * Delete all RTree Index extensions. Drops the triggers, RTree tables, and
 * deletes the extensions.
 */
-(void) deleteAll;

/**
 * Drop the the triggers and RTree table for the feature table
 *
 * @param featureTable
 *            feature table
 */
-(void) dropWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Drop the the triggers and RTree table for the table and geometry column
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop the RTree Index Virtual Table
 *
 * @param featureTable
 *            feature table
 */
-(void) dropRTreeIndexWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Drop the RTree Index Virtual Table
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropRTreeIndexWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Check if the feature table has the RTree extension and if found, drop the
 * triggers
 *
 * @param featureTable
 *            feature table
 */
-(void) dropTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Check if the table and column has the RTree extension and if found, drop
 * the triggers
 *
 * @param tableName
 *            table name
 * @param columnName
 *            column name
 * @return true if dropped
 */
-(BOOL) dropTriggersWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName;

/**
 * Drop Triggers that Maintain Spatial Index Values
 *
 * @param featureTable
 *            feature table
 */
-(void) dropAllTriggersWithFeatureTable: (GPKGFeatureTable *) featureTable;

/**
 * Drop Triggers that Maintain Spatial Index Values
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropAllTriggersWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop insert trigger
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropInsertTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop update 1 trigger
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropUpdate1TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop update 2 trigger
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropUpdate2TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop update 3 trigger
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropUpdate3TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop update 4 trigger
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropUpdate4TriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop delete trigger
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 */
-(void) dropDeleteTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName;

/**
 * Drop the trigger for the table, geometry column, and trigger name
 *
 * @param tableName
 *            table name
 * @param geometryColumnName
 *            geometry column name
 * @param triggerName
 *            trigger name
 */
-(void) dropTriggerWithTableName: (NSString *) tableName andGeometryColumnName: (NSString *) geometryColumnName andTriggerName: (NSString *) triggerName;

@end
