//
//  GPKGUserRowSync.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/20/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGUserRow.h"

/**
 * User Row Sync to support sharing a single user row read copy when multiple
 * near simultaneous asynchronous requests are made
 */
@interface GPKGUserRowSync : NSObject

/**
 *  Initialize
 *
 *  @return new user row sync
 */
-(instancetype) init;

/**
 * Get the row if another same id request has been made by waiting until the
 * row has been set. If no current request, lock the for the calling thread
 * which should read the row and call "setRow: (GPKGUserRow *) row withId: (int) id"
 * when complete.
 *
 * @param id
 *            user row id
 * @return row if retrieved from a previous request, null if calling thread
 *         should read row and set using "setRow: (GPKGUserRow *) row withId: (int) id"
 */
-(GPKGUserRow *) rowOrLockId: (int) id;

/**
 * Get the row if another same id number request has been made by waiting until the
 * row has been set. If no current request, lock the for the calling thread
 * which should read the row and call "setRow: (GPKGUserRow *) row withNumber: (NSNumber *) id"
 * when complete.
 *
 * @param id
 *            user row id
 * @return row if retrieved from a previous request, null if calling thread
 *         should read row and set using "setRow: (GPKGUserRow *) row withNumber: (NSNumber *) id"
 */
-(GPKGUserRow *) rowOrLockNumber: (NSNumber *) id;

/**
 * Set the row, row id, and notify all waiting threads to retrieve the row.
 *
 * @param row
 *            user row or null
 * @param id
 *            user row id
 */
-(void) setRow: (GPKGUserRow *) row withId: (int) id;

/**
 * Set the row, row id number, and notify all waiting threads to retrieve the row.
 *
 * @param row
 *            user row or null
 * @param id
 *            user row number id
 */
-(void) setRow: (GPKGUserRow *) row withNumber: (NSNumber *) id;

@end
