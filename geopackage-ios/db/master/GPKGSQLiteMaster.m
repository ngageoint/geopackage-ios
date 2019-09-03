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
            constraints = [GPKGConstraintParser constraintsForSQL:sql];
        }
    }
    return constraints;
}

+(int) countWithConnection: (GPKGConnection *) db{
    // TODO
    return count(db, types(), SQLiteMasterQuery.create());
}

@end
