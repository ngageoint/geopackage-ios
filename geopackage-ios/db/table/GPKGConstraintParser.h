//
//  GPKGConstraintParser.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGConstraintParser : NSObject

// TODO

/**
 * Get the constraints for the table SQL
 *
 * @param tableSql
 *            table SQL
 * @return constraints
 */
+(GPKGTableConstraints *) constraintsForSQL: (NSString *) tableSql;

@end
