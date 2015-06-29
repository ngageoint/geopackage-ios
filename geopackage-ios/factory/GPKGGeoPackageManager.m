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
#import "GPKGMetadataDb.h"

@implementation GPKGGeoPackageManager

-(NSArray *) databases{
    
    NSMutableArray * databases = [[NSMutableArray alloc] init];
    
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        NSArray * allMetadata = [geoPackageMetadataDao getAll];
        for(GPKGGeoPackageMetadata * metadata in allMetadata){
            [databases addObject:metadata.name];
        }
    }@finally{
        [metadataDb close];
    }

    return databases;
}

-(int) count{
    int count = 0;
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        count = [geoPackageMetadataDao count];
    }@finally{
        [metadataDb close];
    }
    return count;
}

-(NSString *) pathForDatabase: (NSString *) database{
    
    NSString * path = nil;
    
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
    
        if(metadata != nil){
            path = metadata.path;
        }
    }@finally{
        [metadataDb close];
    }
    
    return path;
}

-(NSString *) requiredPathForDatabase: (NSString *) database{
    NSString * path = [self pathForDatabase:database];
    if(path == nil){
        [NSException raise:@"No Database" format:@"Database does not exist: %@", database];
    }
    return path;
}

-(BOOL) exists: (NSString *) database{
    BOOL exists = false;
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        exists = [geoPackageMetadataDao existsByName:database];
    }@finally{
        [metadataDb close];
    }
    return exists;
}

-(int) size: (NSString *) database{
    
    NSString * filename = [self requiredPathForDatabase:database];
    NSString * documentsFilename = [GPKGIOUtils documentsDirectoryWithSubDirectory:filename];
    NSError *error = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:documentsFilename error:&error];
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
    
    // Get the metadata record
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
        if(metadata != nil){
            
            // Delete the file
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSError *error = nil;
            NSString * documentsPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadata.path];
            BOOL fileDeleted = [fileManager removeItemAtPath:documentsPath error:&error];
            if(error || !fileDeleted){
                NSLog(@"Failed to delete GeoPackage '%@' at path '%@' with error: %@", database, documentsPath, error);
            }
            
            // Delete the metadata record
            deleted = [geoPackageMetadataDao deleteMetadata:metadata];
        }
    }@finally{
        [metadataDb close];
    }
    
    return deleted;
}

-(BOOL) deleteAll{
    NSArray * allMetadata = nil;
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        allMetadata = [geoPackageMetadataDao getAll];
    }@finally{
        [metadataDb close];
    }
    
    if(allMetadata != nil){
        for(GPKGGeoPackageMetadata * metadata in allMetadata){
            [self delete:metadata.name];
        }
    }
    
    BOOL deleted = false;
    if([self count] == 0){
        deleted = [GPKGMetadataDb deleteMetadataFile];
        
        // Delete the GeoPackage database directory in case any orphan database files are left
        NSError *error = nil;
        NSString * documentsDatabaseDirectory = [GPKGIOUtils documentsDirectoryWithSubDirectory:[GPKGIOUtils databaseDirectory]];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        BOOL directoryDeleted = [fileManager removeItemAtPath:documentsDatabaseDirectory error:&error];
        if(error || !directoryDeleted){
            NSLog(@"Failed to delete GeoPackage db directory at path '%@' with error: %@", documentsDatabaseDirectory, error);
        }
    }
    
    return deleted;
}

-(BOOL) create: (NSString *) database{
    return [self create:database inDirectory:nil];
}

-(BOOL) create: (NSString *) database inDirectory: (NSString *) dbDirectory{

    BOOL created = false;
    
    if([self exists:database]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", database];
    }
    
    NSString * databasePath = [self buildDatabasePathWithDbDirectory:dbDirectory andDatabase:database];
    NSString * documentsDatabasePath = [GPKGIOUtils documentsDirectoryWithSubDirectory:databasePath];
    
    GPKGConnection * connection = [[GPKGConnection alloc] initWithDatabaseFilename:documentsDatabasePath];
    @try {
        
        // Set the application id as a GeoPackage
        [connection setApplicationId];
        
        // Create the minimum required tables
        GPKGGeoPackageTableCreator * tableCreator = [[GPKGGeoPackageTableCreator alloc] initWithDatabase:connection];
        [tableCreator createRequired];
        
        // Create the metadata record
        [self createMetadataWithName:database andPath:databasePath];
        
        created = true;
    }
    @catch (NSException *e) {
        NSFileManager * fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:documentsDatabasePath error:nil];
        @throw e;
    }
    @finally {
        if(connection != nil){
            [connection close];
        }
    }
    
    return created;
}

-(BOOL) importGeoPackageFromPath: (NSString *) path andDatabase: (NSString *) database{
    return [self importGeoPackageFromPath:path andDatabase:database inDirectory:nil];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path andDatabase: (NSString *) database inDirectory: (NSString *) dbDirectory{
    
    BOOL imported = false;
    
    if([self exists:database]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", database];
    }
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager isReadableFileAtPath:path]){
        NSString * databasePath = [self buildDatabasePathWithDbDirectory:dbDirectory andDatabase:database andExtension:[path pathExtension]];
        NSString * documentsDatabasePath = [GPKGIOUtils documentsDirectoryWithSubDirectory:databasePath];
        NSError *error = nil;
        if([fileManager isReadableFileAtPath:documentsDatabasePath]){
            [NSException raise:@"Import GeoPackage File" format:@"Failed to import GeoPackage '%@' at path '%@' to path '%@' because a file already exists with error: %@", database, path, documentsDatabasePath, error];
        }
        imported = [fileManager copyItemAtPath:path toPath:documentsDatabasePath error:&error];
        if(error || !imported){
            [NSException raise:@"Import GeoPackage File" format:@"Failed to import GeoPackage '%@' at path '%@' with error: %@", database, path, error];
        }
        
        // Create the metadata record
        [self createMetadataWithName:database andPath:databasePath];
    }
    
    return imported && [self exists:database];
}

-(BOOL) importGeoPackageFromUrl: (NSURL *) url andDatabase: (NSString *) database{
    return [self importGeoPackageFromUrl:url andDatabase:database inDirectory:nil];
}

-(BOOL) importGeoPackageFromUrl: (NSURL *) url andDatabase: (NSString *) database inDirectory: (NSString *) dbDirectory{
    
    BOOL imported = false;
    
    if([self exists:database]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", database];
    }
    
    NSData * fileData = [NSData dataWithContentsOfURL:url];
    if(fileData){
        NSString * databasePath = [self buildDatabasePathWithDbDirectory:dbDirectory andDatabase:database];
        NSString * documentsDatabasePath = [GPKGIOUtils documentsDirectoryWithSubDirectory:databasePath];
        imported = [fileData writeToFile:documentsDatabasePath atomically:true];
        if(!imported){
            [NSException raise:@"Import GeoPackage File" format:@"Failed to import GeoPackage '%@' at url '%@'", database, url];
        }
        
        // Create the metadata record
        [self createMetadataWithName:database andPath:databasePath];
    }
    
    return imported && [self exists:database];
}

-(GPKGGeoPackage *) open: (NSString *) database{
    
    NSString * path = [self requiredPathForDatabase:database];
    NSString * documentsPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:path];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
        
    if(![fileManager fileExistsAtPath:documentsPath]){
        [NSException raise:@"No Database File" format:@"Database '%@' does not exist at path: %@", database, documentsPath];
    }
    if(![fileManager isReadableFileAtPath:documentsPath]){
        [NSException raise:@"Database Not Readable" format:@"Database '%@' is not readable at path: %@", database, documentsPath];
    }
    BOOL writable = [fileManager isWritableFileAtPath:documentsPath];

    GPKGConnection *db = [[GPKGConnection alloc] initWithDatabaseFilename:documentsPath];
    GPKGGeoPackage * geoPackage = [[GPKGGeoPackage alloc] initWithConnection:db andWritable:writable];

    return geoPackage;
}

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy{
    return [self copy:database to:databaseCopy andSameDirectory:true];
}

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy andSameDirectory: (BOOL) sameDirectory{
    
    BOOL copied = false;
    
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
        if(metadata == nil){
            [NSException raise:@"No Database" format:@"Database does not exist: %@", database];
        }
        
        NSString * copyPath = nil;
        if(sameDirectory){
            copyPath = [self buildNewPathWithPath:metadata.path andNewName:databaseCopy];
        }else{
            copyPath = [self buildDatabasePathWithDatabase:databaseCopy andExtension:[metadata.path pathExtension]];
        }
        NSString * documentsCopyPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:copyPath];
    
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString * documentsPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadata.path];
        BOOL copied = [fileManager copyItemAtPath:documentsPath toPath:documentsCopyPath error:&error];
        if(error || !copied){
            [NSException raise:@"Copy GeoPackage" format:@"Failed to copy GeoPackage '%@' at path '%@' to GeoPackage '%@' at path '%@' with error: %@", database, documentsPath, databaseCopy, documentsCopyPath, error];
        }
        
        if(copied){
            [self createMetadataWithDao:geoPackageMetadataDao andName:databaseCopy andPath:copyPath];
            copied = true;
        }
        
    }@finally{
        [metadataDb close];
    }
    
    return copied && [self exists:databaseCopy];
}

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase{
    return [self rename:database to:newDatabase andRenameFile:true];
}

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase andRenameFile: (BOOL) renameFile{
    
    BOOL renamed = false;
    
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
        if(metadata == nil){
            [NSException raise:@"No Database" format:@"Database does not exist: %@", database];
        }
        
        BOOL success = true;
        
        NSString * renamePath = metadata.path;
        if(renameFile){
            renamePath = [self buildNewPathWithPath:renamePath andNewName:newDatabase];
            NSString * documentsRenamePath = [GPKGIOUtils documentsDirectoryWithSubDirectory:renamePath];

            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSError *error = nil;
            NSString * documentsPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadata.path];
            success = [fileManager moveItemAtPath:documentsPath toPath:documentsRenamePath error:&error];
            if(error || !success){
                [NSException raise:@"Rename GeoPackage" format:@"Failed to rename GeoPackage '%@' at path '%@' to GeoPackage '%@' at path '%@' with error: %@", database, documentsPath, newDatabase, documentsRenamePath, error];
            }
        }
        
        if(success){
            [metadata setName:newDatabase];
            [metadata setPath:renamePath];
            renamed = [geoPackageMetadataDao update:metadata] > 0;
        }
    }@finally{
        [metadataDb close];
    }
    
    return renamed && [self exists:newDatabase];
}

-(BOOL) move: (NSString *) database toDirectory: (NSString *) dbDirectory{
    
    BOOL moved = false;
    
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
        if(metadata == nil){
            [NSException raise:@"No Database" format:@"Database does not exist: %@", database];
        }
        
        NSString * movePath = [dbDirectory stringByAppendingPathComponent:[metadata.path lastPathComponent]];
        NSString * documentsMovePath = [GPKGIOUtils documentsDirectoryWithSubDirectory:movePath];
            
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        NSString * documentsPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadata.path];
        BOOL success = [fileManager moveItemAtPath:documentsPath toPath:movePath error:&error];
        if(error || !success){
            [NSException raise:@"Move GeoPackage" format:@"Failed to move GeoPackage '%@' at path '%@' to path '%@' with error: %@", database, documentsPath, documentsMovePath, error];
        }
        
        if(success){
            [metadata setPath:movePath];
            moved = [geoPackageMetadataDao update:metadata] > 0;
        }
    }@finally{
        [metadataDb close];
    }
    
    return moved && [self exists:database];
}

-(void) createMetadataWithDao: (GPKGGeoPackageMetadataDao *) dao andName: (NSString *) name andPath: (NSString *) path{
    GPKGGeoPackageMetadata * metadata = [[GPKGGeoPackageMetadata alloc] init];
    [metadata setName:name];
    [metadata setPath:path];
    [dao create:metadata];
}

-(void) createMetadataWithName: (NSString *) name andPath: (NSString *) path{
    GPKGMetadataDb * metadataDb = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [metadataDb getGeoPackageMetadataDao];
        [self createMetadataWithDao:geoPackageMetadataDao andName:name andPath:path];
    }@finally{
        [metadataDb close];
    }
}

-(NSString *) buildDatabasePathWithDatabase: (NSString *) database{
    return [self buildDatabasePathWithDatabase:database andExtension:GPKG_GEOPACKAGE_EXTENSION];
}

-(NSString *) buildDatabasePathWithDatabase: (NSString *) database andExtension: (NSString *) extension{
    return [self buildDatabasePathWithDbDirectory:nil andDatabase:database andExtension:extension];
}

-(NSString *) buildDatabasePathWithDbDirectory: (NSString *) dbDirectory andDatabase: (NSString *) database{
    return [self buildDatabasePathWithDbDirectory:dbDirectory andDatabase:database andExtension:GPKG_GEOPACKAGE_EXTENSION];
}

-(NSString *) buildDatabasePathWithDbDirectory: (NSString *) dbDirectory andDatabase: (NSString *) database andExtension: (NSString *) extension{
    if(dbDirectory == nil){
        dbDirectory = [GPKGIOUtils databaseDirectory];
    }
    NSString * databasePath = [dbDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", database, extension]];
    return databasePath;
}

-(NSString *) buildNewPathWithPath: (NSString *) path andNewName: (NSString *) newName{
    NSString * dbDirectory = [path stringByDeletingLastPathComponent];
    NSString * extension = [path pathExtension];
    return [self buildDatabasePathWithDbDirectory:dbDirectory andDatabase:newName andExtension:extension];
}

@end
