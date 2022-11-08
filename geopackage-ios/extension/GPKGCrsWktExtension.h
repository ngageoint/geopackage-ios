//
//  GPKGCrsWktExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/3/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGGeoPackage.h"
#import "GPKGCrsWktExtensionVersions.h"

extern NSString * const GPKG_CRS_WKT_EXTENSION_NAME;

/**
 *  OGC Well known text representation of Coordinate Reference Systems extension
 *  <p>
 * <a href="http://www.geopackage.org/spec/#extension_crs_wkt">http://www.geopackage.org/spec/#extension_crs_wkt</a>
 */
@interface GPKGCrsWktExtension : GPKGBaseExtension

/**
 *  Extension name
 */
@property (nonatomic, strong) NSString *extensionName;

/**
 *  Extension version 1 definition URL
 */
@property (nonatomic, strong) NSString *definitionV1;

/**
 *  Extension version 1.1 definition URL
 */
@property (nonatomic, strong) NSString *definitionV1_1;

/**
 *  Extension definition column name
 */
@property (nonatomic, strong) NSString *definitionColumnName;

/**
 *  Extension definition column definition
 */
@property (nonatomic, strong) NSString *definitionColumnDef;

/**
 *  Extension epoch column name
 */
@property (nonatomic, strong) NSString *epochColumnName;

/**
 *  Extension epoch column definition
 */
@property (nonatomic, strong) NSString *epochColumnDef;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get or create the latest version of the extension
 *
 *  @return extension
 */
-(NSArray<GPKGExtensions *> *) extensionCreate;

/**
 *  Get or create the version of the extension
 *
 *  @param version extension version
 *  @return extension
 */
-(NSArray<GPKGExtensions *> *) extensionCreateVersion: (enum GPKGCrsWktExtensionVersion) version;

/**
 *  Determine if the GeoPackage has any version of the extension
 *
 *  @return true if has extension
 */
-(BOOL) has;

/**
 * Determine if the GeoPackage has at least the minimum version of the
 * extension
 *
 * @param version
 *            extension version
 * @return true if has extension minimum
 */
-(BOOL) hasMinimum: (enum GPKGCrsWktExtensionVersion) version;

/**
 * Determine if the GeoPackage has the version of the extension
 *
 * @param version
 *            extension version
 * @return true if has extension
 */
-(BOOL) hasVersion: (enum GPKGCrsWktExtensionVersion) version;

/**
 * Get the extension name for the version
 *
 * @param version
 *            extension version
 * @return extension name
 */
-(NSString *) extensionName: (enum GPKGCrsWktExtensionVersion) version;

/**
 *  Update the extension definition
 *
 *  @param definition definition
 *  @param srsId      srs id
 */
-(void) updateDefinition: (NSString *) definition withSrsId: (NSNumber *) srsId;

/**
 *  Get the extension definition
 *
 *  @param srsId srs id
 *
 *  @return definition
 */
-(NSString *) definitionWithSrsId:(NSNumber *) srsId;

/**
 *  Update the extension epoch
 *
 *  @param epoch   epoch
 *  @param srsId      srs id
 */
-(void) updateEpoch: (NSDecimalNumber *) epoch withSrsId: (NSNumber *) srsId;

/**
 *  Get the extension epoch
 *
 *  @param srsId srs id
 *
 *  @return epoch
 */
-(NSDecimalNumber *) epochWithSrsId: (NSNumber *) srsId;

/**
 *  Determine if the GeoPackage SRS table has the extension definition column
 *
 *  @return true if has column
 */
-(BOOL) hasDefinitionColumn;

/**
 *  Determine if the GeoPackage SRS table has the extension epoch column
 *
 *  @return true if has column
 */
-(BOOL) hasEpochColumn;

/**
 * Remove the extension. Leaves the column and values.
 */
-(void) removeExtension;

/**
 * Remove the extension. Leaves the column and values.
 *
 * @param version extension version
 */
-(void) removeExtension: (enum GPKGCrsWktExtensionVersion) version;

@end
