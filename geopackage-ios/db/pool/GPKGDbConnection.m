//
//  GPKGDbConnection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/26/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGDbConnection.h"

@interface GPKGDbConnection()

@property (nonatomic, strong) GPKGSqliteConnection * connection;
@property (nonatomic) BOOL releasable;

@end

@implementation GPKGDbConnection

-(instancetype)initWithConnection:(GPKGSqliteConnection *) connection andReleasable: (BOOL) releasable{
    self = [super init];
    if(self){
        self.connection = connection;
        self.releasable = releasable;
    }
    return self;
}

-(NSNumber *) getConnectionId{
    return [self.connection getConnectionId];
}

-(sqlite3 *) getConnection{
    return [self.connection getConnection];
}

-(void) releaseConnection{
    if(self.releasable){
        [self.connection releaseConnection];
    }
}

-(NSArray<NSString *> *) getStackTrace{
    return [self.connection getStackTrace];
}

-(NSDate *) getDateCheckedOut{
    return [self.connection getDateCheckedOut];
}

-(BOOL) isReleasable{
    return self.releasable;
}

@end
