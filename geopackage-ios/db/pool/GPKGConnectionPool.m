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
@property (nonatomic, strong) NSDate * lastConnectionCheck;
@property (nonatomic, strong) NSMutableDictionary * resultConnections;
@property (nonatomic, strong) GPKGSqliteConnection * writeConnection;

@end

@implementation GPKGConnectionPool

/**
 *  Number of connection to keep open per pool, connections released above this number are closed
 */
static int openConnectionsPerPool = -1;

/**
 *  Flag indicating to check for connections that remain open for long periods of time
 */
static BOOL checkConnections = false;

/**
 *  Frequency in seconds to check for long opened connections
 */
static int checkConnectionsFrequency = -1;

/**
 *  Time in seconds that makes a connection considered as open for a long time
 */
static int checkConnectionsWarningTime = -1;

/**
 *  Flag indicating whether to save the stack trace of the connection checkout caller
 */
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

/**
 *  Initialize the default connection pool settings
 */
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

/**
 *  Log the default connection pool settings
 */
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
        self.resultConnections = [[NSMutableDictionary alloc] init];
        asl_add_log_file(NULL, STDERR_FILENO);
        
        // Open a database connection
        GPKGSqliteConnection * connection = [self openConnection];
        [connection checkOut];
        [self.availableConnections addObject:connection];
    }
    
    return self;
}

-(void) close{
    @synchronized(self) {
        for(GPKGSqliteConnection * connection in self.availableConnections){
            [GPKGSqlUtils closeDatabase:connection];
        }
        [self.availableConnections removeAllObjects];
        for(GPKGSqliteConnection * connection in [self.usedConnections allValues]){
            [GPKGSqlUtils closeDatabase:connection];
        }
        [self.usedConnections removeAllObjects];
    }
}

-(GPKGDbConnection *) getConnection{
    GPKGSqliteConnection * connection = [self getSqliteConnection];
    return [[GPKGDbConnection alloc] initWithConnection:connection andReleasable:true];
}

/**
 *  Get an available connection or open a new one
 *
 *  @return connection
 */
-(GPKGSqliteConnection *) getSqliteConnection{
    GPKGSqliteConnection * connection = nil;
    @synchronized(self) {
        [self checkConnections];
        if(self.availableConnections.count > 0){
            connection = (GPKGSqliteConnection *)[self.availableConnections objectAtIndex:0];
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

-(GPKGDbConnection *) getResultConnection{
    GPKGSqliteConnection * connection = nil;
    @synchronized(self) {
        connection = [self getSqliteConnection];
        [self.resultConnections setObject:connection forKey:[connection getConnectionId]];
    }
    return [[GPKGDbConnection alloc] initWithConnection:connection andReleasable:true];
}

-(GPKGDbConnection *) getWriteConnection{
    BOOL releasable = false;
    GPKGSqliteConnection * connection = nil;
    @synchronized(self) {
        if(self.writeConnection != nil){
            connection = self.writeConnection;
        }else if(self.resultConnections.count > 0){
            if(self.resultConnections.count > 1){
                // Multiple open result connections causes a database locked error when trying to use the connection, regardless of which connection is used
                [NSException raise:@"Connection State Not Writable" format:@"%lu result connections are open, locking the database and preventing writes. A max of one result connection can be open to while updating the database. File: %@",
                 (unsigned long)self.resultConnections.count, self.filename];
            }
            connection = [[self.resultConnections allValues] objectAtIndex:0];
            self.writeConnection = connection;
        }else{
            releasable = true;
            connection = [self getSqliteConnection];
            self.writeConnection = connection;
        }
    }
    return [[GPKGDbConnection alloc] initWithConnection:connection andReleasable:releasable];
}

-(BOOL) releaseConnection: (GPKGDbConnection *) connection{
    BOOL released = false;
    if([connection isReleasable]){
        released = [self releaseConnectionWithId:[connection getConnectionId]];
    }
    return released;
}

-(BOOL) releaseConnectionWithId: (NSNumber *) connectionId{
    BOOL released = false;
    @synchronized(self) {
        GPKGSqliteConnection * connection = [self.usedConnections objectForKey:connectionId];
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
            
            // Check if the write connection
            if(self.writeConnection != nil && [[self.writeConnection getConnectionId] intValue] == [[connection getConnectionId] intValue]){
                self.writeConnection = nil;
            }
            
            // Remove if a result connection
            [self.resultConnections removeObjectForKey:[connection getConnectionId]];
        }
        [self checkConnections];
    }
    return released;
}

/**
 *  Open a new sqlite connection to the database file
 *
 *  @return <#return value description#>
 */
-(GPKGSqliteConnection *) openConnection{

    sqlite3 *sqlite3Database;
    int openDatabaseResult = sqlite3_open([self.filename UTF8String], &sqlite3Database);
    if(openDatabaseResult != SQLITE_OK){
        [NSException raise:@"Open Database Failure" format:@"Failed to open database: %@, Error: %s", self.filename, sqlite3_errmsg(sqlite3Database)];
    }
    
    GPKGSqliteConnection * connection = [[GPKGSqliteConnection alloc] initWithId:self.idCounter++ andConnection:sqlite3Database andPool:self andStackTrace:(checkConnections && maintainStackTraces)];
    
    return connection;
}

-(NSUInteger) connectionCount{
    return self.availableConnections.count + self.usedConnections.count;
}

/**
 *  Check for connections that have been checked out for long periods of time and warn
 */
-(void) checkConnections{

    // If checking connections and time to check
    if(checkConnections && ([self.lastConnectionCheck timeIntervalSinceNow] * -1) >= checkConnectionsFrequency){
        
        // Check each used connection
        for(GPKGSqliteConnection * connection in [self.usedConnections allValues]){
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
