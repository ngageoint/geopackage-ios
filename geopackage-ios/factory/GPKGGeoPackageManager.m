//
//  GPKGGeoPackageManager.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageManager.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGGeoPackageTableCreator.h"
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

-(int) count{
    return (int)[[self databases] count];
}

-(NSString *) pathForDatabase: (NSString *) database{
    return [[self databasePaths] objectForKey:database];
}

-(NSString *) requiredPathForDatabase: (NSString *) database{
    NSString * path = [self pathForDatabase:database];
    if(path == nil){
        [NSException raise:@"No Database" format:@"Database does not exist: %@", database];
    }
    return path;
}

-(BOOL) exists: (NSString *) database{
    return [self pathForDatabase:database] != nil;
}

-(int) size: (NSString *) database{
    
    NSString * filename = [self requiredPathForDatabase:database];
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filename error:&error];
    if(error){
        [NSException raise:@"Database Size" format:@"Failed to get the size of database '%@' with error: %@", database, error];
    }
    NSNumber * size = [fileAttributes objectForKey:NSFileSize];
    
    return [size intValue];
}

-(NSString *) readableSize: (NSString *) database{
    int size = [self size:database];
    return [GPKGIOUtils formatBytes:size];
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
    
    NSString * databasePath = [self buildDatabasePathWithDatabase:database];
    
    GPKGConnection * connection = [[GPKGConnection alloc] initWithDatabaseFilename:databasePath];
    @try {
        
        // Set the application id as a GeoPackage
        [connection setApplicationId];
        
        // Create the minimum required tables
        GPKGGeoPackageTableCreator * tableCreator = [[GPKGGeoPackageTableCreator alloc] initWithDatabase:connection];
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
        NSString * databasePath = [self buildDatabasePathWithDatabase:database andExtension:[path pathExtension]];
        NSError *error = nil;
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
        NSString * databasePath = [self buildDatabasePathWithDatabase:database];
        imported = [fileData writeToFile:databasePath atomically:true];
    }
    
    return imported && [self exists:database];
}

-(GPKGGeoPackage *) open: (NSString *) database{
    
    NSString * path = [self requiredPathForDatabase:database];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
        
    if(![fileManager fileExistsAtPath:path]){
        [NSException raise:@"No Database File" format:@"Database '%@' does not exist at path: %@", database, path];
    }
    if(![fileManager isReadableFileAtPath:path]){
        [NSException raise:@"Database Not Readable" format:@"Database '%@' is not readable at path: %@", database, path];
    }
    BOOL writable = [fileManager isWritableFileAtPath:path];

    GPKGConnection *db = [[GPKGConnection alloc] initWithDatabaseFilename:path];
    GPKGGeoPackage * geoPackage = [[GPKGGeoPackage alloc] initWithConnection:db andWritable:writable];

    return geoPackage;
}

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy{
    
    NSString * path = [self requiredPathForDatabase:database];
    NSString * copyPath = [self buildDatabasePathWithDatabase:databaseCopy];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL copied = [fileManager copyItemAtPath:path toPath:copyPath error:&error];
    if(error){
        [NSException raise:@"Copy GeoPackage" format:@"Failed to copy GeoPackage '%@' at path '%@' to GeoPackage '%@' at path '%@' with error: %@", database, path, databaseCopy, copyPath, error];
    }
    
    return copied && [self exists:databaseCopy];
}

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase{
    
    NSString * path = [self requiredPathForDatabase:database];
    NSString * newPath = [self buildDatabasePathWithDatabase:newDatabase];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    BOOL renamed = [fileManager moveItemAtPath:path toPath:newPath error:&error];
    if(error){
        [NSException raise:@"Rename GeoPackage" format:@"Failed to rename GeoPackage '%@' at path '%@' to GeoPackage '%@' at path '%@' with error: %@", database, path, newDatabase, newPath, error];
    }
    
    return renamed && [self exists:newDatabase];
}

-(NSString *) buildDatabasePathWithDatabase: (NSString *) database{
    return [self buildDatabasePathWithDatabase:database andExtension:GPKG_GEOPACKAGE_EXTENSION];
}

-(NSString *) buildDatabasePathWithDatabase: (NSString *) database andExtension: (NSString *) extension{
    NSString * dbDirectory = [GPKGIOUtils databaseDirectory];
    NSString * databasePath = [dbDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", database, extension]];
    return databasePath;
}

@end
