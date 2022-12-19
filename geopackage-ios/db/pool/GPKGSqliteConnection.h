//
//  GPKGSqliteConnection.h
//  Pods
//
//  Created by Brian Osborn on 10/23/15.
//
//

#import <sqlite3.h>
#import "GPKGConnectionPool.h"

/**
 *  Single sqlite3 connection to a database file opened as part of a connection pool
 */
@interface GPKGSqliteConnection : NSObject

/**
 *  Reusable connection flag
 */
@property (nonatomic) BOOL reusable;

/**
 *  Initialize
 *
 *  @param connectionId   connection id
 *  @param connection     sqlite connection
 *  @param connectionPool connection pool
 *  @param stackTrace     true to maintain stack traces of thread owner
 *
 *  @return new sql connection
 */
-(instancetype)initWithId: (int) connectionId andConnection: (sqlite3 *) connection andPool: (GPKGConnectionPool *) connectionPool andStackTrace: (BOOL) stackTrace;

/**
 *  Get the connection id
 *
 *  @return connection id
 */
-(NSNumber *) connectionId;

/**
 *  Get the connection
 *
 *  @return connection
 */
-(sqlite3 *) connection;

/**
 *  Release the connection back to the connection pool
 */
-(void) releaseConnection;

/**
 *  Update the check out attributes using the current thread as the new owner
 */
-(void) checkOut;

/**
 *  Clear the check out features upon check in
 */
-(void) checkIn;

/**
 *  Get the stack trace of when the owning thread checked out the connection.
 *
 *  @return stack trace, nil when not checked out or not maintaining stack traces
 */
-(NSArray *) stackTrace;

/**
 *  Get the date this connection was checked out
 *
 *  @return date of checkout, nil if not checked out
 */
-(NSDate *) dateCheckedOut;

/**
 *  Determine if this connection is releasable
 *
 *  @return true if releasable
 */
-(BOOL) isReleasable;

@end
