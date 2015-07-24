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

@interface GPKGGeoPackageManager : NSObject

-(NSArray *) databases;

-(int) count;

-(NSString *) pathForDatabase: (NSString *) database;

-(NSString *) documentsPathForDatabase: (NSString *) database;

-(BOOL) exists: (NSString *) database;

-(int) size: (NSString *) database;

-(NSString *) readableSize: (NSString *) database;

-(BOOL) delete: (NSString *) database;

-(BOOL) deleteAll;

-(BOOL) create: (NSString *) database;

-(BOOL) create: (NSString *) database inDirectory: (NSString *) dbDirectory;

-(BOOL) importGeoPackageFromPath: (NSString *) path;

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name;

-(BOOL) importGeoPackageFromPath: (NSString *) path inDirectory: (NSString *) dbDirectory;

-(BOOL) importGeoPackageFromPath: (NSString *) path andOverride: (BOOL) override;

-(BOOL) importGeoPackageFromPath: (NSString *) path andOverride: (BOOL) override andMove: (BOOL) moveFile;

-(BOOL) importGeoPackageFromPath: (NSString *) path inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override;

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name andOverride: (BOOL) override;

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory;

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override;

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override andMove: (BOOL) moveFile;

-(void) importGeoPackageFromUrl: (NSURL *) url;

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name;

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory;

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name andProgress: (NSObject<GPKGProgress> *) progress;

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name andOverride: (BOOL) override;

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andProgress: (NSObject<GPKGProgress> *) progress;

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override;

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override andProgress: (NSObject<GPKGProgress> *) progress;

-(void) exportGeoPackage: (NSString *) database toDirectory: (NSString *) directory;

-(void) exportGeoPackage: (NSString *) database withName: (NSString *) name toDirectory: (NSString *) directory;

-(GPKGGeoPackage *) open: (NSString *) database;

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy;

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy andSameDirectory: (BOOL) sameDirectory;

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase;

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase andRenameFile: (BOOL) renameFile;

-(BOOL) move: (NSString *) database toDirectory: (NSString *) dbDirectory;

@end
