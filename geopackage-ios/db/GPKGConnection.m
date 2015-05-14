//
//  GPKGConnection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/7/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGConnection.h"
#import <sqlite3.h>
#import "GPKGSqlLiteQueryBuilder.h"
#import "GPKGSqlUtils.h"

@interface GPKGConnection()

@property (nonatomic) sqlite3 *database;

@end

@implementation GPKGConnection

-(instancetype)initWithDatabaseFilename:(NSString *) filename{
    self = [super init];
    if(self){
        self.filename = filename;
        self.name = [[filename lastPathComponent] stringByDeletingPathExtension];
        
        // Open the database.
        NSString *databasePath  = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.filename];
        sqlite3 *sqlite3Database;
        BOOL openDatabaseResult = sqlite3_open([databasePath UTF8String], &sqlite3Database);
        if(openDatabaseResult != SQLITE_OK){
            // In the database cannot be opened then show the error message on the debugger.
            NSLog(@"%s", sqlite3_errmsg(self.database));
        }else{
            self.database = sqlite3Database;
        }
    }

    return self;
}

-(void)close{
    [GPKGSqlUtils closeDatabase:self.database];
}

-(GPKGResultSet *) rawQuery:(NSString *) statement{
    return [GPKGSqlUtils queryWithDatabase:self.database andStatement:statement];
}

-(GPKGResultSet *) queryWithTable: (NSString *) table
                  andColumns: (NSArray *) columns
                    andWhere: (NSString *) where
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                  andOrderBy: (NSString *) orderBy{
    return [self queryWithTable:table
                     andColumns:columns
                       andWhere:where
                     andGroupBy:groupBy
                      andHaving:having
                     andOrderBy:orderBy
                       andLimit:nil];
}

-(GPKGResultSet *) queryWithTable: (NSString *) table
                          andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    
    NSString * query = [GPKGSqlLiteQueryBuilder buildQueryWithDistinct:false
                                                             andTables:table
                                                            andColumns:columns
                                                              andWhere:where
                                                            andGroupBy:groupBy
                                                             andHaving:having
                                                            andOrderBy:orderBy
                                                              andLimit:limit];
    GPKGResultSet *resultSet = [self rawQuery:query];
    return resultSet;
}

-(int) count:(NSString *) statement{
    return [GPKGSqlUtils countWithDatabase:self.database andStatement:statement];
}

-(int) countWithTable: (NSString *) table andWhere: (NSString *) where{
    return [GPKGSqlUtils countWithDatabase:self.database andTable:table andWhere:where];
}

-(long long) insert:(NSString *) statement{
    return [GPKGSqlUtils insertWithDatabase:self.database andStatement:statement];
}

-(int) update:(NSString *) statement{
    return [GPKGSqlUtils updateWithDatabase:self.database andStatement:statement];
}

-(int) delete:(NSString *) statement{
    return [GPKGSqlUtils deleteWithDatabase:self.database andStatement:statement];
}

-(void) exec:(NSString *) statement{
    [GPKGSqlUtils execWithDatabase:self.database andStatement:statement];
}

@end
