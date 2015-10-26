//
//  GPKGSqlConnection.m
//  Pods
//
//  Created by Brian Osborn on 10/23/15.
//
//

#import "GPKGSqlConnection.h"

@interface GPKGSqlConnection()

@property (nonatomic, strong) NSNumber * connectionId;
@property (nonatomic) sqlite3 *connection;
@property (nonatomic, strong) GPKGConnectionPool * connectionPool;
@property (nonatomic) BOOL maintainStackTrace;
@property (nonatomic, strong) NSArray<NSString *> * stackTrace;
@property (nonatomic, strong) NSDate * dateCheckedOut;

@end

@implementation GPKGSqlConnection

-(instancetype)initWithId: (int) connectionId andConnection: (sqlite3 *) connection andPool: (GPKGConnectionPool *) connectionPool andStackTrace: (BOOL) stackTrace{
    self = [super init];
    if(self){
        self.connectionId = [NSNumber numberWithInt:connectionId];
        self.connection = connection;
        self.connectionPool = connectionPool;
        self.maintainStackTrace = stackTrace;
    }
    return self;
}


-(NSNumber *) getConnectionId{
    return self.connectionId;
}

-(sqlite3 *) getConnection{
    return self.connection;
}

-(void) releaseConnection{
    [self.connectionPool releaseConnection:self];
}

-(void) checkOut{
    if(self.maintainStackTrace){
        self.stackTrace = [NSThread callStackSymbols];
    }
    self.dateCheckedOut = [NSDate date];
}

-(void) checkIn{
    self.stackTrace = nil;
    self.dateCheckedOut = nil;
}

-(NSArray<NSString *> *) getStackTrace{
    return self.stackTrace;
}

-(NSDate *) getDateCheckedOut{
    return self.dateCheckedOut;
}

@end
