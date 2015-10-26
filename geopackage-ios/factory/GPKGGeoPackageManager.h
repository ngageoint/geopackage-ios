//
//  GPKGGeoPackageManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGProgress.h"

/**
 *  GeoPackage Database management. Maintains an active connection to the metadata database, close when done.
 */
@interface GPKGGeoPackageManager : NSObject

/**
 *  Metadata database connection
 */
@property (nonatomic, strong)  GPKGMetadataDb * metadataDb;

/**
 *  Initialize
 *
 *  @return manager
 */
-(instancetype) init;

/**
 *  Close the manager connection
 */
-(void) close;

/**
 *  List all GeoPackage databases sorted alphabetically
 *
 *  @return database names
 */
-(NSArray *) databases;

/**
 *  Get the count of GeoPackage databases
 *
 *  @return database count
 */
-(int) count;

/**
 *  Get the path of the database
 *
 *  @param database database name
 *
 *  @return path
 */
-(NSString *) pathForDatabase: (NSString *) database;

/**
 *  Get the documents path for the database
 *
 *  @param database database name
 *
 *  @return documents path
 */
-(NSString *) documentsPathForDatabase: (NSString *) database;

/**
 *  Check if the database exists
 *
 *  @param database database name
 *
 *  @return true if exists, false if not
 */
-(BOOL) exists: (NSString *) database;

/**
 *  Size of the database in bytes
 *
 *  @param database database name
 *
 *  @return bytes
 */
-(int) size: (NSString *) database;

/**
 *  Get a readable version of the database size
 *
 *  @param database database name
 *
 *  @return string size
 */
-(NSString *) readableSize: (NSString *) database;

/**
 *  Delete a database
 *
 *  @param database database name
 *
 *  @return true if deleted
 */
-(BOOL) delete: (NSString *) database;

/**
 *  Delete all databases
 *
 *  @return true if deleted
 */
-(BOOL) deleteAll;

/**
 *  Create a new GeoPackage database
 *
 *  @param database database name
 *
 *  @return true if created
 */
-(BOOL) create: (NSString *) database;

/**
 *  Create a new GeoPackage database in specified directory
 *
 *  @param database    database name
 *  @param dbDirectory directory
 *
 *  @return true if created
 */
-(BOOL) create: (NSString *) database inDirectory: (NSString *) dbDirectory;

/**
 *  Import a GeoPackage file from a path
 *
 *  @param path Geopackage path
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path;

/**
 *  Import a GeoPackage file from a path and name it
 *
 *  @param path GeoPackage path
 *  @param name creation name
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name;

/**
 *  Import a GeoPackage file from a path into a directory
 *
 *  @param path        GeoPackage path
 *  @param dbDirectory directory
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path inDirectory: (NSString *) dbDirectory;

/**
 *  Import a GeoPackage file from a path with existing file override option
 *
 *  @param path     GeoPackage path
 *  @param override true to override an existing GeoPackage
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path andOverride: (BOOL) override;

/**
 *  Import a GeoPackage file from a path with existing file override and move instead of copy option
 *
 *  @param path     GeoPackage path
 *  @param override true to override an existing GeoPackage
 *  @param moveFile true to move GeoPackage instead of copying
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path andOverride: (BOOL) override andMove: (BOOL) moveFile;

/**
 *  Import a GeoPackage file from a path into a directory with existing file override option
 *
 *  @param path        GeoPackage path
 *  @param dbDirectory directory
 *  @param override    true to override an existing GeoPackage
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override;

/**
 *  Import a GeoPackage file from a path and name it with existing file override option
 *
 *  @param path     GeoPackage path
 *  @param name     creation name
 *  @param override true to override an existing GeoPackage
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name andOverride: (BOOL) override;

/**
 *  Import a GeoPackage file from a path and name it into a directory
 *
 *  @param path        GeoPackage path
 *  @param name        creation name
 *  @param dbDirectory directory
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory;

/**
 *  Import a GeoPackage file from a path and name it into a directory with existing file overide option
 *
 *  @param path        GeoPackage path
 *  @param name        creation name
 *  @param dbDirectory directory
 *  @param override    true to override an existing GeoPackage
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override;

/**
 *  Import a GeoPackage file from a path and name it into a directory with existing file overide and move instead of copy option
 *
 *  @param path        GeoPackage path
 *  @param name        creation name
 *  @param dbDirectory directory
 *  @param override    true to override an existing GeoPackage
 *  @param moveFile    true to move GeoPackage instead of copying
 *
 *  @return true if imported
 */
-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override andMove: (BOOL) moveFile;

/**
 *  Import a GeoPackage file from a URL
 *
 *  @param url url
 */
-(void) importGeoPackageFromUrl: (NSURL *) url;

/**
 *  Import a GeoPackage file from a URL and name it
 *
 *  @param url  url
 *  @param name creation name
 */
-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name;

/**
 *  Import a GeoPackage file from a URL and name it into a directory
 *
 *  @param url         url
 *  @param name        creation name
 *  @param dbDirectory directory
 */
-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory;

/**
 *  Import a GeoPackage file from a URL and name it with progress callbacks
 *
 *  @param url      url
 *  @param name     creation name
 *  @param progress progress callback
 */
-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name andProgress: (NSObject<GPKGProgress> *) progress;

/**
 *   Import a GeoPackage file from a URL and name it with existing file overide option
 *
 *  @param url      url
 *  @param name     creation name
 *  @param override true to override an existing GeoPackage
 */
-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name andOverride: (BOOL) override;

/**
 *  Import a GeoPackage file from a URL and name it into a directory with progress callbacks
 *
 *  @param url         url
 *  @param name        creation name
 *  @param dbDirectory directory
 *  @param progress    progress callback
 */
-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andProgress: (NSObject<GPKGProgress> *) progress;

/**
 *  Import a GeoPackage file from a URL and name it into a directory with existing file overide option
 *
 *  @param url         url
 *  @param name        creation name
 *  @param dbDirectory directory
 *  @param override    true to override an existing GeoPackage
 */
-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override;

/**
 *  Import a GeoPackage file from a URL and name it into a directory with existing file overide option and progress callbacks
 *
 *  @param url         url
 *  @param name        creation name
 *  @param dbDirectory directory
 *  @param override    true to override an existing GeoPackage
 *  @param progress    progress callback
 */
-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override andProgress: (NSObject<GPKGProgress> *) progress;

/**
 *  Export a GeoPackage to a directory
 *
 *  @param database  database name
 *  @param directory directory
 */
-(void) exportGeoPackage: (NSString *) database toDirectory: (NSString *) directory;

/**
 *  Export a GeoPackage to a directory and name it
 *
 *  @param database  database name
 *  @param name      export save name
 *  @param directory directory
 */
-(void) exportGeoPackage: (NSString *) database withName: (NSString *) name toDirectory: (NSString *) directory;

/**
 *  Open a GeoPackage database
 *
 *  @param database database name
 *
 *  @return GeoPackage
 */
-(GPKGGeoPackage *) open: (NSString *) database;

/**
 *  Copy a GeoPackage into the same directory
 *
 *  @param database     database name
 *  @param databaseCopy new copy database name
 *
 *  @return true if copied
 */
-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy;

/**
 *  Copy a GeoPackage with same directory option
 *
 *  @param database      database name
 *  @param databaseCopy  new copy database name
 *  @param sameDirectory true to copy into same directory, false to copy into manager default directory
 *
 *  @return true if copied
 */
-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy andSameDirectory: (BOOL) sameDirectory;

/**
 *  Rename a GeoPackage and it's file
 *
 *  @param database    database name
 *  @param newDatabase new database name
 *
 *  @return true if renamed
 */
-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase;

/**
 *  Rename a GeoPackage with rename file option
 *
 *  @param database    database name
 *  @param newDatabase new database name
 *  @param renameFile  true to rename file, false to preserve file name
 *
 *  @return true if renamed
 */
-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase andRenameFile: (BOOL) renameFile;

/**
 *  Move a GeoPackage to a different directory
 *
 *  @param database    database name
 *  @param dbDirectory new directory location
 *
 *  @return true if moved
 */
-(BOOL) move: (NSString *) database toDirectory: (NSString *) dbDirectory;

@end
