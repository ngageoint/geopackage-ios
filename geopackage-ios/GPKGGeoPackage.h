//
//  GPKGGeoPackage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "GPKGConnection.h"

@interface GPKGGeoPackage : NSObject

-(instancetype) initWithName: (NSString *) name andPath: (NSString *) path andDatabase: (GPKGConnection *) database;

-(void)close;

-(NSString *)getName;

-(NSString *)getPath;

-(GPKGConnection *)getDatabase;

-(NSArray *)getFeatureTables;

@end
