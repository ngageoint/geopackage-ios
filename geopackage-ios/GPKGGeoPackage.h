//
//  GPKGGeoPackage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "GPKGConnection.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGContentsDao.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGFeatureTable.h"
#import "GPKGFeatureDao.h"
#import "GPKGTileDao.h"
#import "GPKGBoundingBox.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGTileMatrixDao.h"
#import "GPKGTileTable.h"
#import "GPKGDataColumnsDao.h"
#import "GPKGDataColumnConstraintsDao.h"
#import "GPKGMetadataDao.h"
#import "GPKGMetadataReferenceDao.h"
#import "GPKGExtensionsDao.h"

@interface GPKGGeoPackage : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic) GPKGConnection *database;
@property (nonatomic) BOOL writable;

-(instancetype) initWithConnection: (GPKGConnection *) database andWritable: (BOOL) writable;

-(void)close;

-(NSArray *)getFeatureTables;

-(NSArray *)getTileTables;

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao;

-(GPKGContentsDao *) getContentsDao;

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao;

-(BOOL) createGeometryColumnsTable;

-(void) createFeatureTable: (GPKGFeatureTable *) table;

-(GPKGGeometryColumns *) createFeatureTableWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns
                                                andBoundingBox: (GPKGBoundingBox *) boundingBox
                                                andSrsId: (NSNumber *) srsId;

-(GPKGTileMatrixSetDao *) getTileMatrixSetDao;

-(BOOL) createTileMatrixSetTable;

-(GPKGTileMatrixDao *) getTileMatrixDao;

-(BOOL) createTileMatrixTable;

-(void) createTileTable: (GPKGTileTable *) table;

-(GPKGTileMatrixSet *) createTileTableWithTableName: (NSString *) tableName
                                                andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox
                                                andContentsSrsId: (NSNumber *) contentsSrsId
                                                andTileMatrixSetBoundingBox: (GPKGBoundingBox *) tileMatrixSetBoundingBox
                                                andTileMatrixSetSrsId: (NSNumber *) tileMatrixSetSrsId;

-(GPKGDataColumnsDao *) getDataColumnsDao;

-(BOOL) createDataColumnsTable;

-(GPKGDataColumnConstraintsDao *) getDataColumnConstraintsDao;

-(BOOL) createDataColumnConstraintsTable;

-(GPKGMetadataDao *) getMetadataDao;

-(BOOL) createMetadataTable;

-(GPKGMetadataReferenceDao *) getMetadataReferenceDao;

-(BOOL) createMetadataReferenceTable;

-(GPKGExtensionsDao *) getExtensionsDao;

-(BOOL) createExtensionsTable;

-(void) deleteUserTable: (NSString *) tableName;

-(void) deleteUserTableQuietly: (NSString *) tableName;

-(void) verifyWritable;

-(GPKGFeatureDao *) getFeatureDaoWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

-(GPKGFeatureDao *) getFeatureDaoWithContents: (GPKGContents *) contents;

-(GPKGFeatureDao *) getFeatureDaoWithTableName: (NSString *) tableName;

-(GPKGTileDao *) getTileDaoWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

-(GPKGTileDao *) getTileDaoWithContents: (GPKGContents *) contents;

-(GPKGTileDao *) getTileDaoWithTableName: (NSString *) tableName;

@end
