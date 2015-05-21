//
//  GPKGUserDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGUserTable.h"

@interface GPKGUserDao : GPKGBaseDao

@property (nonatomic, strong) GPKGUserTable * table;

@property (nonatomic, strong) GPKGProjection * projection;

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserTable *) table;

@end
