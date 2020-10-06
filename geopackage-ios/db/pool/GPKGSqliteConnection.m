//
//  GPKGSqliteConnection.m
//  Pods
//
//  Created by Brian Osborn on 10/23/15.
//
//

#import "GPKGSqliteConnection.h"

@interface GPKGSqliteConnection()

@property (nonatomic, strong) NSNumber * connectionId;
@property (nonatomic) sqlite3 *connection;
@property (nonatomic, strong) GPKGConnectionPool * connectionPool;
@property (nonatomic) BOOL maintainStackTrace;
@property (nonatomic, strong) NSArray<NSString *> * stackTrace;
@property (nonatomic, strong) NSDate * dateCheckedOut;

@end

@implementation GPKGSqliteConnection

-(instancetype)initWithId: (int) connectionId andConnection: (sqlite3 *) connection andPool: (GPKGConnectionPool *) connectionPool andStackTrace: (BOOL) stackTrace{
    self = [super init];
    if(self){
        self.reusable = YES;
        self.connectionId = [NSNumber numberWithInt:connectionId];
        self.connection = connection;
        self.connectionPool = connectionPool;
        self.maintainStackTrace = stackTrace;
    }
    return self;
}


-(NSNumber *) connectionId{
    return _connectionId;
}

-(sqlite3 *) connection{
    return _connection;
}

-(void) releaseConnection{
    [self.connectionPool releaseConnectionWithId:[self connectionId]];
}

-(void) checkOut{
    if(self.maintainStackTrace){
        self.stackTrace = [NSThread callStackSymbols];
    }
    self.dateCheckedOut = [NSDate date];
}

-(void) checkIn{
    _stackTrace = nil;
    _dateCheckedOut = nil;
}

-(NSArray<NSString *> *) stackTrace{
    return _stackTrace;
}

-(NSDate *) dateCheckedOut{
    return _dateCheckedOut;
}

-(BOOL) isReleasable{
    return YES;
}

@end
