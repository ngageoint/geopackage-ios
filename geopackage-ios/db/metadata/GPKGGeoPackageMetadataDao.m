//
//  GPKGGeoPackageMetadataDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageMetadataDao.h"
#import "GPKGTableMetadataDao.h"

@implementation GPKGGeoPackageMetadataDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_GPM_TABLE_NAME;
        self.idColumns = @[GPKG_GPM_COLUMN_PK];
        self.columns = @[GPKG_GPM_COLUMN_ID, GPKG_GPM_COLUMN_NAME, GPKG_GPM_COLUMN_PATH];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGGeoPackageMetadata alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGGeoPackageMetadata *setObject = (GPKGGeoPackageMetadata*) object;
    
    switch(columnIndex){
        case 0:
            setObject.id = (NSNumber *) value;
            break;
        case 1:
            setObject.name = (NSString *) value;
            break;
        case 2:
            setObject.path = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeoPackageMetadata *getObject = (GPKGGeoPackageMetadata*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.id;
            break;
        case 1:
            value = getObject.name;
            break;
        case 2:
            value = getObject.path;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(BOOL) deleteMetadata: (GPKGGeoPackageMetadata *) metadata{
    return [self deleteByName:metadata.name];
}

-(BOOL) deleteByName: (NSString *) name{
    
    BOOL deleted = false;
    
    GPKGGeoPackageMetadata * metadata = [self getMetadataByName:name];
    if(metadata != nil){
        GPKGTableMetadataDao * tableDao = [[GPKGTableMetadataDao alloc] initWithDatabase:self.database];
        [tableDao deleteByGeoPackageId:metadata.id];
        
        deleted = [self delete:metadata] > 0;
    }

    return deleted;
}

-(BOOL) renameMetadata: (GPKGGeoPackageMetadata *) metadata toNewName: (NSString *) newName{
    BOOL renamed = [self renameName:metadata.name toNewName:newName];
    if(renamed){
        [metadata setName:newName];
    }
    return renamed;
}

-(BOOL) renameName: (NSString *) name toNewName: (NSString *) newName{
    
    GPKGContentValues *values = [[GPKGContentValues alloc] init];
    [values putKey:GPKG_GPM_COLUMN_NAME withValue:newName];
    
    NSString * where = [self buildWhereWithField:GPKG_GPM_COLUMN_NAME andValue:name];
    NSArray * whereArgs = [self buildWhereArgsWithValue:name];
    
    int count = [self updateWithValues:values andWhere:where andWhereArgs:whereArgs];
    return count > 0;
}

-(NSArray *) getAll{
    
    NSMutableArray * allMetadata = [[NSMutableArray alloc] init];
    
    GPKGResultSet * results = [self queryForAll];
    @try{
        while([results moveToNext]){
            GPKGGeoPackageMetadata * metadata = (GPKGGeoPackageMetadata *) [self getObject:results];
            [allMetadata addObject:metadata];
        }
    }@finally{
        [results close];
    }
    
    return allMetadata;
}

-(NSArray *) getAllNames{
    return [self getAllNamesSortedBy:nil];
}

-(NSArray *) getAllNamesSorted{
    return [self getAllNamesSortedBy:GPKG_GPM_COLUMN_NAME];
}

-(NSArray *) getAllNamesSortedBy: (NSString *) column{
    NSMutableArray * names = [[NSMutableArray alloc] init];
    GPKGResultSet * results = [self queryColumns:[NSArray arrayWithObject:GPKG_GPM_COLUMN_NAME] andWhere:nil andWhereArgs:nil andGroupBy:nil andHaving:nil andOrderBy:column];
    @try{
        while([results moveToNext]){
            [names addObject:[results getString:0]];
        }
    }@finally{
        [results close];
    }
    return names;
}

-(GPKGGeoPackageMetadata *) getMetadataByName: (NSString *) name{
    return (GPKGGeoPackageMetadata *)[self getFirstObject:[self queryForEqWithField:GPKG_GPM_COLUMN_NAME andValue:name]];
}

-(GPKGGeoPackageMetadata *) getMetadataById: (NSNumber *) id{
    return (GPKGGeoPackageMetadata *)[self queryForIdObject:id];
}

-(GPKGGeoPackageMetadata *) getOrCreateMetadataByName: (NSString *) name{
    GPKGGeoPackageMetadata * metadata = [self getMetadataByName:name];
    
    if(metadata == nil){
        metadata = [[GPKGGeoPackageMetadata alloc] init];
        [metadata setName:name];
        long long id = [self create:metadata];
        [metadata setId:[NSNumber numberWithLongLong:id]];
    }
    
    return metadata;
}

-(BOOL) existsByName: (NSString *) name{
    return [self getMetadataByName:name] != nil;
}

@end
