//
//  GPKGDgiwgFile.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgFile.h"

@implementation GPKGDgiwgFile

-(instancetype) initWithFile: (NSString *) file{
    self = [super init];
    if(self != nil){
        [self setFile:file];
        [self setFileNameFromFile:file];
    }
    return self;
}

-(instancetype) initWithFile: (NSString *) file andFileName: (GPKGDgiwgFileName *) fileName{
    self = [super init];
    if(self != nil){
        [self setFile:file];
        [self setFileName:fileName];
    }
    return self;
}

-(instancetype) initWithFile: (NSString *) file andName: (NSString *) fileName{
    self = [super init];
    if(self != nil){
        [self setFile:file];
        [self setFileNameFromFile:fileName];
    }
    return self;
}

-(NSString *) name{
    return _fileName != nil ? [_fileName name] : nil;
}

-(void) setFileNameFromFile: (NSString *) file{
    _fileName = file != nil ? [[GPKGDgiwgFileName alloc] initWithName:file] : nil;
}

@end
