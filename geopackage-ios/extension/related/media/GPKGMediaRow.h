//
//  GPKGMediaRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomRow.h"
#import "GPKGMediaTable.h"

/**
 * User Media Row containing the values from a single result set row
 */
@interface GPKGMediaRow : GPKGUserCustomRow

/**
 *  Initialize
 *
 *  @param table       media table
 *  @param columnTypes column types
 *  @param values      values
 *
 *  @return new media row
 */
-(instancetype) initWithMediaTable: (GPKGMediaTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values;

/**
 *  Initialize
 *
 *  @param table media table
 *
 *  @return new media row
 */
-(instancetype) initWithMediaTable: (GPKGMediaTable *) table;

/**
 *  Initialize
 *
 *  @param userCustomRow user custom row
 *
 *  @return new media row
 */
-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow;

/**
 *  Get the media table
 *
 *  @return media table
 */
-(GPKGMediaTable *) table;

/**
 * Get the id column index
 *
 * @return id column index
 */
-(int) idColumnIndex;

/**
 * Get the id column
 *
 * @return id column
 */
-(GPKGUserCustomColumn *) idColumn;

/**
 * Get the id
 *
 * @return id
 */
-(int) id;

/**
 * Get the data column index
 *
 * @return data column index
 */
-(int) dataColumnIndex;

/**
 * Get the data column
 *
 * @return data column
 */
-(GPKGUserCustomColumn *) dataColumn;

/**
 * Get the data
 *
 * @return data
 */
-(NSData *) data;

/**
 * Set the data
 *
 * @param data
 *            data
 */
-(void) setData: (NSData *) data;

/**
 * Get the content type column index
 *
 * @return content type column index
 */
-(int) contentTypeColumnIndex;

/**
 * Get the content type column
 *
 * @return content type column
 */
-(GPKGUserCustomColumn *) contentTypeColumn;

/**
 * Get the content type
 *
 * @return content type
 */
-(NSString *) contentType;

/**
 * Set the content type
 *
 * @param contentType
 *            content type
 */
-(void) setContentType: (NSString *) contentType;

@end
