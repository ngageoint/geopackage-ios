//
//  GPKGConstraintTestResult.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTableConstraints.h"

/**
 * Constraint test result
 */
@interface GPKGConstraintTestResult : NSObject

@property (nonatomic, strong) GPKGTableConstraints *constraints;
@property (nonatomic) int primaryKeyCount;
@property (nonatomic) int uniqueCount;
@property (nonatomic) int checkCount;
@property (nonatomic) int foreignKeyCount;

-(instancetype) initWithTableConstraints: (GPKGTableConstraints *) constraints andPrimaryKeyCount: (int) primaryKeyCount andUniqueCount: (int) uniqueCount andCheckCount: (int) checkCount andForeignKeyCount: (int) foreignKeyCount;

-(int) count;

@end
