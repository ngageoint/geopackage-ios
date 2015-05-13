//
//  GPKGConnection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/7/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGResultSet.h"

@interface GPKGConnection : NSObject


@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *filename;


-(instancetype)initWithDatabaseFilename:(NSString *) filename;

-(GPKGResultSet *) query:(NSString *) statement;

-(int) count:(NSString *) statement;

-(long long) insert:(NSString *) statement;

-(int) update:(NSString *) statement;

-(int) delete:(NSString *) statement;

-(void)close;

@end
