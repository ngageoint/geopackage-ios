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
@property (nonatomic, strong) NSDate *lastConnectionCheck;
@property (nonatomic, strong) NSMutableDictionary *resultConnections;
@property (nonatomic, strong) GPKGDbConnection *writableConnection;
@property (nonatomic) BOOL inTransaction;
@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGConnectionFunction *> *writeFunctions;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *connectionExecs;

@end

@implementation GPKGConnectionPool

/**
 *  Number of connection to keep open per pool, connections released above this number are closed
 */
static int openConnectionsPerPool = -1;

/**
 *  Flag indicating to check for connections that remain open for long periods of time
 */
static BOOL checkConnections = NO;

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
static BOOL maintainStackTraces = NO;

+(int) openConnectionsPerPool{
    [self initializeDefaults];
    return openConnectionsPerPool;
}

+(void) setOpenConnectionsPerPool: (int) connections{
    [self initializeDefaults];
    openConnectionsPerPool = connections;
    [self logProperties];
}

+(BOOL) checkConnections{
    [self initializeDefaults];
    return checkConnections;
}

+(void) setCheckConnections: (BOOL) check{
    [self initializeDefaults];
    checkConnections = check;
    [self logProperties];
}

+(int) checkConnectionsFrequency{
    [self initializeDefaults];
    return checkConnectionsFrequency;
}

+(void) setCheckConnectionsFrequency: (int) frequency{
    [self initializeDefaults];
    checkConnectionsFrequency = frequency;
    [self logProperties];
}

+(int) checkConnectionsWarningTime{
    [self initializeDefaults];
    return checkConnectionsWarningTime;
}

+(void) setCheckConnectionsWarningTime: (int) time{
    [self initializeDefaults];
    checkConnectionsWarningTime = time;
    [self logProperties];
}

+(BOOL) maintainStackTraces{
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
        openConnectionsPerPool = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_OPEN_CONNECTIONS_PER_POOL] floatValue];
        checkConnections = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS];
        checkConnectionsFrequency = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS_FREQUENCY] floatValue];
        checkConnectionsWarningTime = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_CHECK_CONNECTIONS_WARNING_TIME] floatValue];
        maintainStackTraces = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_CONNECTION_POOL andProperty:GPKG_PROP_CONNECTION_POOL_MAINTAIN_STACK_TRACES];
        
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
        self.availableConnections = [NSMutableArray array];
        self.usedConnections = [NSMutableDictionary dictionary];
        self.idCounter = 1;
        self.lastConnectionCheck = [NSDate date];
        self.resultConnections = [NSMutableDictionary dictionary];
        self.inTransaction = NO;
        self.writeFunctions = [NSMutableDictionary dictionary];
        self.connectionExecs = [NSMutableDictionary dictionary];
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
        [self.resultConnections removeAllObjects];
        self.inTransaction = NO;
        [self.writeFunctions removeAllObjects];
        [self.connectionExecs removeAllObjects];
    }
}

-(GPKGDbConnection *) connection{
    GPKGDbConnection * connection = nil;
    @synchronized(self) {
         if(self.writableConnection != nil){
             connection = [[GPKGDbConnection alloc] initWithDbConnection:self.writableConnection andReleasable:NO];
         }else{
             GPKGSqliteConnection * sqlConnection = [self sqliteConnection];
             connection =  [[GPKGDbConnection alloc] initWithConnection:sqlConnection andReleasable:YES];
         }
    }
    return connection;
}

/**
 *  Get an available connection or open a new one
 *
 *  @return connection
 */
-(GPKGSqliteConnection *) sqliteConnection{
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
        [self.usedConnections setObject:connection forKey:[connection connectionId]];
    }
    return connection;
}

-(GPKGDbConnection *) resultConnection{
    GPKGDbConnection * connection = nil;
    @synchronized(self) {
        if(self.writableConnection != nil){
            connection = [[GPKGDbConnection alloc] initWithDbConnection:self.writableConnection andReleasable:NO];
        }else{
            GPKGSqliteConnection * sqlConnection = [self sqliteConnection];
            [self createWriteFunctionsOnConnection:sqlConnection];
            [self.resultConnections setObject:sqlConnection forKey:[sqlConnection connectionId]];
            connection = [[GPKGDbConnection alloc] initWithConnection:sqlConnection andReleasable:YES];
        }
    }
    return connection;
}

-(GPKGDbConnection *) writeConnection{
    GPKGDbConnection * connection = nil;
    @synchronized(self) {
        if(self.writableConnection != nil){
            connection = [[GPKGDbConnection alloc] initWithDbConnection:self.writableConnection andReleasable:NO];
        } else{
            GPKGSqliteConnection * sqlConnection = nil;
            if(self.resultConnections.count > 0){
                if(self.resultConnections.count > 1){
                    // Multiple open result connections causes a database locked error when trying to use the connection, regardless of which connection is used
                    [NSException raise:@"Connection State Not Writable" format:@"%lu result connections are open, locking the database and preventing writes. A max of one result connection can be open to while updating the database. File: %@",
                     (unsigned long)self.resultConnections.count, self.filename];
                }
                sqlConnection = [[self.resultConnections allValues] objectAtIndex:0];
                connection = [[GPKGDbConnection alloc] initWithConnection:sqlConnection andReleasable:NO andWriteReleasable:YES];
            }else{
                sqlConnection = [self sqliteConnection];
                [self createWriteFunctionsOnConnection:sqlConnection];
                connection = [[GPKGDbConnection alloc] initWithConnection:sqlConnection andReleasable:YES];
            }
            self.writableConnection = connection;
        }
    }
    return connection;
}

-(void) beginTransaction{
    [self beginTransactionAsResettable:NO];
}

-(void) beginResettableTransaction{
    [self beginTransactionAsResettable:YES];
}

-(void) beginTransactionAsResettable: (BOOL) resettable{
    @synchronized(self) {
        if(self.writableConnection != nil){
            [NSException raise:@"Begin Transaction Failure" format:@"Can not begin a transaction while write connection is already open on database: %@", self.filename];
        }
        GPKGDbConnection * connection = [self writeConnection];
        int result = sqlite3_exec([connection connection], "BEGIN EXCLUSIVE TRANSACTION", 0, 0, 0);
        if(result != SQLITE_OK){
            [NSException raise:@"Begin Transaction Failure" format:@"Failed to begin exclusive transaction on database: %@, Error: %s", self.filename, sqlite3_errmsg([connection connection])];
        }
        [connection setResettable:resettable];
        self.inTransaction = YES;
    }
}

-(void) commitTransaction{
    @synchronized(self) {
        GPKGDbConnection * connection = self.writableConnection;
        if(connection == nil){
            [NSException raise:@"No Active Transaction" format:@"No transaction is active to commit on database: %@", self.filename];
        }
        int result = sqlite3_exec([connection connection], "COMMIT TRANSACTION", 0, 0, 0);
        [self releaseConnection:connection];
        self.inTransaction = NO;
        if(result != SQLITE_OK){
            [NSException raise:@"Commit Transaction Failure" format:@"Failed to commit transaction on database: %@, Error: %s", self.filename, sqlite3_errmsg([connection connection])];
        }
    }
}

-(void) rollbackTransaction{
    @synchronized(self) {
        GPKGDbConnection * connection = self.writableConnection;
        if(connection == nil){
            [NSException raise:@"No Active Transaction" format:@"No transaction is active to rollback on database: %@", self.filename];
        }
        int result = sqlite3_exec([self.writableConnection connection], "ROLLBACK TRANSACTION", 0, 0, 0);
        [self releaseConnection:connection];
        self.inTransaction = NO;
        if(result != SQLITE_OK){
            [NSException raise:@"Rollback Transaction Failure" format:@"Failed to rollback transaction on database: %@, Error: %s", self.filename, sqlite3_errmsg([self.writableConnection connection])];
        }
    }
}

-(BOOL) inTransaction{
    return _inTransaction;
}

-(BOOL) releaseConnection: (GPKGDbConnection *) connection{
    BOOL released = NO;
    if([connection isReleasable]){
        released = [self releaseConnectionWithId:[connection connectionId]];
    } else {
        [self releaseWriteConnection:connection];
    }
    return released;
}

-(BOOL) releaseConnectionWithId: (NSNumber *) connectionId{
    BOOL released = NO;
    @synchronized(self) {
        GPKGSqliteConnection * connection = [self.usedConnections objectForKey:connectionId];
        if(connection != nil){
            [self.usedConnections removeObjectForKey:connectionId];
            released = YES;
            
            BOOL close = !connection.reusable || self.availableConnections.count >= openConnectionsPerPool;
            
            if(close){
                [GPKGSqlUtils closeDatabase:connection];
                NSLog(@"Closed a connection to %@, open connections: %lu", self.filename, (unsigned long)[self connectionCount]);
            }
            
            // Release write connections
            [self releaseWriteConnectionWithId:connectionId];
            
            // Remove if a result connection
            [self.resultConnections removeObjectForKey:connectionId];
            
            if(!close){
                [connection checkIn];
                [self.availableConnections addObject:connection];
            }
            
        }
        [self checkConnections];
    }
    return released;
}

-(BOOL) releaseWriteConnection: (GPKGDbConnection *) connection{
    BOOL writeReleased = NO;
    if([connection isWriteReleasable]){
        writeReleased = [self releaseWriteConnectionWithId:[connection connectionId]];
    }
    return writeReleased;
}

-(BOOL) releaseWriteConnectionWithId: (NSNumber *) connectionId{
    BOOL writeReleased = NO;
    @synchronized(self) {
        
        // Check if the write connection
        if(self.writableConnection != nil && [[self.writableConnection connectionId] isEqualToNumber:connectionId]){
            
            // If a resettable connection, close available connections and mark used connections as not reusable
            if(self.writableConnection.resettable){
                for(GPKGSqliteConnection *connection in self.availableConnections){
                    [GPKGSqlUtils closeDatabase:connection];
                }
                [self.availableConnections removeAllObjects];
                for(GPKGSqliteConnection *connection in [self.usedConnections allValues]){
                    if(![[connection connectionId] isEqualToNumber:connectionId]){
                        connection.reusable = NO;
                    }
                }
                [self.writableConnection setResettable:NO];
            }
            
            // Clear the write connection
            self.writableConnection = nil;
            writeReleased = YES;
            
        }
    }
    return writeReleased;
}

/**
 *  Open a new sqlite connection to the database file
 *
 *  @return sqlite connection
 */
-(GPKGSqliteConnection *) openConnection{

    sqlite3 *sqlite3Database;
    int openDatabaseResult = sqlite3_open([self.filename UTF8String], &sqlite3Database);
    if(openDatabaseResult != SQLITE_OK){
        [NSException raise:@"Open Database Failure" format:@"Failed to open database: %@, Error: %s", self.filename, sqlite3_errmsg(sqlite3Database)];
    }
    
    GPKGSqliteConnection * connection = [[GPKGSqliteConnection alloc] initWithId:self.idCounter++ andConnection:sqlite3Database andPool:self andStackTrace:(checkConnections && maintainStackTraces)];
    for(NSString *exec in [self.connectionExecs allValues]){
        [GPKGSqlUtils execWithSQLiteConnection:connection andStatement:exec];
    }
    
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
            NSDate * dateCheckedOut = [connection dateCheckedOut];
            if(dateCheckedOut != nil){
                NSTimeInterval time = [dateCheckedOut timeIntervalSinceNow] * -1;
                if(time >= checkConnectionsWarningTime){
                    NSArray<NSString *> * stackTrace = [connection stackTrace];
                    NSMutableString * stackTraceMessage = [NSMutableString string];
                    if(stackTrace != nil){
                        [stackTraceMessage appendString:@"\n\nConnection Check Out Stack Trace:\n"];
                        for(NSString * step in stackTrace){
                            [stackTraceMessage appendFormat:@"\n\t%@", step];
                        }
                    }
                    NSString * warning = [NSString stringWithFormat:@"Connection %@ to %@ has been checked out for %f seconds. Verify connections are being closed.%@", [connection connectionId], self.filename, time, stackTraceMessage];
                    asl_log(NULL, NULL, ASL_LEVEL_WARNING, "%s", [warning UTF8String]);
                }
            }
        }
        self.lastConnectionCheck = [NSDate date];
    }
        
}

-(void) addWriteFunction: (GPKGConnectionFunction *) function{
    [self addWriteFunctions:[NSArray arrayWithObject:function]];
}

-(void) addWriteFunctions: (NSArray<GPKGConnectionFunction *> *) functions{
    @synchronized(self) {
        for(GPKGConnectionFunction *function in functions){
            [self.writeFunctions setObject:function forKey:[function name]];
        }
        for(GPKGSqliteConnection *connection in self.availableConnections){
            [self createWriteFunctionsOnConnection:connection];
        }
        for(GPKGSqliteConnection * connection in [self.usedConnections allValues]){
            connection.reusable = NO;
        }
    }
}

/**
 *  Create the write functions on the connection
 *
 *  @param connection sqlite connection
 */
-(void) createWriteFunctionsOnConnection: (GPKGSqliteConnection *) connection{
    for(GPKGConnectionFunction *function in [self.writeFunctions allValues]){
        [self createFunction:function onConnection:connection];
    }
}

/**
 *  Create the write function on the connection
 *
 *  @param function connection function
 *  @param connection sqlite connection
 */
-(void) createFunction: (GPKGConnectionFunction *) function onConnection: (GPKGSqliteConnection *) connection{

    int result = sqlite3_create_function([connection connection], [[function name] cStringUsingEncoding:NSUTF8StringEncoding], [function numArgs], SQLITE_ANY, NULL, [function function], NULL, NULL);
    if(result != SQLITE_OK){
        NSLog(@"Failed to create SQL function: %@, SQLITE Error Code: %d", [function name], result);
    }
    
}

-(void) execAllConnectionStatement: (NSString *) statement{
    [self execPersistentAllConnectionStatement:statement asName:nil];
}

-(void) execPersistentAllConnectionStatement: (NSString *) statement asName: (NSString *) name{
    @synchronized(self) {
        if(name != nil){
            [self.connectionExecs setObject:statement forKey:name];
        }
        for(GPKGSqliteConnection *connection in self.availableConnections){
            [GPKGSqlUtils execWithSQLiteConnection:connection andStatement:statement];
        }
        for(GPKGSqliteConnection * connection in [self.usedConnections allValues]){
            connection.reusable = NO;
        }
    }
}

-(NSString *) removePersistentAllConnectionStatementWithName: (NSString *) name{
    NSString *statement = nil;
    @synchronized(self) {
        statement = [self.connectionExecs objectForKey:name];
        if(statement != nil){
            [self.connectionExecs removeObjectForKey:name];
        }
    }
    return statement;
}

-(int) clearPersistentStatements{
    int count = 0;
    @synchronized(self) {
        count = (int) self.connectionExecs.count;
        [self.connectionExecs removeAllObjects];
    }
    return count;
}

@end
