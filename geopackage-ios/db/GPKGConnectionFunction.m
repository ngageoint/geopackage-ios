//
//  GPKGConnectionFunction.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/7/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGConnectionFunction.h"

@interface GPKGConnectionFunction()

@property (nonatomic)  void * function;
@property (nonatomic, strong)  NSString *name;
@property (nonatomic)  int numArgs;
@property (nonatomic, strong)  NSObject *userData;

@end

@implementation GPKGConnectionFunction

-(instancetype)initWithFunction: (void *) function withName: (NSString *) name andNumArgs: (int) numArgs{
    return [self initWithFunction:function withName:name andNumArgs:numArgs andUserData:nil];
}

-(instancetype)initWithFunction: (void *) function withName: (NSString *) name andNumArgs: (int) numArgs andUserData: (NSObject *) userData{
    self = [super init];
    if(self){
        self.function = function;
        self.name = name;
        self.numArgs = numArgs;
        self.userData = userData;
    }
    return self;
}

-(void *) function{
    return _function;
}

-(NSString *) name{
    return _name;
}

-(int) numArgs{
    return _numArgs;
}

-(NSObject *) userData{
    return _userData;
}

@end
