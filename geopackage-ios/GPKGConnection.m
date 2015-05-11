//
//  GPKGConnection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/7/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGConnection.h"
#import <sqlite3.h>

@interface GPKGConnection()

@property (nonatomic) sqlite3 *database;

@property (nonatomic, strong) NSString *databaseFilename;

@property (nonatomic, strong) NSMutableArray *arrResults;

-(void)copyDatabaseIntoDocumentsDirectory;

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)queryExecutable withDatabase:(sqlite3 *)sqlite3Database;

@end

@implementation GPKGConnection

-(instancetype)initWithDatabaseFilename:(NSString *)dbFilename{
    self = [super init];
    if(self){
        self.databaseFilename = dbFilename;
    }
    
    // Open the database.
    NSString *databasePath  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
    sqlite3 *sqlite3Database;
    BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
    if(openDatabaseResult != SQLITE_OK){
        // In the database cannot be opened then show the error message on the debugger.
        NSLog(@"%s", sqlite3_errmsg(self.database));
    }else{
        self.database = sqlite3Database;
    }

    return self;
}

-(void)runQuery:(const char *)query isUpdate:(BOOL)update{

    // Set the database file path.
    NSString *databasePath  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
    
    // Initialize the results array.
    if (self.arrResults != nil) {
        [self.arrResults removeAllObjects];
        self.arrResults = nil;
    }
    self.arrResults = [[NSMutableArray alloc] init];
    
    // Initialize the column names array.
    if (self.arrColumnNames != nil) {
        [self.arrColumnNames removeAllObjects];
        self.arrColumnNames = nil;
    }
    self.arrColumnNames = [[NSMutableArray alloc] init];
    
    // Declare a sqlite3_stmt object in which will be stored the query after having been compiled into a SQLite statement.
    sqlite3_stmt *compiledStatement;
    
    // Load all data from database to memory.
    BOOL prepareStatementResult = sqlite3_prepare_v2(self.database, query, -1, &compiledStatement, NULL);
    if(prepareStatementResult == SQLITE_OK) {
        // Check if the query is non-executable.
        if (!update){
            // In this case data must be loaded from the database.
            
            // Declare an array to keep the data for each fetched row.
            NSMutableArray *arrDataRow;
            
            // Loop through the results and add them to the results array row by row.
            while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                // Initialize the mutable array that will contain the data of a fetched row.
                arrDataRow = [[NSMutableArray alloc] init];
                
                // Get the total number of columns.
                int totalColumns = sqlite3_column_count(compiledStatement);
                
                // Go through all columns and fetch each column data.
                for (int i=0; i<totalColumns; i++){
                    
                    int type = sqlite3_column_type(compiledStatement, i);
                    switch (type) {
                        case SQLITE_TEXT:;
                            
                            // Convert the column data to text (characters).
                            char *dbDataAsChars = (char *)sqlite3_column_text(compiledStatement, i);
                            
                            // If there are contents in the currenct column (field) then add them to the current row array.
                            if (dbDataAsChars != NULL) {
                                // Convert the characters to string.
                                [arrDataRow addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                            }
                            break;
                            
                        case SQLITE_INTEGER:;
                            
                            int intValue = sqlite3_column_int(compiledStatement, i);
                            [arrDataRow addObject:[NSNumber numberWithInt: intValue]];
                            
                            break;
                            
                        case SQLITE_FLOAT:;
                            
                            double floatValue = sqlite3_column_double(compiledStatement, i);
                            [arrDataRow addObject:[NSNumber numberWithDouble: floatValue]];
                            
                            break;
                            
                        case SQLITE_NULL:
                            
                            [arrDataRow addObject:nil];
                            break;
                            
                        case SQLITE_BLOB:
                            {
                                NSData *blobValue = [[NSData alloc] initWithBytes:sqlite3_column_blob(compiledStatement, i) length:sqlite3_column_bytes(compiledStatement,  i)];
                                [arrDataRow addObject:blobValue];
                            }
                            break;
                            
                        default:
                            break;
                    }
                    
                    // Keep the current column name.
                    if (self.arrColumnNames.count != totalColumns) {
                        char *columnName = (char *)sqlite3_column_name(compiledStatement, i);
                        [self.arrColumnNames addObject:[NSString stringWithUTF8String:columnName]];
                    }
                }
                
                // Store each fetched data row in the results array, but first check if there is actually data.
                if (arrDataRow.count > 0) {
                    [self.arrResults addObject:arrDataRow];
                }
            }
        }
        else {
            // This is the case of an executable query (insert, update, ...).
            
            // Execute the query.
            if(sqlite3_step(compiledStatement) == SQLITE_DONE) {
                // Keep the affected rows.
                self.affectedRows = sqlite3_changes(self.database);
                
                // Keep the last inserted row ID.
                self.lastInsertedRowID = sqlite3_last_insert_rowid(self.database);
            }
            else {
                // If could not execute the query show the error message on the debugger.
                NSLog(@"DB Error: %s", sqlite3_errmsg(self.database));
            }
        }
        
        // Release the compiled statement from memory.
        sqlite3_finalize(compiledStatement);
        
    }
    
}

-(NSArray *)query:(NSString *)query{
    [self runQuery:[query UTF8String] isUpdate:NO];
    return (NSArray *)self.arrResults;
}

-(void)update:(NSString *)query{
    [self runQuery:[query UTF8String] isUpdate:YES];
}

@end
