//
//  GPKGDbConnection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/26/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGDbConnection.h"

@interface GPKGDbConnection()

@property (nonatomic, strong) GPKGSqliteConnection * sqliteConnection;
@property (nonatomic) BOOL releasable;
@property (nonatomic) BOOL writeReleasable;

@end

@implementation GPKGDbConnection

-(instancetype) initWithConnection:(GPKGSqliteConnection *) connection andReleasable: (BOOL) releasable{
    return [self initWithConnection:connection andReleasable:releasable andWriteReleasable:releasable];
}

-(instancetype) initWithConnection:(GPKGSqliteConnection *) connection andReleasable: (BOOL) releasable andWriteReleasable: (BOOL) writeReleasable{
    self = [super init];
    if(self){
        self.sqliteConnection = connection;
        self.releasable = releasable;
        self.writeReleasable = writeReleasable;
        self.resettable = NO;
    }
    return self;
}

-(instancetype) initWithDbConnection:(GPKGDbConnection *) connection andReleasable: (BOOL) releasable{
    return [self initWithDbConnection:connection andReleasable:releasable andWriteReleasable:releasable];
}

-(instancetype) initWithDbConnection:(GPKGDbConnection *) connection andReleasable: (BOOL) releasable andWriteReleasable: (BOOL) writeReleasable{
    return [self initWithConnection:connection.sqliteConnection andReleasable:releasable andWriteReleasable:writeReleasable];
}

-(NSNumber *) connectionId{
    return [self.sqliteConnection connectionId];
}

-(sqlite3 *) connection{
    return [self.sqliteConnection connection];
}

-(void) releaseConnection{
    if(self.releasable){
        [self.sqliteConnection releaseConnection];
    }
}

-(NSArray<NSString *> *) stackTrace{
    return [self.sqliteConnection stackTrace];
}

-(NSDate *) dateCheckedOut{
    return [self.sqliteConnection dateCheckedOut];
}

-(BOOL) isReleasable{
    return self.releasable;
}

-(BOOL) isWriteReleasable{
    return self.writeReleasable;
}

@end
