//
//  GPKGGeoPackage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackage.h"
#import "GPKGGeometryColumnsDao.h"

@interface GPKGGeoPackage()

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic) GPKGConnection *database;

@end

@implementation GPKGGeoPackage

-(instancetype) initWithName: (NSString *) name andPath: (NSString *) path andDatabase: (GPKGConnection *) database{
    self = [super init];
    if(self != nil){
        self.name = name;
        self.path = path;
        self.database = database;
    }
    return self;
}

-(void)close{
    [self.database close];
}

-(NSString *)getName{
    return self.name;
}

-(NSString *)getPath{
    return self.path;
}

-(GPKGConnection *)getDatabase{
    return self.database;
}

-(NSArray *)getFeatureTables{
    
    GPKGGeometryColumnsDao *dao = [self getGeometryColumnsDao];
    NSArray *tables = dao.getFeatureTables;
    
    return tables;
}

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.database];
}

@end
