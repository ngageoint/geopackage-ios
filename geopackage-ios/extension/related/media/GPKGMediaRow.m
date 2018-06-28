//
//  GPKGMediaRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGMediaRow.h"

@implementation GPKGMediaRow

-(instancetype) initWithMediaTable: (GPKGMediaTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumnTypes:columnTypes andValues:values];
    return self;
}

-(instancetype) initWithMediaTable: (GPKGMediaTable *) table{
    self = [super initWithTable:table];
    return self;
}

-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow{
    self = [super initWithUserCustomRow:userCustomRow];
    return self;
}

-(GPKGMediaTable *) table{
    return (GPKGMediaTable *) super.userCustomTable;
}

-(int) idColumnIndex{
    return [[self table] idColumnIndex];
}

-(GPKGUserCustomColumn *) idColumn{
    return [[self table] idColumn];
}

-(int) id{
    return [(NSNumber *)[self getValueWithIndex:[self idColumnIndex]] intValue];
}

-(int) dataColumnIndex{
    return [[self table] dataColumnIndex];
}

-(GPKGUserCustomColumn *) dataColumn{
    return [[self table] dataColumn];
}

-(NSData *) data{
    return (NSData *)[self getValueWithIndex:[self dataColumnIndex]];
}

-(void) setData: (NSData *) data{
    [self setValueWithIndex:[self dataColumnIndex] andValue:data];
}

-(int) contentTypeColumnIndex{
    return [[self table] contentTypeColumnIndex];
}

-(GPKGUserCustomColumn *) contentTypeColumn{
    return [[self table] contentTypeColumn];
}

-(NSString *) contentType{
    return (NSString *)[self getValueWithIndex:[self contentTypeColumnIndex]];
}

-(void) setContentType: (NSString *) contentType{
    [self setValueWithIndex:[self contentTypeColumnIndex] andValue:contentType];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGMediaRow *mediaRow = [super mutableCopyWithZone:zone];
    return mediaRow;
}

@end
