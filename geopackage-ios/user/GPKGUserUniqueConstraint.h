//
//  GPKGUserUniqueConstraint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"

/**
 *  User table unique constraint for one or more columns
 */
@interface GPKGUserUniqueConstraint : NSObject

/**
 *  Columns included in the unique constraint
 */
@property (nonatomic, strong) NSMutableArray *columns;

/**
 *  Initialize
 *
 *  @return new unique constraint
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param columns columns
 *
 *  @return new unique constraint
 */
-(instancetype) initWithColumns: (NSMutableArray *) columns;

/**
 *  Add a column
 *
 *  @param column column
 */
-(void) add: (GPKGUserColumn *)column;

@end
