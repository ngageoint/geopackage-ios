//
//  GPKGDbConnection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/26/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGSqliteConnection.h"

@class GPKGSqliteConnection;

/**
 *  Single database connection to a database file opened as part of a connection pool.  Wraps a sqlite3 connection.
 */
@interface GPKGDbConnection : NSObject

/**
 *  Initialize
 *
 *  @param connection sql connection
 *  @param releasable true if a releasable version of the connection
 *
 *  @return db connection
 */
-(instancetype)initWithConnection:(GPKGSqliteConnection *) connection andReleasable: (BOOL) releasable;

/**
 *  Initialize
 *
 *  @param connection      sql connection
 *  @param releasable      true if a releasable version of the connection
 *  @param writeReleasable true if writable lock is releasable, regardless of it releasable
 *
 *  @return db connection
 */
-(instancetype)initWithConnection:(GPKGSqliteConnection *) connection andReleasable: (BOOL) releasable andWriteReleasable: (BOOL) writeReleasable;

/**
 *  Initialize
 *
 *  @param connection      db connection
 *  @param releasable true if a releasable version of the connection
 *
 *  @return db connection
 */
-(instancetype)initWithDbConnection:(GPKGDbConnection *) connection andReleasable: (BOOL) releasable;

/**
 *  Initialize
 *
 *  @param connection      db connection
 *  @param releasable      true if a releasable version of the connection
 *  @param writeReleasable true if writable lock is releasable, regardless of it releasable
 *
 *  @return db connection
 */
-(instancetype)initWithDbConnection:(GPKGDbConnection *) connection andReleasable: (BOOL) releasable andWriteReleasable: (BOOL) writeReleasable;

/**
 *  Get the connection id
 *
 *  @return connection id
 */
-(NSNumber *) getConnectionId;

/**
 *  Get the connection
 *
 *  @return connection
 */
-(sqlite3 *) getConnection;

/**
 *  Release the connection back to the connection pool. If not releasable, does nothing.
 */
-(void) releaseConnection;

/**
 *  Get the stack trace of when the owning thread checked out the connection.
 *
 *  @return stack trace, nil when not checked out or not maintaining stack traces
 */
-(NSArray *) getStackTrace;

/**
 *  Get the date this connection was checked out
 *
 *  @return date of checkout, nil if not checked out
 */
-(NSDate *) getDateCheckedOut;

/**
 *  Determine if this connection is releasable. An instance of a connection is releasable when it is the instance 
 first retrieved for an operation, and not a reference to an active result or write connection.
 *
 *  @return true if releasable
 */
-(BOOL) isReleasable;

/**
 *  Determine if write access is releasable. This is always true when also releasable. This may be true when not releasable
 *  if another connection has the releasable lock but this connection has the write lock.
 *
 *  @return true if write releasable
 */
-(BOOL) isWriteReleasable;

@end
