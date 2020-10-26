//
//  GPKGAlterTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/21/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAlterTable.h"
#import "GPKGSqlUtils.h"
#import "GPKGUserCustomTableReader.h"
#import "GPKGRawConstraint.h"
#import "GPKGSQLiteMaster.h"
#import "GPKGRTreeIndexExtension.h"

@implementation GPKGAlterTable

+(NSString *) alterTable: (NSString *) table{
    return [NSString stringWithFormat:@"ALTER TABLE %@", [GPKGSqlUtils quoteWrapName:table]];
}

+(void) renameTable: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    NSString *sql = [self renameTableSQL:tableName toTable:newTableName];
    [db execResettable:sql];
}

+(NSString *) renameTableSQL: (NSString *) tableName toTable: (NSString *) newTableName{
    return [NSString stringWithFormat:@"%@ RENAME TO %@", [self alterTable:tableName], [GPKGSqlUtils quoteWrapName:newTableName]];
}

+(void) renameColumn: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName withConnection: (GPKGConnection *) db{
    NSString *sql = [self renameColumnSQL:columnName inTable:tableName toColumn:newColumnName];
    [db execResettable:sql];
}

+(NSString *) renameColumnSQL: (NSString *) columnName inTable: (NSString *) tableName toColumn: (NSString *) newColumnName{
    return [NSString stringWithFormat:@"%@ RENAME COLUMN %@ TO %@", [self alterTable:tableName], [GPKGSqlUtils quoteWrapName:columnName], [GPKGSqlUtils quoteWrapName:newColumnName]];
}

+(void) addColumn: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName withConnection: (GPKGConnection *) db{
    NSString *sql = [self addColumnSQL:columnName withDefinition:columnDef toTable:tableName];
    [db execResettable:sql];
}

+(NSString *) addColumnSQL: (NSString *) columnName withDefinition: (NSString *) columnDef toTable: (NSString *) tableName{
    return [NSString stringWithFormat:@"%@ ADD COLUMN %@ %@", [self alterTable:tableName], [GPKGSqlUtils quoteWrapName:columnName], columnDef];
}

+(void) dropColumn: (NSString *) columnName fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    [self dropColumns:[NSArray arrayWithObject:columnName] fromTable:table withConnection:db];
}

+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{

    GPKGUserTable *newTable = [table mutableCopy];
    
    for(NSString *columnName in columnNames){
        [newTable dropColumnWithName:columnName];
    }
    
    // Build the table mapping
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:newTable andDroppedColumns:columnNames];
    
    [self alterTable:newTable withMapping:tableMapping withConnection:db];
    
    for(NSString *columnName in columnNames){
        [table dropColumnWithName:columnName];
    }
}

+(void) dropColumn: (NSString *) columnName fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    [self dropColumns:[NSArray arrayWithObject:columnName] fromTableName:tableName withConnection:db];
}

+(void) dropColumns: (NSArray<NSString *> *) columnNames fromTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:db andTableName:tableName];
    [self dropColumns:columnNames fromTable:userTable withConnection:db];
}

+(void) alterColumn: (GPKGUserColumn *) column inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{
    [self alterColumns:[NSArray arrayWithObject:column] inTable:table withConnection:db];
}

+(void) alterColumns: (NSArray<GPKGUserColumn *> *) columns inTable: (GPKGUserTable *) table withConnection: (GPKGConnection *) db{

    GPKGUserTable *newTable = [table mutableCopy];
    
    for(GPKGUserColumn *column in columns){
        [newTable alterColumn:column];
    }
    
    [self alterTable:newTable withConnection:db];
    
    for(GPKGUserColumn *column in columns){
        [table alterColumn:column];
    }
}

+(void) alterColumn: (GPKGUserCustomColumn *) column inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    [self alterColumns:[NSArray arrayWithObject:column] inTableName:tableName withConnection:db];
}

+(void) alterColumns: (NSArray<GPKGUserCustomColumn *> *) columns inTableName: (NSString *) tableName withConnection: (GPKGConnection *) db{
    GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:db andTableName:tableName];
    [self alterColumns:columns inTable:userTable withConnection:db];
}

+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    [self copyTable:table toTable:newTableName andTransfer:YES withConnection:db];
}

+(void) copyTable: (GPKGUserTable *) table toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db{

    // Build the table mapping
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:table andNewTable:newTableName];
    [tableMapping setTransferContent:transferContent];
    
    [self alterTable:table withMapping:tableMapping withConnection:db];
}

+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName withConnection: (GPKGConnection *) db{
    [self copyTableName:tableName toTable:newTableName andTransfer:YES withConnection:db];
}

+(void) copyTableName: (NSString *) tableName toTable: (NSString *) newTableName andTransfer: (BOOL) transferContent withConnection: (GPKGConnection *) db{
    GPKGUserCustomTable *userTable = [GPKGUserCustomTableReader readTableWithConnection:db andTableName:tableName];
    [self copyTable:userTable toTable:newTableName andTransfer:transferContent withConnection:db];
}

+(void) alterTable: (GPKGUserTable *) newTable withConnection: (GPKGConnection *) db{

    // Build the table mapping
    GPKGTableMapping *tableMapping = [[GPKGTableMapping alloc] initWithTable:newTable];
    
    [self alterTable:newTable withMapping:tableMapping withConnection:db];
}

+(void) alterTable: (GPKGUserTable *) newTable withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{

    // Update column constraints
    for(GPKGUserColumn * column in [newTable columns]){
        NSArray<GPKGConstraint *> *columnConstraints = [column clearConstraints];
        for(GPKGConstraint * columnConstraint in columnConstraints){
            NSString *updatedSql = [GPKGSqlUtils modifySQL:[columnConstraint buildSql] withName:columnConstraint.name andTableMapping:tableMapping];
            if (updatedSql != nil) {
                [column addConstraint:[[GPKGRawConstraint alloc] initWithType:columnConstraint.type andSql:updatedSql]];
            }
        }
    }
    
    // Update table constraints
    NSArray<GPKGConstraint *> *tableContraints = [newTable clearConstraints];
    for(GPKGConstraint * tableConstraint in tableContraints){
        NSString *updatedSql = [GPKGSqlUtils modifySQL:[tableConstraint buildSql] withName:tableConstraint.name andTableMapping:tableMapping];
        if (updatedSql != nil) {
            [newTable addConstraint:[[GPKGRawConstraint alloc] initWithType:tableConstraint.type andSql:updatedSql]];
        }
    }
    
    // Build the create table sql
    NSString *sql = [GPKGSqlUtils createTableSQL:newTable];
    
    [self alterTableSQL:sql withMapping:tableMapping withConnection:db];
}

+(void) alterTableSQL: (NSString *) sql withMapping: (GPKGTableMapping *) tableMapping withConnection: (GPKGConnection *) db{

    NSString *tableName = tableMapping.fromTable;
    
    // Determine if a new table copy vs an alter table
    BOOL newTable = [tableMapping isNewTable];
    
    // 1. Disable foreign key constraints
    BOOL enableForeignKeys = [GPKGSqlUtils foreignKeysAsOn:NO withConnection:db];
    
    // 2. Start a transaction
    BOOL successful = YES;
    [db beginResettableTransaction];
    @try {
        
        // 9a. Query for views
        GPKGSQLiteMaster *views = [GPKGSQLiteMaster queryViewsWithConnection:db andColumns:[NSArray arrayWithObjects:[NSNumber numberWithInteger:GPKG_SMC_NAME], [NSNumber numberWithInteger:GPKG_SMC_SQL], nil] andTable:tableName];
        // Remove the views if not a new table
        if (!newTable) {
            for (int i = 0; i < views.count; i++) {
                NSString *viewName = [views nameAtRow:i];
                @try {
                    [GPKGSqlUtils dropView:viewName withConnection:db];
                } @catch (NSException *exception) {
                    NSLog(@"Failed to drop view: %@, table: %@. error: %@", viewName, tableName, exception);
                }
            }
        }
        
        // 3. Query indexes and triggers
        GPKGSQLiteMaster *indexesAndTriggers = [GPKGSQLiteMaster queryWithConnection:db
                                                    andColumns:[NSArray arrayWithObjects:
                                                                [NSNumber numberWithInteger:GPKG_SMC_NAME],
                                                                [NSNumber numberWithInteger:GPKG_SMC_TYPE],
                                                                [NSNumber numberWithInteger:GPKG_SMC_SQL],
                                                                nil]
                                                    andTypes:[NSArray arrayWithObjects:
                                                              [NSNumber numberWithInteger:GPKG_SMT_INDEX],
                                                              [NSNumber numberWithInteger:GPKG_SMT_TRIGGER],
                                                              nil]
                                                    andTable:tableName];
        
        // Get the temporary or new table name
        NSString *transferTable;
        if (newTable) {
            transferTable = tableMapping.toTable;
        } else {
            transferTable = [GPKGSqlUtils tempTableNameWithPrefix:@"new" andBaseName:tableName withConnection:db];
            [tableMapping setToTable:transferTable];
        }
        
        // 4. Create the new table
        NSRange tableNameRange = [sql rangeOfString:tableName];
        if (tableNameRange.location != NSNotFound) {
            sql = [sql stringByReplacingCharactersInRange:tableNameRange withString:transferTable];
        }
        [db exec:sql];
        
        // If transferring content
        if (tableMapping.transferContent) {
            
            // 5. Transfer content to new table
            [GPKGSqlUtils transferTableContent:tableMapping withConnection:db];
            
        }
        
        // If altering a table
        if (!newTable) {
            
            // 6. Drop the old table
            [GPKGSqlUtils dropTable:tableName withConnection:db];
            
            // 7. Rename the new table
            [self renameTable:transferTable toTable:tableName withConnection:db];
            
            [tableMapping setToTable:tableName];
        }
        
        // 8. Create the indexes and triggers
        for (int i = 0; i < [indexesAndTriggers count]; i++) {
            BOOL create = !newTable;
            if (!create) {
                // Don't create rtree triggers for new tables
                create = [indexesAndTriggers typeAtRow:i] != GPKG_SMT_TRIGGER
                    || ![[indexesAndTriggers nameAtRow:i] hasPrefix:GPKG_RTREE_INDEX_PREFIX];
            }
            if (create) {
                NSString *tableSql = [indexesAndTriggers sqlAtRow:i];
                if (tableSql != nil) {
                    tableSql = [GPKGSqlUtils modifySQL:tableSql withName:[indexesAndTriggers nameAtRow:i] andTableMapping:tableMapping withConnection:db];
                    if (tableSql != nil) {
                        @try {
                            [db exec:tableSql];
                        } @catch (NSException *exception) {
                            NSLog(@"Failed to recreate %@ after table alteration. table: %@, sql: %@. error: %@", [GPKGSQLiteMasterTypes name:[indexesAndTriggers typeAtRow:i]], tableMapping.toTable, tableSql, exception);
                        }
                    }
                }
            }
        }
        
        // 9b. Recreate views
        for (int i = 0; i < views.count; i++) {
            NSString *viewSql = [views sqlAtRow:i];
            if (viewSql != nil) {
                viewSql = [GPKGSqlUtils modifySQL:viewSql withName:[views nameAtRow:i] andTableMapping:tableMapping withConnection:db];
                if (viewSql != nil) {
                    @try {
                        [db exec:viewSql];
                    } @catch (NSException *exception) {
                        NSLog(@"Failed to recreate view: %@, table: %@, sql: %@. error: %@", [views nameAtRow:i], tableMapping.toTable, viewSql, exception);
                    }
                }
            }
        }
        
        // 10. Foreign key check
        if (enableForeignKeys) {
            [self foreignKeyCheck:db];
        }
        
    } @catch (NSException *exception) {
        successful = NO;
        @throw exception;
    } @finally {
        // 11. Commit the transaction
        [db commitTransaction];
    }
    
    // 12. Re-enable foreign key constraints
    if (enableForeignKeys) {
        [GPKGSqlUtils foreignKeysAsOn:YES withConnection:db];
    }

}

/**
 * Perform a foreign key check for violations
 *
 * @param db
 *            connection
 */
+(void) foreignKeyCheck: (GPKGConnection *) db{
    
    NSArray<NSArray<NSObject *> *> *violations = [GPKGSqlUtils foreignKeyCheckWithConnection:db];
    
    if(violations.count > 0){
        NSMutableString *violationsMessage = [NSMutableString string];
        for (int i = 0; i < violations.count; i++) {
            if (i > 0) {
                [violationsMessage appendString:@"; "];
            }
            [violationsMessage appendFormat:@"%d: ", i + 1];
            NSArray<NSObject *> *violation = [violations objectAtIndex:i];
            for (int j = 0; j < violation.count; j++) {
                if (j > 0) {
                    [violationsMessage appendString:@", "];
                }
                [violationsMessage appendString:[[violation objectAtIndex:j] description]];
            }
        }
        [NSException raise:@"Foreign Key Check" format:@"Foreign Key Check Violations: %@", violationsMessage];
    }
    
}

@end
