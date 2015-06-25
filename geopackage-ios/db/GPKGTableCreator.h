//
//  GPKGTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGUserTable.h"

@interface GPKGTableCreator : NSObject

@property (nonatomic) GPKGConnection *db;

-(instancetype)initWithDatabase:(GPKGConnection *) db;

-(int) createTable: (NSString *) tableName;

@end
