//
//  GPKGGeoPackageManager.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@interface GPKGGeoPackageManager : NSObject

-(NSArray *) databases;

-(NSDictionary *) databasePaths;

-(int) count;

-(NSString *) pathForDatabase: (NSString *) database;

-(BOOL) exists: (NSString *) database;

-(int) size: (NSString *) database;

-(NSString *) readableSize: (NSString *) database;

-(BOOL) delete: (NSString *) database;

-(BOOL) create: (NSString *) database;

-(BOOL) importGeoPackageFromPath: (NSString *) path andDatabase: (NSString *) database;

-(BOOL) importGeoPackageFromUrl: (NSURL *) url andDatabase: (NSString *) database;

-(GPKGGeoPackage *) open: (NSString *) database;

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy;

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase;

@end
