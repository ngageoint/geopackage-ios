//
//  GPKGConnectionPool.m
//  Pods
//
//  Created by Brian Osborn on 10/23/15.
//
//

#import "GPKGConnectionPool.h"
#import "GPKGSqlUtils.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#include <asl.h>

@interface GPKGConnectionPool()

@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSMutableArray *availableConnections;
@property (nonatomic, strong) NSMutableDictionary *usedConnections;
@property (nonatomic) int idCounter;
@property (nonatomic) NSDate * lastConnectionCheck;

@end

@implementation GPKGConnectionPool

// Static default settings
static int openConnectionsPerPool = -1;
static BOOL checkConnections = false;
static int checkConnectionsFrequency = -1;
static int checkConnectionsWarningTime = -1;
static BOOL maintainStackTraces = false;

+(int) getOpenConnectionsPerPool{
    [self initializeDefaults];
    return openConnectionsPerPool;
}

+(void) setOpenConnectionsPerPool: (int) connections{
    [self initializeDefaults];
    openConnectionsPerPool = connections;
    [self logProperties];
}

+(BOOL) getCheckConnections{
    [self initializeDefaults];
    return checkConnections;
}

+(void) setCheckConnections: (BOOL) check{
    [self initializeDefaults];
    checkConnections = check;
    [self logProperties];
}

+(int) getCheckConnectionsFrequency{
    [self initializeDefaults];
    return checkConnectionsFrequency;
}

+(void) setCheckConnectionsFrequency: (int) frequency{
    [self initializeDefaults];
    checkConnectionsFrequency = frequency;
    [self logProperties];
}

+(int) getCheckConnectionsWarningTime{
    [self initializeDefaults];
    return checkConnectionsWarningTime;
}

+(void) setCheckConnectionsWarningTime: (int) time{
    [self initializeDefaults];
    checkConnectionsWarningTime = time;
    [self logProperties];
}

+(BOOL) getMaintainStackTraces{
    [self initializeDefaults];
    return maintainStackTraces;
}

+(void) setMaintainStackTraces: (BOOL) maintain{
    [self initializeDefaults];
    maintainStackTraces = maintain;
    [self logProperties];
}

+(void) initializeDefaults{
    // Initialize static defaults
    if(openConnectionsPerPool == -1){
        openConnectionsPerPool = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_OPEN_CONNECTIONS_PER_POOL] floatValue];
        checkConnections = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS];
        checkConnectionsFrequency = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS_FREQUENCY] floatValue];
        checkConnectionsWarningTime = [[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS_WARNING_TIME] floatValue];
        maintainStackTraces = [GPKGProperties getBoolValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_MAINTAIN_STACK_TRACES];
        
        [self logProperties];
    }
}

+(void) logProperties{
    NSLog(@"Open connections per pool: %d, Check connections: %s%@", openConnectionsPerPool, checkConnections ? "true" : "false",
          !checkConnections ? @"" : [NSString stringWithFormat:@" (frequency: %d, warning time: %d, stack traces: %s)", checkConnectionsFrequency, checkConnectionsWarningTime, maintainStackTraces ? "true" : "false"]);
}

-(instancetype)initWithDatabaseFilename:(NSString *) filename{
    self = [super init];
    if(self){
        
        [GPKGConnectionPool initializeDefaults];
        
        self.filename = filename;
        self.availableConnections = [[NSMutableArray alloc] init];
        self.usedConnections = [[NSMutableDictionary alloc] init];
        self.idCounter = 1;
        self.lastConnectionCheck = [NSDate date];
        asl_add_log_file(NULL, STDERR_FILENO);
        
        // Open a database connection
        GPKGSqlConnection * connection = [self openConnection];
        [connection checkOut];
        [self.availableConnections addObject:connection];
    }
    
    return self;
}

-(void) close{
    @synchronized(self) {
        for(GPKGSqlConnection * connection in self.availableConnections){
            [GPKGSqlUtils closeDatabase:connection];
        }
        [self.availableConnections removeAllObjects];
        for(GPKGSqlConnection * connection in [self.usedConnections allValues]){
            [GPKGSqlUtils closeDatabase:connection];
        }
        [self.usedConnections removeAllObjects];
    }
}

-(GPKGSqlConnection *) getConnection{
    GPKGSqlConnection * connection = nil;
    @synchronized(self) {
        [self checkConnections];
        if(self.availableConnections.count > 0){
            connection = (GPKGSqlConnection *)[self.availableConnections objectAtIndex:0];
            [self.availableConnections removeObjectAtIndex:0];
        }else{
            connection = [self openConnection];
            NSLog(@"Opened a connection to %@, open connections: %lu", self.filename, 1 + (unsigned long)[self connectionCount]);
        }
        [connection checkOut];
        [self.usedConnections setObject:connection forKey:[connection getConnectionId]];
    }
    return connection;
}

-(BOOL) releaseConnection: (GPKGSqlConnection *) connection{
    return [self releaseConnectionWithId:[connection getConnectionId]];
}

-(BOOL) releaseConnectionWithId: (NSNumber *) connectionId{
    BOOL released = false;
    @synchronized(self) {
        GPKGSqlConnection * connection = [self.usedConnections objectForKey:connectionId];
        if(connection != nil){
            [self.usedConnections removeObjectForKey:connectionId];
            released = true;
            if(self.availableConnections.count >= openConnectionsPerPool){
                [GPKGSqlUtils closeDatabase:connection];
                NSLog(@"Closed a connection to %@, open connections: %lu", self.filename, (unsigned long)[self connectionCount]);
            }else{
                [connection checkIn];
                [self.availableConnections addObject:connection];
            }
        }
        [self checkConnections];
    }
    return released;
}

-(GPKGSqlConnection *) openConnection{

    sqlite3 *sqlite3Database;
    int openDatabaseResult = sqlite3_open([self.filename UTF8String], &sqlite3Database);
    if(openDatabaseResult != SQLITE_OK){
        [NSException raise:@"Open Database Failure" format:@"Failed to open database: %@, Error: %s", self.filename, sqlite3_errmsg(sqlite3Database)];
    }
    
    GPKGSqlConnection * connection = [[GPKGSqlConnection alloc] initWithId:self.idCounter++ andConnection:sqlite3Database andPool:self andStackTrace:(checkConnections && maintainStackTraces)];
    
    return connection;
}

-(NSUInteger) connectionCount{
    return self.availableConnections.count + self.usedConnections.count;
}

-(void) checkConnections{

    if(checkConnections && ([self.lastConnectionCheck timeIntervalSinceNow] * -1) >= checkConnectionsFrequency){
        for(GPKGSqlConnection * connection in [self.usedConnections allValues]){
            NSDate * dateCheckedOut = [connection getDateCheckedOut];
            if(dateCheckedOut != nil){
                NSTimeInterval time = [dateCheckedOut timeIntervalSinceNow] * -1;
                if(time >= checkConnectionsWarningTime){
                    NSArray<NSString *> * stackTrace = [connection getStackTrace];
                    NSMutableString * stackTraceMessage = [[NSMutableString alloc] init];
                    if(stackTrace != nil){
                        [stackTraceMessage appendString:@"\n\nConnection Check Out Stack Trace:\n"];
                        for(NSString * step in stackTrace){
                            [stackTraceMessage appendFormat:@"\n\t%@", step];
                        }
                    }
                    NSString * warning = [NSString stringWithFormat:@"Connection %@ to %@ has been checked out for %f seconds. Verify connections are being closed.%@", [connection getConnectionId], self.filename, time, stackTraceMessage];
                    asl_log(NULL, NULL, ASL_LEVEL_WARNING, "%s", [warning UTF8String]);
                }
            }
        }
        self.lastConnectionCheck = [NSDate date];
    }
        
}

@end
