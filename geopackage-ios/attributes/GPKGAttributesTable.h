//
//  GPKGAttributesTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGContents.h"

@interface GPKGAttributesTable : GPKGUserTable

/**
 *  Foreign key to Contents
 */
@property (nonatomic, strong) GPKGContents *contents;

/**
 *  Initialize
 *
 *  @param tableName table name
 *  @param columns   attributes columns
 *
 *  @return new attributes table
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

/**
 *  Set the contents
 *
 *  @param contents   contents
 */
-(void) setContents:(GPKGContents *)contents;

@end
