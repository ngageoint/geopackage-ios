//
//  GPKGGeoPackageMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGConnection.h"
#import "GPKGGeoPackageMetadata.h"

@interface GPKGGeoPackageMetadataDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(BOOL) deleteMetadata: (GPKGGeoPackageMetadata *) metadata;

-(BOOL) deleteByName: (NSString *) name;

-(BOOL) renameMetadata: (GPKGGeoPackageMetadata *) metadata toNewName: (NSString *) newName;

-(BOOL) renameName: (NSString *) name toNewName: (NSString *) newName;

-(NSArray *) getAll;

-(NSArray *) getAllNames;

-(NSArray *) getAllNamesSorted;

-(GPKGGeoPackageMetadata *) getMetadataByName: (NSString *) name;

-(GPKGGeoPackageMetadata *) getMetadataById: (NSNumber *) id;

-(GPKGGeoPackageMetadata *) getOrCreateMetadataByName: (NSString *) name;

-(BOOL) existsByName: (NSString *) name;

@end
