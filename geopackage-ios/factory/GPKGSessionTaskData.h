//
//  GPKGSessionTaskData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/17.
//
//

#import <Foundation/Foundation.h>
#import "GPKGProgress.h"
#import "GPKGGeoPackageManager.h"

/**
 *  GeoPackage additional session task data stored as an associated object
 */
@interface GPKGSessionTaskData : NSObject

/**
 *  Original URL request
 */
@property (nonatomic, strong) NSURL *url;

/**
 *  New GeoPackage name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  The new GeoPackage database path
 */
@property (nonatomic, strong) NSString *databasePath;

/**
 *  The full documents GeoPackage database path
 */
@property (nonatomic, strong) NSString *documentsDatabasePath;

/**
 *  Optional progress callback
 */
@property (nonatomic, strong) NSObject<GPKGProgress> *progress;

@end
