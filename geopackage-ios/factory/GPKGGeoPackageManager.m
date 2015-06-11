//
//  GPKGGeoPackageManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGTableCreator.h"
#import "GPKGIOUtils.h"

@implementation GPKGGeoPackageManager

-(NSArray *) databases{
    NSDictionary * databaseFiles = [self databasePaths];
    NSArray * databases = [databaseFiles allKeys];
    return databases;
}

-(NSDictionary *) databasePaths{
    NSMutableDictionary * databases = [[NSMutableDictionary alloc] init];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * databaseDirectory = [GPKGIOUtils databaseDirectory];
    NSError *error = nil;
    NSArray * dbFiles = [fileManager contentsOfDirectoryAtPath:databaseDirectory error:&error];
    if(error){
        [NSException raise:@"Databases" format:@"Failed to get the list of databases with error: %@", error];
    }
    for(NSString * dbFile in dbFiles){
        NSString * extension = [dbFile pathExtension];
        if([extension caseInsensitiveCompare:GPKG_GEOPACKAGE_EXTENSION] || [extension caseInsensitiveCompare:GPKG_GEOPACKAGE_EXTENDED_EXTENSION]){
            NSString * databaseName = [[dbFile lastPathComponent] stringByDeletingPathExtension];
            [databases setObject:[databaseDirectory stringByAppendingPathComponent:dbFile] forKey:databaseName];
        }
    }
    
    return databases;
}

-(NSString *) pathForDatabase: (NSString *) database{
    return [[self databasePaths] objectForKey:database];
}

-(BOOL) exists: (NSString *) database{
    return [self pathForDatabase:database] != nil;
}

-(BOOL) delete: (NSString *) database{
    BOOL deleted = false;
    
    NSString * filename = [self pathForDatabase:database];
    if(filename != nil){
        NSFileManager * fileManager = [NSFileManager defaultManager];
        deleted = [fileManager removeItemAtPath:filename error:nil];
    }
    
    return deleted;
}

-(BOOL) create: (NSString *) database{

    BOOL created = false;
    
    if([self exists:database]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", database];
    }
    
    NSString * dbDirectory = [GPKGIOUtils databaseDirectory];
    NSString * databasePath = [dbDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", database, GPKG_GEOPACKAGE_EXTENSION]];
    
    GPKGConnection * connection = [[GPKGConnection alloc] initWithDatabaseFilename:databasePath];
    @try {
        
        // Set the application id as a GeoPackage
        [connection setApplicationId];
        
        // Create the minimum required tables
        GPKGTableCreator * tableCreator = [[GPKGTableCreator alloc] initWithDatabase:connection];
        [tableCreator createRequired];
        
        created = true;
    }
    @finally {
        if(connection != nil){
            [connection close];
        }
    }
    
    return created;
}

-(BOOL) importGeoPackageFromPath: (NSString *) path andDatabase: (NSString *) database{
    
    if([self exists:database]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", database];
    }
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager isReadableFileAtPath:path]){
        NSString * dbDirectory = [GPKGIOUtils databaseDirectory];
        NSError *error = nil;
        NSString * databasePath = [dbDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", database, [path pathExtension]]];
        [fileManager copyItemAtPath:path toPath:databasePath error:&error];
        if(error){
            [NSException raise:@"Import GeoPackage File" format:@"Failed to import GeoPackage '%@' at path '%@' with error: %@", database, path, error];
        }
    }
    
    BOOL imported = [self exists:database];
    return imported;
}

-(BOOL) importGeoPackageFromUrl: (NSURL *) url andDatabase: (NSString *) database{
    
    BOOL imported = false;
    
    if([self exists:database]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", database];
    }
    
    NSData * fileData = [NSData dataWithContentsOfURL:url];
    if(fileData){
        NSString * dbDirectory = [GPKGIOUtils databaseDirectory];
        NSString * databasePath = [dbDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", database, GPKG_GEOPACKAGE_EXTENSION]];
        imported = [fileData writeToFile:databasePath atomically:true];
    }
    
    if(imported){
        imported = [self exists:database];
    }
    
    return imported;
}

-(GPKGGeoPackage *) open: (NSString *) database{

    GPKGGeoPackage *geoPackage = nil;
    
    NSString * path = [self pathForDatabase:database];
    if(path != nil){
    
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:path]){
            [NSException raise:@"No Database File" format:@"Database '%@' does not exist at path: %@", database, path];
        }
        if(![fileManager isReadableFileAtPath:path]){
            [NSException raise:@"Database Not Readable" format:@"Database '%@' is not readable at path: %@", database, path];
        }
        BOOL writable = [fileManager isWritableFileAtPath:path];

        GPKGConnection *db = [[GPKGConnection alloc] initWithDatabaseFilename:path];
        geoPackage = [[GPKGGeoPackage alloc] initWithConnection:db andWritable:writable];
    }
    return geoPackage;
}

@end
