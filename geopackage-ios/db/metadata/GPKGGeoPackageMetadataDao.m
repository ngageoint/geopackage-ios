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
        self.columnNames = @[GPKG_GPM_COLUMN_ID, GPKG_GPM_COLUMN_NAME, GPKG_GPM_COLUMN_PATH];
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

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeoPackageMetadata *metadata = (GPKGGeoPackageMetadata*) object;
    
    switch(columnIndex){
        case 0:
            value = metadata.id;
            break;
        case 1:
            value = metadata.name;
            break;
        case 2:
            value = metadata.path;
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
    
    BOOL deleted = NO;
    
    GPKGGeoPackageMetadata * metadata = [self metadataByName:name];
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

-(NSArray *) all{
    
    NSMutableArray * allMetadata = [[NSMutableArray alloc] init];
    
    GPKGResultSet * results = [self queryForAll];
    @try{
        while([results moveToNext]){
            GPKGGeoPackageMetadata * metadata = (GPKGGeoPackageMetadata *) [self object:results];
            [allMetadata addObject:metadata];
        }
    }@finally{
        [results close];
    }
    
    return allMetadata;
}

-(NSArray *) allNames{
    return [self allNamesSortedBy:nil];
}

-(NSArray *) allNamesSorted{
    return [self allNamesSortedBy:GPKG_GPM_COLUMN_NAME];
}

-(NSArray *) allNamesSortedBy: (NSString *) column{
    NSMutableArray * names = [[NSMutableArray alloc] init];
    GPKGResultSet * results = [self queryColumns:[NSArray arrayWithObject:GPKG_GPM_COLUMN_NAME] andWhere:nil andWhereArgs:nil andGroupBy:nil andHaving:nil andOrderBy:column];
    @try{
        while([results moveToNext]){
            [names addObject:[results stringWithIndex:0]];
        }
    }@finally{
        [results close];
    }
    return names;
}

-(GPKGGeoPackageMetadata *) metadataByName: (NSString *) name{
    return (GPKGGeoPackageMetadata *)[self firstObject:[self queryForEqWithField:GPKG_GPM_COLUMN_NAME andValue:name]];
}

-(GPKGGeoPackageMetadata *) metadataById: (NSNumber *) id{
    return (GPKGGeoPackageMetadata *)[self queryForIdObject:id];
}

-(GPKGGeoPackageMetadata *) metadataCreateByName: (NSString *) name{
    GPKGGeoPackageMetadata * metadata = [self metadataByName:name];
    
    if(metadata == nil){
        metadata = [[GPKGGeoPackageMetadata alloc] init];
        [metadata setName:name];
        long long id = [self create:metadata];
        [metadata setId:[NSNumber numberWithLongLong:id]];
    }
    
    return metadata;
}

-(BOOL) existsByName: (NSString *) name{
    return [self metadataByName:name] != nil;
}

-(NSArray *) metadataWhereNameLike: (NSString *) like sortedBy: (NSString *) column{
    return [self metadataWhereNameLike:like sortedBy:column andNotLike:NO];
}

-(NSArray *) metadataWhereNameNotLike: (NSString *) notLike sortedBy: (NSString *) column{
    return [self metadataWhereNameLike:notLike sortedBy:column andNotLike:YES];
}

-(NSArray *) metadataWhereNameLike: (NSString *) like sortedBy: (NSString *) column andNotLike: (BOOL) notLike{
    NSMutableArray * names = [[NSMutableArray alloc] init];
    NSString * where = [NSString stringWithFormat:@"%@%@ like ?", GPKG_GPM_COLUMN_NAME, notLike ? @" not" : @""];
    NSArray * whereArgs = [[NSArray alloc] initWithObjects:like, nil];
    GPKGResultSet * results = [self queryColumns:[NSArray arrayWithObject:GPKG_GPM_COLUMN_NAME] andWhere:where andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:column];
    @try{
        while([results moveToNext]){
            [names addObject:[results stringWithIndex:0]];
        }
    }@finally{
        [results close];
    }
    return names;
}

@end
