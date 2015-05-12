//
//  GPKGResultSet.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGResultSet.h"

@implementation GPKGResultSet

-(instancetype) initWithStatement:(sqlite3_stmt *) statement andCount: (int) count{
    self = [super init];
    if(self){
        self.statement = statement;
        self.count = count;
    
        int totalColumns = sqlite3_column_count(statement);

        NSMutableArray *statementColumns = [[NSMutableArray alloc] init];
        
        for (int i=0; i<totalColumns; i++){
            char *columnName = (char *)sqlite3_column_name(statement, i);
            [statementColumns addObject:[NSString stringWithUTF8String:columnName]];
        }
        
        self.columns = statementColumns;
    }
    
    return self;
}

-(BOOL) moveToNext{
    return sqlite3_step(self.statement) == SQLITE_ROW;
}

-(void) close{
    sqlite3_finalize(self.statement);
}

-(NSArray *) getRow{
    
    NSMutableArray *rowValues = [[NSMutableArray alloc] init];
    NSUInteger totalColumns = [self.columns count];
    
    for (int i=0; i<totalColumns; i++){
        
        int type = sqlite3_column_type(self.statement, i);
        switch (type) {
            case SQLITE_TEXT:;
                
                // Convert the column data to text (characters).
                char *dbDataAsChars = (char *)sqlite3_column_text(self.statement, i);
                
                // If there are contents in the currenct column (field) then add them to the current row array.
                if (dbDataAsChars != NULL) {
                    // Convert the characters to string.
                    [rowValues addObject:[NSString  stringWithUTF8String:dbDataAsChars]];
                }
                break;
                
            case SQLITE_INTEGER:;
                
                int intValue = sqlite3_column_int(self.statement, i);
                [rowValues addObject:[NSNumber numberWithInt: intValue]];
                
                break;
                
            case SQLITE_FLOAT:;
                
                double floatValue = sqlite3_column_double(self.statement, i);
                [rowValues addObject:[NSNumber numberWithDouble: floatValue]];
                
                break;
                
            case SQLITE_NULL:
                
                [rowValues addObject:nil];
                break;
                
            case SQLITE_BLOB:
                {
                    NSData *blobValue = [[NSData alloc] initWithBytes:sqlite3_column_blob(self.statement, i) length:sqlite3_column_bytes(self.statement,  i)];
                    [rowValues addObject:blobValue];
                }
                break;
                
            default:
                break;
        }

    }
    
    return rowValues;
}

@end
