//
//  GPKGExtendedRelationsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGExtendedRelationsDao.h"

@implementation GPKGExtendedRelationsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_ER_TABLE_NAME;
        self.idColumns = @[GPKG_ER_COLUMN_PK];
        self.columns = @[GPKG_ER_COLUMN_ID, GPKG_ER_COLUMN_BASE_TABLE_NAME, GPKG_ER_COLUMN_BASE_PRIMARY_COLUMN, GPKG_ER_COLUMN_RELATED_TABLE_NAME, GPKG_ER_COLUMN_RELATED_PRIMARY_COLUMN, GPKG_ER_COLUMN_RELATION_NAME, GPKG_ER_COLUMN_MAPPING_TABLE_NAME];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGExtendedRelation alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGExtendedRelation *setObject = (GPKGExtendedRelation*) object;
    
    switch(columnIndex){
        case 0:
            setObject.id = (NSNumber *) value;
            break;
        case 1:
            setObject.baseTableName = (NSString *) value;
            break;
        case 2:
            setObject.basePrimaryColumn = (NSString *) value;
            break;
        case 3:
            setObject.relatedTableName = (NSString *) value;
            break;
        case 4:
            setObject.relatedPrimaryColumn = (NSString *) value;
            break;
        case 5:
            setObject.relationName = (NSString *) value;
            break;
        case 6:
            setObject.mappingTableName = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGExtendedRelation *getObject = (GPKGExtendedRelation*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.id;
            break;
        case 1:
            value = getObject.baseTableName;
            break;
        case 2:
            value = getObject.basePrimaryColumn;
            break;
        case 3:
            value = getObject.relatedTableName;
            break;
        case 4:
            value = getObject.relatedPrimaryColumn;
            break;
        case 5:
            value = getObject.relationName;
            break;
        case 6:
            value = getObject.mappingTableName;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(NSArray<NSString *> *) baseTables{
    
    NSMutableArray *baseTables = [[NSMutableArray alloc] init];
    
    GPKGResultSet *results = [self queryForAll];
    @try {
        while([results moveToNext]){
            GPKGExtendedRelation *extendedRelation = (GPKGExtendedRelation *)[self getObject:results];
            [baseTables addObject:extendedRelation.baseTableName];
        }
    } @finally {
        [results close];
    }

    return baseTables;
}

-(NSArray<NSString *> *) relatedTables{
    
    NSMutableArray *relatedTables = [[NSMutableArray alloc] init];
    
    GPKGResultSet *results = [self queryForAll];
    @try {
        while([results moveToNext]){
            GPKGExtendedRelation *extendedRelation = (GPKGExtendedRelation *)[self getObject:results];
            [relatedTables addObject:extendedRelation.relatedTableName];
        }
    } @finally {
        [results close];
    }
    
    return relatedTables;
}

-(GPKGResultSet *) relationsToBaseTable: (NSString *) baseTable{
    return [self queryForEqWithField:GPKG_ER_COLUMN_BASE_TABLE_NAME andValue:baseTable];
}

-(GPKGResultSet *) relationsToRelatedTable: (NSString *) relatedTable{
    return [self queryForEqWithField:GPKG_ER_COLUMN_RELATED_TABLE_NAME andValue:relatedTable];
    
}

-(GPKGResultSet *) relationsToTable: (NSString *) table{
    
    GPKGColumnValues *whereValues = [[GPKGColumnValues alloc] init];
    [whereValues addColumn:GPKG_ER_COLUMN_BASE_TABLE_NAME withValue:table];
    [whereValues addColumn:GPKG_ER_COLUMN_RELATED_TABLE_NAME withValue:table];
    
    NSString * where = [self buildWhereWithFields:whereValues];
    NSArray * whereArgs = [self buildWhereArgsWithValues:whereValues];
    
    return [self queryWhere:where andWhereArgs:whereArgs];
}

@end