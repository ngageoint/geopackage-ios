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
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "WKBByteReader.h"
#import "AFURLSessionManager.h"

@implementation GPKGGeoPackageManager

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.metadataDb = [[GPKGMetadataDb alloc] init];
        
        self.importHeaderValidation = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_MANAGER_VALIDATION andProperty:GPKG_PROP_MANAGER_VALIDATION_IMPORT_HEADER];
        self.importIntegrityValidation = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_MANAGER_VALIDATION andProperty:GPKG_PROP_MANAGER_VALIDATION_IMPORT_INTEGRITY];
        self.openHeaderValidation = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_MANAGER_VALIDATION andProperty:GPKG_PROP_MANAGER_VALIDATION_OPEN_HEADER];
        self.openIntegrityValidation = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_MANAGER_VALIDATION andProperty:GPKG_PROP_MANAGER_VALIDATION_OPEN_INTEGRITY];
    }
    return self;
}

-(void) close{
    [self.metadataDb close];
}

-(NSArray *) databases{
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    NSArray * databases = [geoPackageMetadataDao getAllNamesSorted];

    databases = [self deleteMissingDatabases:databases];
    
    return databases;
}

-(NSArray *) databasesLike: (NSString *) like{
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    NSArray * databases = [geoPackageMetadataDao getMetadataWhereNameLike:like sortedBy:GPKG_GPM_COLUMN_NAME];
    
    databases = [self deleteMissingDatabases:databases];
    
    return databases;
}

-(NSArray *) databasesNotLike: (NSString *) notLike{
    
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    NSArray * databases = [geoPackageMetadataDao getMetadataWhereNameNotLike:notLike sortedBy:GPKG_GPM_COLUMN_NAME];
    
    databases = [self deleteMissingDatabases:databases];
    
    return databases;
}

-(NSArray *) deleteMissingDatabases: (NSArray *) databases{
    
    NSMutableArray * filesExist = [[NSMutableArray alloc] init];
    for(NSString * database in databases){
        if([self exists:database]){
            [filesExist addObject:database];
        }
    }
    return filesExist;
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
    BOOL exists = NO;
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
    if(metadata != nil){
        NSString * documentsPath = [self requiredDocumentsPathForDatabase:database];
        NSFileManager * fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:documentsPath]){
            exists = YES;
        }else{
            [self delete:database];
        }
    }
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
    return [self delete:database andFile:YES];
}

-(BOOL) delete: (NSString *) database andFile: (BOOL) deleteFile{
    BOOL deleted = false;
    
    // Get the metadata record
    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    GPKGGeoPackageMetadata * metadata = [geoPackageMetadataDao getMetadataByName:database];
    if(metadata != nil){
        
        // Delete the file
        if(deleteFile){
            NSString * documentsPath = [GPKGIOUtils documentsDirectoryWithSubDirectory:metadata.path];
            [GPKGIOUtils deleteFile:documentsPath];
        }
        
        // Delete the metadata record
        deleted = [geoPackageMetadataDao deleteMetadata:metadata];
    }
    
    return deleted;
}

-(BOOL) deleteAll{
    return [self deleteAllAndFiles:YES];
}

-(BOOL) deleteAllAndFiles: (BOOL) deleteFiles{

    GPKGGeoPackageMetadataDao * geoPackageMetadataDao = [self.metadataDb getGeoPackageMetadataDao];
    NSArray * allMetadata = [geoPackageMetadataDao getAll];
    
    if(allMetadata != nil){
        for(GPKGGeoPackageMetadata * metadata in allMetadata){
            [self delete:metadata.name andFile:deleteFiles];
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
        
        // Set the GeoPackage application id and user version
        [connection setApplicationId];
        [connection setUserVersion];
        
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

-(BOOL) importGeoPackageFromPath: (NSString *) path withName: (NSString *) name andOverride: (BOOL) override andMove: (BOOL) moveFile{
    return [self importGeoPackageFromPath:path withName:name inDirectory:nil andOverride:override andMove:moveFile];
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
        [self validateAndCreateImportGeoPackageWithName:database andPath:databasePath andDocumentsPath:documentsDatabasePath andDeleteOnError:YES];
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
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [NSURL fileURLWithPath :documentsDatabasePath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        
        if(error || (progress != nil && ![progress isActive])){
            [GPKGIOUtils deleteFile:documentsDatabasePath];
            if(progress != nil){
                NSString * errorString = nil;
                if(error == nil || ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCancelled)){
                    errorString = @"Operation was canceled";
                }else{
                    errorString = [error description];
                }
                [progress failureWithError:errorString];
            }
        } else{
            
            @try {
                // Validate the imported GeoPackage and create the metadata
                [self validateAndCreateImportGeoPackageWithName:name andPath:databasePath andDocumentsPath:documentsDatabasePath andDeleteOnError:YES];
                
                if(progress != nil){
                    [progress completed];
                }
            } @catch (NSException *e) {
                NSLog(@"Download Validation Error for '%@' at url '%@' with error: %@", name, url, [e description]);
                if(progress != nil){
                    [progress failureWithError:[e description]];
                }
            }
        }
    }];
    
    [manager setDownloadTaskDidWriteDataBlock:^(NSURLSession *session, NSURLSessionDownloadTask *downloadTask, int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        if(progress != nil){
            if([progress isActive]){
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [progress setMax:(int)totalBytesExpectedToWrite];
                    [progress addProgress:(int)bytesWritten];
                });
            }else{
                [downloadTask cancel];
            }
        }
    }];
    
    [downloadTask resume];

}

-(void) validateAndCreateImportGeoPackageWithName: (NSString *) name andPath: (NSString *) path andDocumentsPath: (NSString *) documentsPath andDeleteOnError: (BOOL) deleteOnError{
    
    // Verify the database is valid
    sqlite3 *sqlite3Database;
    @try {
        int openDatabaseResult = sqlite3_open([documentsPath UTF8String], &sqlite3Database);
        if(openDatabaseResult != SQLITE_OK){
            [NSException raise:@"Invalid GeoPackage database file" format:@"Invalid GeoPackage database file: %@, Error: %s", documentsPath, sqlite3_errmsg(sqlite3Database)];
        }
        [self validateDatabase:sqlite3Database andDatabaseFile:documentsPath andValidateHeader:self.importHeaderValidation andValidateIntegrity:self.importIntegrityValidation];
        sqlite3_close(sqlite3Database);
    }
    @catch (NSException *e) {
        sqlite3_close(sqlite3Database);
        // Delete the file
        if(deleteOnError){
            [GPKGIOUtils deleteFile:documentsPath];
        }
        @throw e;
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
        if(deleteOnError){
            [GPKGIOUtils deleteFile:documentsPath];
        }
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

        // Validate the database if validation is enabled
        [self validateDatabaseFile:documentsPath andValidateHeader:self.openHeaderValidation andValidateIntegrity:self.openIntegrityValidation];
        
        GPKGConnection *db = [[GPKGConnection alloc] initWithDatabaseFilename:documentsPath];
        geoPackage = [[GPKGGeoPackage alloc] initWithConnection:db andWritable:writable andMetadataDb:self.metadataDb];
    }

    return geoPackage;
}

-(BOOL) validate: (NSString *) database{
    BOOL valid = [self isValidWithDatabase:database andValidateHeader:true andValidateIntegrity:true];
    return valid;
}

-(BOOL) validateHeader: (NSString *) database{
    BOOL valid = [self isValidWithDatabase:database andValidateHeader:true andValidateIntegrity:false];
    return valid;
}

-(BOOL) validateIntegrity: (NSString *) database{
    BOOL valid = [self isValidWithDatabase:database andValidateHeader:false andValidateIntegrity:true];
    return valid;
}

/**
 *  Validate the GeoPackage database
 *
 *  @param database          database name
 *  @param validateHeader    true to validate header
 *  @param validateIntegrity true to validate integrity
 *
 *  @return true if valid
 */
-(BOOL) isValidWithDatabase: (NSString *) database andValidateHeader: (BOOL) validateHeader andValidateIntegrity: (BOOL) validateIntegrity{
    
    BOOL valid = false;
    
    if([self exists:database]){
        NSString * documentsPath = [self requiredDocumentsPathForDatabase:database];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        @try {
            valid = [fileManager fileExistsAtPath:documentsPath]
                && [fileManager isReadableFileAtPath:documentsPath]
                && [self isDatabaseFileValid:documentsPath andValidateHeader:validateHeader andValidateIntegrity:validateIntegrity];
        }
        @catch (NSException *e) {
            NSLog(@"Failed to validate database '%@', file '%@' with error: %@", database, documentsPath, [e description]);
        }
    }
    
    return valid;
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

-(BOOL) importGeoPackageAsLinkToPath: (NSString *) path withName: (NSString *) name{
    
    if([self exists:name]){
        [NSException raise:@"Database Exists" format:@"GeoPackage already exists: %@", name];
    }
    
    // Verify the file has the right extension
    [GPKGGeoPackageValidate validateGeoPackageExtension:path];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager isReadableFileAtPath:path]){
        // Validate the imported GeoPackage and create the metadata
        NSString * subPath = [GPKGIOUtils localDocumentsDirectoryPath:path];
        [self validateAndCreateImportGeoPackageWithName:name andPath:subPath andDocumentsPath:path andDeleteOnError:NO];
    }
    
    return [self exists:name];
}

/**
 *  Validate the database file
 *
 *  @param databaseFile      database file
 *  @param validateHeader    true to validate database header
 *  @param validateIntegrity true to validate integrity
 */
-(void) validateDatabaseFile: (NSString *) databaseFile andValidateHeader: (BOOL) validateHeader andValidateIntegrity: (BOOL) validateIntegrity{
    sqlite3 *sqlite3Database;
    int openDatabaseResult = sqlite3_open([databaseFile UTF8String], &sqlite3Database);
    @try {
        if(openDatabaseResult != SQLITE_OK){
            [NSException raise:@"Invalid GeoPackage database file" format:@"Invalid GeoPackage database file: %@, Error: %s", databaseFile, sqlite3_errmsg(sqlite3Database)];
        }
        [self validateDatabase:sqlite3Database andDatabaseFile:databaseFile andValidateHeader:validateHeader andValidateIntegrity:validateIntegrity];
    }
    @finally {
        sqlite3_close(sqlite3Database);
    }

}

/**
 *  Check if the database file is valid
 *
 *  @param databaseFile      database file
 *  @param validateHeader    true to validate database header
 *  @param validateIntegrity true to validate integrity
 *  @return true if valid
 */
-(BOOL) isDatabaseFileValid: (NSString *) databaseFile andValidateHeader: (BOOL) validateHeader andValidateIntegrity: (BOOL) validateIntegrity{
    BOOL valid = false;
    sqlite3 *sqlite3Database;
    int openDatabaseResult = sqlite3_open([databaseFile UTF8String], &sqlite3Database);
    @try {
        valid = openDatabaseResult == SQLITE_OK
            && [self isDatabaseValid:sqlite3Database andDatabaseFile:databaseFile andValidateHeader:validateHeader andValidateIntegrity:validateIntegrity];
    }
    @finally {
        sqlite3_close(sqlite3Database);
    }
    return valid;
}

/**
 *  Validate the database connection
 *
 *  @param sqlite3Database   database connection
 *  @param databaseFile      database file
 *  @param validateHeader    true to validate database header
 *  @param validateIntegrity true to validate integrity
 */
-(void) validateDatabase: (sqlite3 *) sqlite3Database andDatabaseFile: (NSString *) databaseFile andValidateHeader: (BOOL) validateHeader andValidateIntegrity: (BOOL) validateIntegrity{
    
    if(validateHeader){
        [self validateDatabaseHeader:sqlite3Database andDatabaseFile:databaseFile];
    }
    if(validateIntegrity){
        [self validateDatabaseIntegrity:sqlite3Database andDatabaseFile:databaseFile];
    }
    
}

/**
 *  Check if the database connection is valid
 *
 *  @param sqlite3Database   database connection
 *  @param databaseFile      database file
 *  @param validateHeader    true to validate database header
 *  @param validateIntegrity true to validate integrity
 *  @return true if valid
 */
-(BOOL) isDatabaseValid: (sqlite3 *) sqlite3Database andDatabaseFile: (NSString *) databaseFile andValidateHeader: (BOOL) validateHeader andValidateIntegrity: (BOOL) validateIntegrity{
    BOOL valid = (!validateHeader || [self isDatabaseHeaderValid:databaseFile])
        && (!validateIntegrity || [self isDatabaseIntegrityValid:sqlite3Database]);
    return valid;
}

/**
 *  Validate the database header
 *
 *  @param sqlite3Database database connection
 *  @param databaseFile    database file
 */
-(void) validateDatabaseHeader: (sqlite3 *) sqlite3Database andDatabaseFile: (NSString *) databaseFile{

    BOOL validHeader = [self isDatabaseHeaderValid:databaseFile];
    if(!validHeader){
        [NSException raise:@"GeoPackage SQLite Header" format:@"GeoPackage SQLite header is not valid: %@", databaseFile];
    }
}

/**
 *  Check if the database header is valid
 *
 *  @param databaseFile    database file
 *
 *  @return true if valid
 */
-(BOOL) isDatabaseHeaderValid: (NSString *) databaseFile{
    
    BOOL validHeader = false;
    NSInputStream * is = nil;
    @try {
        is = [NSInputStream inputStreamWithFileAtPath:databaseFile];
        [is open];
        NSInteger bufferSize = 16;
        uint8_t buffer[bufferSize];
        if([is read:buffer maxLength:bufferSize] == bufferSize){
            NSData * data = [[NSData alloc] initWithBytes:buffer length:bufferSize];
            WKBByteReader * byteReader = [[WKBByteReader alloc] initWithData:data];
            NSString * header = [byteReader readString:(int)bufferSize];
            NSString * headerPrefix = [header substringToIndex:[GPKG_SQLITE_HEADER_PREFIX length]];
            validHeader = [headerPrefix caseInsensitiveCompare:GPKG_SQLITE_HEADER_PREFIX] == NSOrderedSame;
        }
    }
    @catch (NSException *e) {
        NSLog(@"Failed to retrieve database header from file '%@' with error: %@", databaseFile, [e description]);
    }
    @finally {
        if(is != nil){
            [is close];
        }
    }
    
    return validHeader;
}

/**
 *  Validate the database integrity
 *
 *  @param sqlite3Database database connection
 *  @param databaseFile    database file
 */
-(void) validateDatabaseIntegrity: (sqlite3 *) sqlite3Database andDatabaseFile: (NSString *) databaseFile{
    
    BOOL validHeader = [self isDatabaseIntegrityValid:sqlite3Database];
    if(!validHeader){
        [NSException raise:@"GeoPackage SQLite Integrity" format:@"GeoPackage SQLite file integrity failed: %@", databaseFile];
    }
}

/**
 *  Check if the database integrity is valid
 *
 *  @param sqlite3Database database connection
 *
 *  @return true if valid
 */
-(BOOL) isDatabaseIntegrityValid: (sqlite3 *) sqlite3Database{
    
    BOOL validIntegrity = false;
    
    sqlite3_stmt *integrity = NULL;
    
    if ( sqlite3_prepare_v2( sqlite3Database, "PRAGMA integrity_check;", -1, &integrity, NULL ) == SQLITE_OK ) {
        
        while ( sqlite3_step( integrity ) == SQLITE_ROW ) {
            const unsigned char *result = sqlite3_column_text( integrity, 0 );
            if ( result && strcmp( ( const char * )result, (const char *)"ok" ) == 0 ) {
                validIntegrity = true;
                break;
            }
        }
        
        sqlite3_finalize( integrity );
    }
    
    return validIntegrity;
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
