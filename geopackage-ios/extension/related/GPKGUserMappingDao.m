//
//  GPKGUserMappingDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserMappingDao.h"
#import "GPKGSqlUtils.h"

@implementation GPKGUserMappingDao

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao{
    self = [self initWithDao:dao andTable:[[GPKGUserMappingTable alloc] initWithTable:[dao userCustomTable]]];
    return self;
}

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao andTable: (GPKGUserMappingTable *) userMappingTable{
    self = [super initWithDao:dao andTable:userMappingTable];
    if(self != nil){
        self.autoIncrementId = NO;
    }
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGUserMappingTable *) userMappingTable{
    return (GPKGUserMappingTable *)[super userCustomTable];
}

-(GPKGUserMappingRow *) row: (GPKGResultSet *) results{
    return (GPKGUserMappingRow *) [super row:results];
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGUserMappingRow alloc] initWithUserMappingTable:[self userMappingTable] andColumns:columns andValues:values];
}

-(GPKGUserMappingRow *) newRow{
    return [[GPKGUserMappingRow alloc] initWithUserMappingTable:[self userMappingTable]];
}

-(GPKGResultSet *) queryByBaseIdFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self queryByBaseId:[userMappingRow baseId]];
}

-(GPKGResultSet *) queryByBaseId: (int) baseId{
    return [self queryForEqWithField:GPKG_UMT_COLUMN_BASE_ID andValue:[NSNumber numberWithInt:baseId]];
}

-(int) countByBaseIdFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self countByBaseId:[userMappingRow baseId]];
}

-(int) countByBaseId: (int) baseId{
    return [self countOfResultSet:[self queryByBaseId:baseId]];
}

-(GPKGResultSet *) queryByRelatedIdFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self queryByRelatedId:[userMappingRow baseId]];
}

-(GPKGResultSet *) queryByRelatedId: (int) relatedId{
    return [self queryForEqWithField:GPKG_UMT_COLUMN_RELATED_ID andValue:[NSNumber numberWithInt:relatedId]];
}

-(int) countByRelatedIdFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self countByRelatedId:[userMappingRow relatedId]];
}
-(int) countByRelatedId: (int) relatedId{
    return [self countOfResultSet:[self queryByRelatedId:relatedId]];
}

-(GPKGResultSet *) queryByIdsFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self queryByBaseId:[userMappingRow baseId] andRelatedId:[userMappingRow relatedId]];
}

-(GPKGResultSet *) queryByBaseId: (int) baseId andRelatedId: (int) relatedId{
    GPKGColumnValues *values = [self buildColumnValuesWithBaseId:baseId andRelatedId:relatedId];
    return [self queryWhere:[self buildWhereWithFields:values] andWhereArgs:[self buildWhereArgsWithValues:values]];
}

-(NSArray<NSNumber *> *) uniqueBaseIds{
    return (NSArray<NSNumber *> *)[self querySingleColumnResultsWithSql:[NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@", [GPKGSqlUtils quoteWrapName:GPKG_UMT_COLUMN_BASE_ID], [GPKGSqlUtils quoteWrapName:self.tableName]] andArgs:nil];
}

-(NSArray<NSNumber *> *) uniqueRelatedIds{
    return (NSArray<NSNumber *> *)[self querySingleColumnResultsWithSql:[NSString stringWithFormat:@"SELECT DISTINCT %@ FROM %@", [GPKGSqlUtils quoteWrapName:GPKG_UMT_COLUMN_RELATED_ID], [GPKGSqlUtils quoteWrapName:self.tableName]] andArgs:nil];
}

-(int) countByIdsFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self countByBaseId:[userMappingRow baseId] andRelatedId:[userMappingRow relatedId]];
}

-(int) countByBaseId: (int) baseId andRelatedId: (int) relatedId{
    return [self countOfResultSet:[self queryByBaseId:baseId andRelatedId:relatedId]];
}

-(int) deleteByBaseIdFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self deleteByBaseId:[userMappingRow baseId]];
}

-(int) deleteByBaseId: (int) baseId{
    NSNumber *baseIdNumber = [NSNumber numberWithInt:baseId];
    int deleted = [self deleteWhere:[self buildWhereWithField:GPKG_UMT_COLUMN_BASE_ID andValue:baseIdNumber] andWhereArgs:[self buildWhereArgsWithValue:baseIdNumber]];
    return deleted;
}

-(int) deleteByRelatedIdFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self deleteByRelatedId:[userMappingRow relatedId]];
}

-(int) deleteByRelatedId: (int) relatedId{
    NSNumber *relatedIdNumber = [NSNumber numberWithInt:relatedId];
    int deleted = [self deleteWhere:[self buildWhereWithField:GPKG_UMT_COLUMN_RELATED_ID andValue:relatedIdNumber] andWhereArgs:[self buildWhereArgsWithValue:relatedIdNumber]];
    return deleted;
}

-(int) deleteByIdsFromRow: (GPKGUserMappingRow *) userMappingRow{
    return [self deleteByBaseId:[userMappingRow baseId] andRelatedId:[userMappingRow relatedId]];
}

-(int) deleteByBaseId: (int) baseId andRelatedId: (int) relatedId{
    GPKGColumnValues *values = [self buildColumnValuesWithBaseId:baseId andRelatedId:relatedId];
    return [self deleteWhere:[self buildWhereWithFields:values] andWhereArgs:[self buildWhereArgsWithValues:values]];
}

/**
 * Build the column values for the base and related ids
 *
 * @param baseId
 *            base id
 * @param relatedId
 *            related id
 * @return column values
 */
-(GPKGColumnValues *) buildColumnValuesWithBaseId: (int) baseId andRelatedId: (int) relatedId{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_UMT_COLUMN_BASE_ID withValue:[NSNumber numberWithInt:baseId]];
    [values addColumn:GPKG_UMT_COLUMN_RELATED_ID withValue:[NSNumber numberWithInt:relatedId]];
    
    return values;
}

@end
