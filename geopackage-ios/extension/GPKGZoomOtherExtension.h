//
//  GPKGZoomOtherExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"

extern NSString * const GPKG_ZOOM_OTHER_EXTENSION_NAME;

/**
 *  Zoom Other Intervals extension
 */
@interface GPKGZoomOtherExtension : GPKGBaseExtension

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
 *  Get or create the extension
 *
 *  @param tableName table name
 *
 *  @return extension
 */
-(GPKGExtensions *) getOrCreateWithTableName: (NSString *) tableName;

/**
 *  Determine if the GeoPackage has the extension
 *
 *  @param tableName table name
 *
 *  @return true if has extension
 */
-(BOOL) hasWithTableName: (NSString *) tableName;

@end
