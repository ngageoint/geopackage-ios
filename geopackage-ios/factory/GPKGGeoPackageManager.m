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
#import "GPKGGeoPackageValidate.h"
#import "GPKGSqlUtils.h"
#import "AFHTTPRequestOperation.h"

@implementation GPKGGeoPackageManager

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.metadataDb = [[GPKGMetadataDb alloc] init];
    }
    return self;
}

-(void) close{
    [self.metadataDb close];
}

-(NSArray *) databases{
    
    NSArray * databases = nil;
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    databases = [geoPackageMetadataDao getAllNamesSorted];

    return databases;
}

-(int) count{
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    int count = [geoPackageMetadataDao count];
    return count;
}

-(NSString *) pathForDatabase: (NSString *) database{
    
    NSString * path = nil;
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];

    if(metadata != nil){
        path = metadata.path;
    }
    
    return path;
}

-(NSString *) documentsPathForDatabase: (NSString *) database{
    NSString * path = [self pathForDatabase:database];
    if(path != nil){
        path = [GPKGIOUtils documentsDirectoryWithSubDirectory:path];
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

-(NSString *) requiredDocumentsPathForDatabase: (NSString *) database{
    NSString * path = [self requiredPathForDatabase:database];
    path = [GPKGIOUtils documentsDirectoryWithSubDirectory:path];
    return path;
}

-(BOOL) exists: (NSString *) database{
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    BOOL exists = [geoPackageMetadataDao existsByName:database];
    return exists;
}

-(int) size: (NSString *) database{
    
    NSString * documentsFilename = [self requiredDocumentsPathForDatabase:database];
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
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
    if(metadata != nil){
        
        // Delete the file
        NSString * documentsPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadata.path];
        [GPKGIOUtils deleteFile:documentsPath];
        
        // Delete the metadata record
        deleted = [geoPackageMetadataDao deleteMetadata:metadata];
    }
    
    return deleted;
}

-(BOOL) deleteAll{

    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    NSArray * allMetadata = [geoPackageMetadataDao getAll];
    
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

-(BOOL) importGeoPackageFromPath: (NSString *) path{
    return [self importGeoPackageFromPath:path withName:nil inDirectory:nil andOverride:false];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name{
    return [self importGeoPackageFromPath:path withName:name inDirectory:nil andOverride:false];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path inDirectory: (NSString *) dbDirectory{
    return [self importGeoPackageFromPath:path withName:nil inDirectory:dbDirectory andOverride:false];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path andOverride: (BOOL) override{
    return [self importGeoPackageFromPath:path withName:nil inDirectory:nil andOverride:override];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path andOverride: (BOOL) override andMove: (BOOL) moveFile{
    return [self importGeoPackageFromPath:path withName:nil inDirectory:nil andOverride:override andMove:moveFile];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override{
    return [self importGeoPackageFromPath:path withName:nil inDirectory:dbDirectory andOverride:override];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name andOverride: (BOOL) override{
    return [self importGeoPackageFromPath:path withName:name inDirectory:nil andOverride:override];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory{
    return [self importGeoPackageFromPath:path withName:name inDirectory:dbDirectory andOverride:false];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override{
    return [self importGeoPackageFromPath:path withName:name inDirectory:dbDirectory andOverride:override andMove:false];
}

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override andMove: (BOOL) moveFile{
    
    // Verify the file has the right extension
    [GPKGGeoPackageValidate validateGeoPackageExtension:path];
    
    // Use the provided name or the base file name as the database name
    NSString * database = nil;
    if(name != nil){
        database = name;
    } else{
        database = [[path lastPathComponent] stringByDeletingPathExtension];
    }
    
    BOOL imported = false;
    
    BOOL exists = [self exists:database];
    if(exists){
        if(override){
            [self delete:database];
        }else{
            [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", name];
        }
    }
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager isReadableFileAtPath:path]){
        NSString * databasePath = [self buildDatabasePathWithDbDirectory:dbDirectory andDatabase:database andExtension:[path pathExtension]];
        NSString * documentsDatabasePath = [GPKGIOUtils documentsDirectoryWithSubDirectory:databasePath];
        NSError *error = nil;
        if([fileManager isReadableFileAtPath:documentsDatabasePath]){
            [NSException raise:@"Import GeoPackage File" format:@"Failed to import GeoPackage '%@' at path '%@' to path '%@' because a file already exists with error: %@", database, path, documentsDatabasePath, error];
        }
        if(moveFile){
            imported = [fileManager moveItemAtPath:path toPath:documentsDatabasePath error:&error];
        }else{
            imported = [fileManager copyItemAtPath:path toPath:documentsDatabasePath error:&error];
        }
        if(error || !imported){
            [NSException raise:@"Import GeoPackage File" format:@"Failed to import GeoPackage '%@' at path '%@' with error: %@", database, path, error];
        }
        
        // Validate the imported GeoPackage and create the metadata
        [self validateAndCreateImportGeoPackageWithName:database andPath:databasePath andDocumentsPath:documentsDatabasePath];
    }
    
    return imported && [self exists:database];
}

-(void) importGeoPackageFromUrl: (NSURL *) url{
    NSString * name = [[[url absoluteString] lastPathComponent] stringByDeletingPathExtension];
    [self importGeoPackageFromUrl:url withName:name inDirectory:nil andOverride:false andProgress:nil];
}

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name{
    [self importGeoPackageFromUrl:url withName:name inDirectory:nil andOverride:false andProgress:nil];
}

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory{
    [self importGeoPackageFromUrl:url withName:name inDirectory:dbDirectory andOverride:false andProgress:nil];
}

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name andProgress: (NSObject<GPKGProgress> *) progress{
    [self importGeoPackageFromUrl:url withName:name inDirectory:nil andOverride:false andProgress:progress];
}

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name andOverride: (BOOL) override{
    [self importGeoPackageFromUrl:url withName:name inDirectory:nil andOverride:override andProgress:nil];
}

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andProgress: (NSObject<GPKGProgress> *) progress{
    [self importGeoPackageFromUrl:url withName:name inDirectory:dbDirectory andOverride:false andProgress:progress];
}

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override{
    [self importGeoPackageFromUrl:url withName:name inDirectory:dbDirectory andOverride:override andProgress:nil];
}

-(void) importGeoPackageFromUrl: (NSURL *) url withName: (NSString *) name inDirectory: (NSString *) dbDirectory andOverride: (BOOL) override andProgress: (NSObject<GPKGProgress> *) progress{
    
    if(!override && [self exists:name]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", name];
    }
    
    NSString * databasePath = [self buildDatabasePathWithDbDirectory:dbDirectory andDatabase:name];
    NSString * documentsDatabasePath = [GPKGIOUtils documentsDirectoryWithSubDirectory:databasePath];
    NSOutputStream * outputStream = [NSOutputStream outputStreamToFileAtPath:documentsDatabasePath append:false];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setOutputStream:outputStream];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        if(progress != nil){
            if([progress isActive]){
                [progress setMax:(int)totalBytesExpectedToRead];
                [progress addProgress:(int)bytesRead];
            }else{
                [operation cancel];
            }
        }
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if(progress == nil || [progress isActive]){
            
            @try {
                // Validate the imported GeoPackage and create the metadata
                [self validateAndCreateImportGeoPackageWithName:name andPath:databasePath andDocumentsPath:documentsDatabasePath];
            
                if(progress != nil){
                    [progress completed];
                }
            } @catch (NSException *e) {
                NSLog(@"Download Validation Error for '%@' at url '%@' with error: %@", name, url, [e description]);
                if(progress != nil){
                    [progress failureWithError:[e description]];
                }
            }
        }else{
            [GPKGIOUtils deleteFile:documentsDatabasePath];
            [progress failureWithError:@"Operation was canceled"];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(progress != nil){
            if([progress isActive]){
                [progress failureWithError:[error description]];
            }else{
                [progress failureWithError:@"Operation was canceled"];
            }
        }
        NSLog(@"Download Error for '%@' at url '%@' with error: %@", name, url, [error description]);
    }];
    
    [operation start];
}

-(void) validateAndCreateImportGeoPackageWithName: (NSString *) name andPath: (NSString *) path andDocumentsPath: (NSString *) documentsPath{
    
    // Verify the database is valid
    sqlite3 *sqlite3Database;
    int openDatabaseResult = sqlite3_open([documentsPath UTF8String], &sqlite3Database);
    sqlite3_close(sqlite3Database);
    if(openDatabaseResult != SQLITE_OK){
        // Delete the file
        [GPKGIOUtils deleteFile:documentsPath];
        [NSException raise:@"Invalid GeoPackage database file: %@" format:@"Invalid GeoPackage database file: %@, Error: %s", documentsPath, sqlite3_errmsg(sqlite3Database)];
    }
    
    // Create the metadata record
    [self createMetadataWithName:name andPath:path];
    
    // Open and validate the GeoPackage
    GPKGGeoPackage * geoPackage = [self open:name];
    if(geoPackage != nil){
        @try {
            if(![[geoPackage getSpatialReferenceSystemDao] tableExists] || ! [[geoPackage getContentsDao] tableExists]){
                [NSException raise:@"Invalid GeoPackage" format:@"Invalid GeoPackage database file. Does not contain required tables: %@ & %@, Database: %@", GPKG_SRS_TABLE_NAME, GPKG_CON_TABLE_NAME, name];
            }
        }
        @catch (NSException *e) {
            [self delete:name];
            @throw e;
        }
        @finally {
            [geoPackage close];
        }
    }else{
        [GPKGIOUtils deleteFile:documentsPath];
        [NSException raise:@"Failed to Open" format:@"Unable to open GeoPackage database. Database: %@", name];
    }
}

-(void) exportGeoPackage: (NSString *) database toDirectory: (NSString *) directory{
    [self exportGeoPackage:database withName:database toDirectory:directory];
}

-(void) exportGeoPackage: (NSString *) database withName: (NSString *) name toDirectory: (NSString *) directory{
    
    NSString * file = [directory stringByAppendingPathComponent:name];
    
    // Add the extension if not on the name
    if(![GPKGGeoPackageValidate hasGeoPackageExtension:file]){
        file = [file stringByAppendingPathExtension:GPKG_GEOPACKAGE_EXTENSION];
    }
    
    // Copy the geopackage database to the new file location
    NSString * documentsDbFile = [self requiredDocumentsPathForDatabase:database];
    [GPKGIOUtils copyFile:documentsDbFile toFile:file];
}

-(GPKGGeoPackage *) open: (NSString *) database{
    
    GPKGGeoPackage * geoPackage = nil;
    
    if([self exists:database]){
        NSString * documentsPath = [self requiredDocumentsPathForDatabase:database];
    
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        if(![fileManager fileExistsAtPath:documentsPath]){
            [NSException raise:@"No Database File" format:@"Database '%@' does not exist at path: %@", database, documentsPath];
        }
        if(![fileManager isReadableFileAtPath:documentsPath]){
            [NSException raise:@"Database Not Readable" format:@"Database '%@' is not readable at path: %@", database, documentsPath];
        }
        BOOL writable = [fileManager isWritableFileAtPath:documentsPath];

        GPKGConnection *db = [[GPKGConnection alloc] initWithDatabaseFilename:documentsPath];
        geoPackage = [[GPKGGeoPackage alloc] initWithConnection:db andWritable:writable andMetadataDb:self.metadataDb];
    }

    return geoPackage;
}

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy{
    return [self copy:database to:databaseCopy andSameDirectory:true];
}

-(BOOL) copy: (NSString *) database to: (NSString *) databaseCopy andSameDirectory: (BOOL) sameDirectory{
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
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
    
    return copied && [self exists:databaseCopy];
}

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase{
    return [self rename:database to:newDatabase andRenameFile:true];
}

-(BOOL) rename: (NSString *) database to: (NSString *) newDatabase andRenameFile: (BOOL) renameFile{
    
    BOOL renamed = false;
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
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
    
    return renamed && [self exists:newDatabase];
}

-(BOOL) move: (NSString *) database toDirectory: (NSString *) dbDirectory{
    
    BOOL moved = false;
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
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
    
    return moved && [self exists:database];
}

-(void) createMetadataWithDao: (GPKGGeoPackageMetadataDao *) dao andName: (NSString *) name andPath: (NSString *) path{
    GPKGGeoPackageMetadata * metadata = [[GPKGGeoPackageMetadata alloc] init];
    [metadata setName:name];
    [metadata setPath:path];
    [dao create:metadata];
}

-(void) createMetadataWithName: (NSString *) name andPath: (NSString *) path{
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    [self createMetadataWithDao:geoPackageMetadataDao andName:name andPath:path];
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
