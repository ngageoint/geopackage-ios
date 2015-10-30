//
//  GPKGConnectionPool.h
//  Pods
//
//  Created by Brian Osborn on 10/23/15.
//
//

#import <Foundation/Foundation.h>
#import "GPKGDbConnection.h"

@class GPKGDbConnection;

/**
 *  Connection pool to manage retrieving a sqlite3 connection to a database file. Connections should be released after the database operation has completed.
 *  Opens connections as needed and keeps a configured amount of connections open for us.
 */
@interface GPKGConnectionPool : NSObject

/**
 *  Get the number of unused connections to keep open and available for use
 *
 *  @return open connection per pool
 */
+(int) getOpenConnectionsPerPool;

/**
 *  Set the number of unused connections to keep open and available for use
 *
 *  @param connections open connection per pool
 */
+(void) setOpenConnectionsPerPool: (int) connections;

/**
 *  Get the check connections state, when true used connections are checked to see if they are left open for long periods of time or indefinitly
 *
 *  @return check connections flag
 */
+(BOOL) getCheckConnections;

/**
 *  Set the check connections state, when true used connections are checked to see if they are left open for long periods of time or indefinitly
 *
 *  @param check check connections flag
 */
+(void) setCheckConnections: (BOOL) check;

/**
 *  Get the check connections frequency in seconds as the minimum time to wait before checking for stale open connections
 *
 *  @return check frequency in seconds
 */
+(int) getCheckConnectionsFrequency;

/**
 *  Set the check connections frequency in seconds as the minimum time to wait before checking for stale open connections
 *
 *  @param frequency check frequency in seconds
 */
+(void) setCheckConnectionsFrequency: (int) frequency;

/**
 *  Get the check connections warning time in seconds as the time an open connection causes warnings for being stale
 *
 *  @return warning time in seconds
 */
+(int) getCheckConnectionsWarningTime;

/**
 *  Set the check connections warning time in seconds as the time an open connection causes warnings for being stale
 *
 *  @param time warning time in seconds
 */
+(void) setCheckConnectionsWarningTime: (int) time;

/**
 *  Get the maintain statck traces state, when check connections is enabled and when true, stack traces are maintained from the thread that checks out a connection
 *
 *  @return maintain stack traces flag
 */
+(BOOL) getMaintainStackTraces;

/**
 *  Set the maintain statck traces state, when check connections is enabled and when true, stack traces are maintained from the thread that checks out a connection
 *
 *  @param maintain maintain stack traces flag
 */
+(void) setMaintainStackTraces: (BOOL) maintain;

/**
 *  Initialize
 *
 *  @param filename GeoPackage filename
 *
 *  @return new connection
 */
-(instancetype)initWithDatabaseFilename:(NSString *) filename;

/**
 *  Close the connection pool, closing all connections
 */
-(void) close;

/**
 *  Get a connection for single database reads (do not maintain open result sets), such as counts. The connection must be released when done.
 *
 *  @return connection
 */
-(GPKGDbConnection *) getConnection;

/**
 *  Get a connection for database reads that maintain open result sets, such as row queries. The connection must be released when done.
 *
 *  @return connection for result sets
 */
-(GPKGDbConnection *) getResultConnection;

/**
 *  Get a connection for database updates. The connection must be released when done.
 *
 *  @return connection for writing
 */
-(GPKGDbConnection *) getWriteConnection;

/**
 *  Release a connection, either adding it back to available pool connections or closing it
 *
 *  @param connection connection
 *
 *  @return true if released
 */
-(BOOL) releaseConnection: (GPKGDbConnection *) connection;

/**
 *  Release a connection by id, either adding it back to available pool connections or closing it
 *
 *  @param connectionId connection id
 *
 *  @return true if released
 */
-(BOOL) releaseConnectionWithId: (NSNumber *) connectionId;

/**
 *  Total connection count of open available and used connections
 *
 *  @return connection count
 */
-(NSUInteger) connectionCount;

@end
