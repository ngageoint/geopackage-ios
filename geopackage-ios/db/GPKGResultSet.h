//
//  GPKGResultSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface GPKGResultSet : NSObject

@property (nonatomic) sqlite3_stmt *statement;

@property (nonatomic, strong) NSArray *columns;

-(instancetype) initWithStatement:(sqlite3_stmt *) statement;

-(BOOL) moveToNext;

-(void) close;

-(NSArray *) getRow;

@end
