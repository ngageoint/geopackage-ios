//
//  GPKGTableIndexDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGTableIndexDao.h"
#import "GPKGGeometryIndexDao.h"
#import "GPKGGeometryIndex.h"
#import "GPKGExtensionsDao.h"
#import "GPKGDateTimeUtils.h"

@implementation GPKGTableIndexDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_TI_TABLE_NAME;
        self.idColumns = @[GPKG_TI_COLUMN_PK];
        self.columns = @[GPKG_TI_COLUMN_TABLE_NAME, GPKG_TI_COLUMN_LAST_INDEXED];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGTableIndex alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGTableIndex *setObject = (GPKGTableIndex*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.lastIndexed = [GPKGDateTimeUtils convertToDateWithString:((NSString *) value)];
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGTableIndex *getObject = (GPKGTableIndex*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.lastIndexed;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(int) deleteCascade: (GPKGTableIndex *) tableIndex{
    
    int count = 0;
    
    if(tableIndex != nil){
        
        // Delete Geometry Indices
        GPKGGeometryIndexDao * geometryIndexDao = [self getGeometryIndexDao];
        if([geometryIndexDao tableExists]){
            GPKGResultSet * geometryIndexResults = [self getGeometryIndices:tableIndex];
            while([geometryIndexResults moveToNext]){
                GPKGGeometryIndex * geometryIndex = (GPKGGeometryIndex *)[geometryIndexDao getObject:geometryIndexResults];
                [geometryIndexDao delete:geometryIndex];
            }
            [geometryIndexResults close];
        }
        
        // Delete
        count = [self delete:tableIndex];
    }
    
    return count;
}

-(int) deleteCascadeWithCollection: (NSArray *) tableIndexCollection{
    int count = 0;
    if(tableIndexCollection != nil){
        for(GPKGTableIndex *tableIndex in tableIndexCollection){
            count += [self deleteCascade:tableIndex];
        }
    }
    return count;
}

-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = 0;
    if(where != nil){
        GPKGResultSet *results = [self queryWhere:where andWhereArgs:whereArgs];
        while([results moveToNext]){
            GPKGTableIndex *tableIndex = (GPKGTableIndex *)[self getObject:results];
            count += [self deleteCascade:tableIndex];
        }
        [results close];
    }
    return count;
}

-(int) deleteByIdCascade: (NSString *) id{
    int count = 0;
    if(id != nil){
        GPKGTableIndex *tableIndex = (GPKGTableIndex *) [self queryForIdObject:id];
        if(tableIndex != nil){
            count = [self deleteCascade:tableIndex];
        }
    }
    return count;
}

-(int) deleteIdsCascade: (NSArray *) idCollection{
    int count = 0;
    if(idCollection != nil){
        for(NSString * id in idCollection){
            count += [self deleteByIdCascade:id];
        }
    }
    return count;
}

-(void) deleteTable: (NSString *) table{
    [self deleteByIdCascade:table];
}

-(GPKGResultSet *) getGeometryIndices: (GPKGTableIndex *) tableIndex{
    GPKGGeometryIndexDao * dao = [self getGeometryIndexDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:tableIndex.tableName];
    return results;
}

-(int) getGeometryIndexCount: (GPKGTableIndex *) tableIndex{
    GPKGResultSet * results = [self getGeometryIndices:tableIndex];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGGeometryIndexDao *) getGeometryIndexDao{
    return [[GPKGGeometryIndexDao alloc] initWithDatabase:self.database];
}

@end
