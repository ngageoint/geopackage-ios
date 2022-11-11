//
//  GPKGDgiwgValidationErrors.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgValidationErrors.h"

@interface GPKGDgiwgValidationErrors()

/**
 * Errors
 */
@property (nonatomic, strong) NSMutableArray<GPKGDgiwgValidationError *> *errors;

@end

@implementation GPKGDgiwgValidationErrors

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.errors = [NSMutableArray array];
    }
    return self;
}

-(instancetype) initWithError: (GPKGDgiwgValidationError *) error{
    self = [self init];
    if(self != nil){
        [self addError:error];
    }
    return self;
}

-(instancetype) initWithErrors: (NSArray<GPKGDgiwgValidationError *> *) errors{
    self = [self init];
    if(self != nil){
        [self addErrors:errors];
    }
    return self;
}

-(instancetype) initWithValidationErrors: (GPKGDgiwgValidationErrors *) errors{
    self = [self init];
    if(self != nil){
        [self addValidationErrors:errors];
    }
    return self;
}

-(void) addError: (GPKGDgiwgValidationError *) error{
    [_errors addObject:error];
}

-(void) addErrors: (NSArray<GPKGDgiwgValidationError *> *) errors{
    [_errors addObjectsFromArray:errors];
}

-(void) addValidationErrors: (GPKGDgiwgValidationErrors *) errors{
    [self addErrors:[errors errors]];
}

-(BOOL) isValid{
    return _errors.count == 0;
}

-(BOOL) hasErrors{
    return ![self isValid];
}

-(int) numErrors{
    return (int) _errors.count;
}

-(NSArray<GPKGDgiwgValidationError *> *) errors{
    return _errors;
}

-(GPKGDgiwgValidationError *) errorAtIndex: (int) index{
    return [_errors objectAtIndex:index];
}

-(NSString *) description{
    NSMutableString *value = [NSMutableString string];
    for(GPKGDgiwgValidationError *error in _errors){
        if(value.length > 0){
            [value appendString:@"\n"];
        }
        [value appendString:[error description]];
    }
    return value;
}

@end
