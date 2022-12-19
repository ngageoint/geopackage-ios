//
//  GPKGDublinCoreMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGDublinCoreTypes.h"
#import "GPKGUserRow.h"

/**
 * Dublin Core Metadata Initiative
 */
@interface GPKGDublinCoreMetadata : NSObject

/**
 * Check if the table has a column for the Dublin Core Type term
 *
 * @param type
 *            Dublin Core Type
 * @param table
 *            user table
 * @return true if has column
 */
+(BOOL) hasColumn: (enum GPKGDublinCoreType) type inTable: (GPKGUserTable *) table;

/**
 * Check if the row has a column for the Dublin Core Type term
 *
 * @param type
 *            Dublin Core Type
 * @param row
 *            user row
 * @return true if has column
 */
+(BOOL) hasColumn: (enum GPKGDublinCoreType) type inRow: (GPKGUserRow *) row;

/**
 * Get the column from the table for the Dublin Core Type term
 *
 * @param type
 *            Dublin Core Type
 * @param table
 *            user table
 * @return column
 */
+(GPKGUserColumn *) column: (enum GPKGDublinCoreType) type fromTable: (GPKGUserTable *) table;

/**
 * Get the column from the row for the Dublin Core Type term
 *
 * @param type
 *            Dublin Core Type
 * @param row
 *            user row
 * @return column
 */
+(GPKGUserColumn *) column: (enum GPKGDublinCoreType) type fromRow: (GPKGUserRow *) row;

/**
 * Get the value from the row for the Dublin Core Type term
 *
 * @param type
 *            Dublin Core Type
 * @param row
 *            user row
 * @return value
 */
+(NSObject *) value: (enum GPKGDublinCoreType) type fromRow: (GPKGUserRow *) row;

/**
 * Set the value in the row for the Dublin Core Type term
 *
 * @param value
 *            value
 * @param type
 *            Dublin Core Type
 * @param row
 *            user row
 */
+(void) setValue: (NSObject *) value asColumn: (enum GPKGDublinCoreType) type inRow: (GPKGUserRow *) row;

@end
