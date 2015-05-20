//
//  GPKGUserUniqueConstraint.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"

@interface GPKGUserUniqueConstraint : NSObject

@property (nonatomic, strong) NSMutableArray *columns;

-(instancetype) init;

-(instancetype) initWithColumns: (NSMutableArray *) columns;

-(void) add: (GPKGUserColumn *)column;

@end
