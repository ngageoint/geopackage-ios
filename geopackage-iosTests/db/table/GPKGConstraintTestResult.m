//
//  GPKGConstraintTestResult.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraintTestResult.h"

@implementation GPKGConstraintTestResult

-(instancetype) initWithTableConstraints: (GPKGTableConstraints *) constraints andPrimaryKeyCount: (int) primaryKeyCount andUniqueCount: (int) uniqueCount andCheckCount: (int) checkCount andForeignKeyCount: (int) foreignKeyCount{
    self = [super init];
    if(self != nil){
        self.constraints = constraints;
        self.primaryKeyCount = primaryKeyCount;
        self.uniqueCount = uniqueCount;
        self.checkCount = checkCount;
        self.foreignKeyCount = foreignKeyCount;
    }
    return self;
}

-(int) count{
    return [self.constraints numTableConstraints];
}

@end
