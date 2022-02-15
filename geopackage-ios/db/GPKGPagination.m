//
//  GPKGPagination.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGPagination.h"

/**
 * Limit SQL statement
 */
NSString *const LIMIT = @"LIMIT";

/**
 * Offset SQL statement
 */
NSString *const OFFSET = @"OFFSET";

/**
 * Expression 1 pattern group
 */
NSString *const EXPRESSION1 = @"expr1";

/**
 * Expression Separator pattern group
 */
NSString *const SEPARATOR = @"separator";

/**
 * Expression 1 pattern group
 */
NSString *const EXPRESSION2 = @"expr2";

/**
 * Limit regex
 */
NSString *const LIMIT_REGEX = @"\\sLIMIT\\s+(?<expr1>-?+\\d+)(\\s*(?<separator>(OFFSET|,))\\s*(?<expr2>-?\\d+))?";

@implementation GPKGPagination

static NSRegularExpression *limitExpression = nil;

+(void) initialize{
    if(limitExpression == nil){
        NSError  *error = nil;
        limitExpression = [NSRegularExpression regularExpressionWithPattern:LIMIT_REGEX options:NSRegularExpressionCaseInsensitive error:&error];
        if(error){
            [NSException raise:@"Limit Regular Expression" format:@"Failed to create limit regular expression with error: %@", error];
        }
    }
}

+(GPKGPagination *) findInSQL: (NSString *) sql{
    GPKGPagination *pagination = nil;
    NSArray<NSTextCheckingResult *> *matches = [limitExpression matchesInString:sql options:0 range:NSMakeRange(0, [sql length])];
    if([matches count] > 0){
        NSTextCheckingResult* match = [matches objectAtIndex:0];
        int limit;
        NSNumber *offset = nil;
        NSString *expr1 = [sql substringWithRange:[match rangeWithName:EXPRESSION1]];
        NSRange separatorRange = [match rangeWithName:SEPARATOR];
        if(separatorRange.length != 0){
            NSString *separator = [sql substringWithRange:separatorRange];
            NSString *expr2 = [sql substringWithRange:[match rangeWithName:EXPRESSION2]];
            if([[separator uppercaseString] isEqualToString:OFFSET]){
                limit = [expr1 intValue];
                offset = [NSNumber numberWithInt:[expr2 intValue]];
            }else{
                limit = [expr2 intValue];
                offset = [NSNumber numberWithInt:[expr1 intValue]];
            }
        }else{
            limit = [expr1 intValue];
        }
        pagination = [[GPKGPagination alloc] initWithLimit:limit andOffset:offset];
    }
    return pagination;
}

+(NSString *) replaceSQL: (NSString *) sql withPagination: (GPKGPagination *) pagination{
    NSString * replaced = nil;
    NSArray<NSTextCheckingResult *> *matches = [limitExpression matchesInString:sql options:0 range:NSMakeRange(0, [sql length])];
    if([matches count] > 0){
        replaced = [limitExpression stringByReplacingMatchesInString:sql options:0 range:NSMakeRange(0, [sql length]) withTemplate:[NSString stringWithFormat:@" %@", [pagination description]]];
    }else{
        [NSException raise:@"Paginated Query" format:@"SQL statement is not a paginated query: %@", sql];
    }
    return replaced;
}

-(instancetype) initWithLimit: (int) limit{
    self = [self initWithLimit:limit andOffset:nil];
    return self;
}

-(instancetype) initWithLimit: (int) limit andOffsetInt: (int) offset{
    self = [self initWithLimit:limit andOffset:[NSNumber numberWithInt:offset]];
    return self;
}

-(instancetype) initWithLimit: (int) limit andOffset: (NSNumber *) offset{
    self = [self init];
    if(self != nil){
        [self setLimit:limit];
        [self setOffset:offset];
    }
    return self;
}

-(BOOL) hasLimit{
    return _limit > 0;
}

-(BOOL) hasOffset{
    return _offset != nil;
}

-(void) setOffset: (NSNumber *) offset{
    if(offset != nil && [offset intValue] < 0){
        offset = [NSNumber numberWithInt:0];
    }
    _offset = offset;
}

-(void) incrementOffset{
    if(_limit > 0){
        [self incrementOffsetByCount:_limit];
    }
}

-(void) incrementOffsetByCount: (int) count{
    if(_offset == nil){
        _offset = [NSNumber numberWithInt:0];
    }
    _offset = [NSNumber numberWithInt:[_offset intValue] + count];
}

-(NSString *) replaceSQL: (NSString *) sql{
    return [GPKGPagination replaceSQL:sql withPagination:self];
}

-(NSString *) description{
    NSMutableString *sql = [NSMutableString string];
    [sql appendString:LIMIT];
    [sql appendString:@" "];
    [sql appendFormat:@"%d", _limit];
    if([self hasOffset]){
        [sql appendString:@" "];
        [sql appendString:OFFSET];
        [sql appendString:@" "];
        [sql appendFormat:@"%@", _offset];
    }
    return sql;
}


@end
