//
//  GPKGSQLiteMaster.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGSQLiteMaster.h"
#import "GPKGConstraintParser.h"

NSString * const GPKG_SM_TABLE_NAME = @"sqlite_master";

@interface GPKGSQLiteMaster()

/**
 * SQLiteMaster query results
 */
@property (nonatomic, strong) NSArray<NSArray<NSObject *> *> *results;

/**
 * Mapping between result columns and indices
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *columnIndices;

/**
 * Query result count
 */
@property (nonatomic) int count;

@end

@implementation GPKGSQLiteMaster

/**
 * Initializer
 *
 * @param results
 *            query results
 * @param columns
 *            query columns
 */
-(instancetype) initWithResults: (NSArray<NSArray<NSObject *> *> *) results andColumns: (NSArray<NSNumber *> *) columns{
    self = [super init];
    if(self != nil){
        self.columnIndices = [[NSMutableDictionary alloc] init];
        
        if(columns != nil){
            
            self.results = results;
            self.count = (int) results.count;
            
            for(int i = 0; i < columns.count; i++){
                [self.columnIndices setObject:[NSNumber numberWithInt:i] forKey:[columns objectAtIndex:i]];
            }
            
        }else{
            // Count only result
            self.results = [[NSArray alloc] init];
            self.count = [((NSNumber *)[[results objectAtIndex:0] objectAtIndex:0]) intValue];
        }
    }
    return self;
}

-(int) count{
    return _count;
}

-(NSArray<NSNumber *> *) columns{
    return [self.columnIndices allKeys];
}

-(enum GPKGSQLiteMasterType) typeAtRow: (int) row{
    return [GPKGSQLiteMasterTypes fromName:[self typeStringAtRow:row]];
}

-(NSString *) typeStringAtRow: (int) row{
    return (NSString *)[self valueAtRow:row forColumn:GPKG_SMC_TYPE];
}

-(NSString *) nameAtRow: (int) row{
    return (NSString *)[self valueAtRow:row forColumn:GPKG_SMC_NAME];
}

-(NSString *) tableNameAtRow: (int) row{
    return (NSString *)[self valueAtRow:row forColumn:GPKG_SMC_TBL_NAME];
}

-(NSNumber *) rootpageAtRow: (int) row{
    return (NSNumber *)[self valueAtRow:row forColumn:GPKG_SMC_ROOTPAGE];
}

-(NSString *) sqlAtRow: (int) row{
    return (NSString *)[self valueAtRow:row forColumn:GPKG_SMC_SQL];
}

-(NSObject *) valueAtRow: (int) row forColumn: (enum GPKGSQLiteMasterColumn) column{
    return [self valueInRow:[self row:row] forColumn:column];
}

-(NSArray<NSObject *> *) row: (int) row{
    if(row < 0 || row >= self.results.count){
        NSString *message = nil;
        if(self.results.count == 0){
            message = @"Results are empty";
        }else{
            message = [NSString stringWithFormat:@"Row index: %d, not within range 0 to %d", row, (int)self.results.count - 1];
        }
        [NSException raise:@"Index Out Of Bounds" format:message, nil];
    }
    return [self.results objectAtIndex:row];
}

-(NSObject *) valueInRow: (NSArray<NSObject *> *) row forColumn: (enum GPKGSQLiteMasterColumn) column{
    return [row objectAtIndex:[self columnIndex:column]];
}

-(int) columnIndex: (enum GPKGSQLiteMasterColumn) column{
    NSNumber *index = [self.columnIndices objectForKey:[NSNumber numberWithInteger:column]];
    if(index == nil){
        [NSException raise:@"Index Out Of Bounds" format:@"Column does not exist in row values: %@", [GPKGSQLiteMasterColumns name:column]];
    }
    return [index intValue];
}

-(GPKGTableConstraints *) constraintsAtRow: (int) row{
    GPKGTableConstraints *constraints = [[GPKGTableConstraints alloc] init];
    if([self typeAtRow:row] == GPKG_SMT_TABLE){
        NSString *sql = [self sqlAtRow:row];
        if(sql != nil){
            constraints = [GPKGConstraintParser tableConstraintsForSQL:sql];
        }
    }
    return constraints;
}

+(NSArray *) columnsFromColumn: (enum GPKGSQLiteMasterColumn) column{
    return [NSArray arrayWithObject:[NSNumber numberWithInteger:column]];
}

+(NSArray *) typesFromType: (enum GPKGSQLiteMasterType) type{
    return [NSArray arrayWithObject:[NSNumber numberWithInteger:type]];
}

+(int) countWithConnection: (GPKGConnection *) db{
    return [self countWithConnection:db andTypes:nil andQuery:nil];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db{
    return [self queryWithConnection:db andQuery:nil];
}

+(int) countWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName{
    return [self countWithConnection:db andTypes:nil andTable:tableName];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName{
    return [self queryWithConnection:db andColumns:[GPKGSQLiteMasterColumns values] andTypes:nil andTable:tableName];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns{
    return [self queryWithConnection:db andColumns:columns andTable:nil];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTable: (NSString *) tableName{
    return [self queryWithConnection:db andColumns:columns andTypes:nil andTable:tableName];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type{
    return [self queryWithConnection:db andType:type andTable:nil];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types{
    return [self queryWithConnection:db andTypes:types andTable:nil];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andTable: (NSString *) tableName{
    return [self queryWithConnection:db andColumns:[GPKGSQLiteMasterColumns values] andType:type andTable:tableName];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types andTable: (NSString *) tableName{
    return [self queryWithConnection:db andColumns:[GPKGSQLiteMasterColumns values] andTypes:types andTable: tableName];
}

+(int) countWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type{
    return [self countWithConnection:db andTypes:[self typesFromType:type]];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andType: (enum GPKGSQLiteMasterType) type{
    return [self queryWithConnection:db andColumns:columns andTypes:[self typesFromType:type]];
}

+(int) countWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andTable: (NSString *) tableName{
    return [self countWithConnection:db andTypes:[self typesFromType:type] andTable:tableName];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andType: (enum GPKGSQLiteMasterType) type andTable: (NSString *) tableName{
    return [self queryWithConnection:db andColumns:columns andTypes:[self typesFromType:type] andTable:tableName];
}

+(int) countWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types{
    return [self countWithConnection:db andTypes:types andQuery:nil];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTypes: (NSArray<NSNumber *> *) types{
    return [self queryWithConnection:db andColumns:columns andTypes:types andQuery:nil];
}

+(int) countWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types andTable: (NSString *) tableName{
    GPKGSQLiteMasterQuery *query = nil;
    if(tableName != nil){
        query = [GPKGSQLiteMasterQuery createWithColumn:GPKG_SMC_TBL_NAME andValue:tableName];
    }
    return [self countWithConnection:db andTypes:types andQuery:query];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTypes: (NSArray<NSNumber *> *) types andTable: (NSString *) tableName{
    GPKGSQLiteMasterQuery *query = nil;
    if(tableName != nil){
        query = [GPKGSQLiteMasterQuery createWithColumn:GPKG_SMC_TBL_NAME andValue:tableName];
    }
    return [self queryWithConnection:db andColumns:columns andTypes:types andQuery:query];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andQuery: (GPKGSQLiteMasterQuery *) query{
    return [self queryWithConnection:db andColumns:[GPKGSQLiteMasterColumns values] andQuery:query];
}

+(int) countWithConnection: (GPKGConnection *) db andQuery: (GPKGSQLiteMasterQuery *) query{
    return [self countWithConnection:db andTypes:nil andQuery:query];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andQuery: (GPKGSQLiteMasterQuery *) query{
    return [self queryWithConnection:db andColumns:columns andTypes:nil andQuery:query];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andQuery: (GPKGSQLiteMasterQuery *) query{
    return [self queryWithConnection:db andColumns:[GPKGSQLiteMasterColumns values] andType:type andQuery:query];
}

+(int) countWithConnection: (GPKGConnection *) db andType: (enum GPKGSQLiteMasterType) type andQuery: (GPKGSQLiteMasterQuery *) query{
    return [self countWithConnection:db andTypes:[self typesFromType:type] andQuery:query];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andType: (enum GPKGSQLiteMasterType) type andQuery: (GPKGSQLiteMasterQuery *) query{
    return [self queryWithConnection:db andColumns:columns andTypes:[self typesFromType:type] andQuery:query];
}

+(int) countWithConnection: (GPKGConnection *) db andTypes: (NSArray<NSNumber *> *) types andQuery: (GPKGSQLiteMasterQuery *) query{
    return [[self queryWithConnection:db andColumns:nil andTypes:types andQuery:query] count];
}

+(GPKGSQLiteMaster *) queryWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTypes: (NSArray<NSNumber *> *) types andQuery: (GPKGSQLiteMasterQuery *) query{
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    NSMutableArray<NSString *> *args = [[NSMutableArray alloc] init];
    
    if(columns != nil && columns.count > 0){
        
        for(int i = 0; i < columns.count; i++){
            if(i > 0){
                [sql appendString:@", "];
            }
            enum GPKGSQLiteMasterColumn column = [[columns objectAtIndex:i] intValue];
            [sql appendFormat:@"%@", [[GPKGSQLiteMasterColumns name:column] lowercaseString]];
        }
        
    }else{
        [sql appendString:@"count(*)"];
    }
    
    [sql appendString:@" FROM "];
    [sql appendString:GPKG_SM_TABLE_NAME];
    
    BOOL hasQuery = query != nil && [query has];
    BOOL hasTypes = types != nil && types.count > 0;
    
    if (hasQuery || hasTypes) {
        
        [sql appendString:@" WHERE "];
        
        if (hasQuery) {
            [sql appendFormat:@"%@", [query buildSQL]];
            [args addObjectsFromArray:[query arguments]];
        }
        
        if (hasTypes) {
            
            if (hasQuery) {
                [sql appendString:@" AND"];
            }
            
            [sql appendString:@" type IN ("];
            for (int i = 0; i < types.count; i++) {
                if (i > 0) {
                    [sql appendString:@", "];
                }
                [sql appendString:@"?"];
                enum GPKGSQLiteMasterType type = [[types objectAtIndex:i] intValue];
                [args addObject:[[GPKGSQLiteMasterTypes name:type] lowercaseString]];
            }
            [sql appendString:@")"];
        }
    }
    
    NSArray<NSArray<NSObject *> *> *results = [db queryResultsWithSql:sql andArgs:args];
    
    GPKGSQLiteMaster *sqliteMaster = [[GPKGSQLiteMaster alloc] initWithResults:results andColumns:columns];
    
    return sqliteMaster;
}

+(GPKGSQLiteMaster *) queryViewsWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName{
    return [self queryViewsWithConnection:db andColumns:[GPKGSQLiteMasterColumns values] andTable:tableName];
}

+(GPKGSQLiteMaster *) queryViewsWithConnection: (GPKGConnection *) db andColumns: (NSArray<NSNumber *> *) columns andTable: (NSString *) tableName{
    return [self queryWithConnection:db andColumns:columns andType:GPKG_SMT_VIEW andQuery:[GPKGSQLiteMasterQuery createViewQueryWithTable:tableName]];
}

+(int) countViewsWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName{
    return [self countWithConnection:db andType:GPKG_SMT_VIEW andQuery:[GPKGSQLiteMasterQuery createViewQueryWithTable:tableName]];
}

+(GPKGTableConstraints *) queryForConstraintsWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName{
    GPKGTableConstraints *constraints = [[GPKGTableConstraints alloc] init];
    GPKGSQLiteMaster *tableMaster = [self queryWithConnection:db andType:GPKG_SMT_TABLE andTable:tableName];
    for(int i = 0; i < [tableMaster count]; i++){
        [constraints addConstraints:[tableMaster constraintsAtRow:i]];
    }
    return constraints;
}

@end
