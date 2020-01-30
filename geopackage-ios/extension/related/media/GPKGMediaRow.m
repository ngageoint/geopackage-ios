//
//  GPKGMediaRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGMediaRow.h"
#import "GPKGImageConverter.h"

@implementation GPKGMediaRow

-(instancetype) initWithMediaTable: (GPKGMediaTable *) table andColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    self = [super initWithTable:table andColumns:columns andValues:values];
    return self;
}

-(instancetype) initWithMediaTable: (GPKGMediaTable *) table{
    self = [super initWithTable:table];
    return self;
}

-(GPKGMediaTable *) mediaTable{
    return (GPKGMediaTable *) [super userCustomTable];
}

-(int) dataColumnIndex{
    return [[self mediaTable] dataColumnIndex];
}

-(GPKGUserCustomColumn *) dataColumn{
    return [[self mediaTable] dataColumn];
}

-(NSData *) data{
    return (NSData *)[self valueWithIndex:[self dataColumnIndex]];
}

-(void) setData: (NSData *) data{
    [self setValueWithIndex:[self dataColumnIndex] andValue:data];
}

-(NSDictionary *) dataImageSourceProperties{
    CGImageSourceRef source = CGImageSourceCreateWithData( (CFDataRef) [self data], NULL);
    NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(source,0,NULL));
    CFRelease(source);
    return properties;
}

-(UIImage *) dataImage{
    return [GPKGImageConverter toImage:[self data]];
}

-(UIImage *) dataImageWithScale: (CGFloat) scale{
    return [GPKGImageConverter toImage:[self data] withScale:scale];
}

-(void) setDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format{
    [self setData:[GPKGImageConverter toData:image andFormat:format]];
}

-(void) setDataWithImage: (UIImage *) image andFormat: (enum GPKGCompressFormat) format andQuality: (CGFloat) quality{
    [self setData:[GPKGImageConverter toData:image andFormat:format andQuality:quality]];
}

-(int) contentTypeColumnIndex{
    return [[self mediaTable] contentTypeColumnIndex];
}

-(GPKGUserCustomColumn *) contentTypeColumn{
    return [[self mediaTable] contentTypeColumn];
}

-(NSString *) contentType{
    return (NSString *)[self valueWithIndex:[self contentTypeColumnIndex]];
}

-(void) setContentType: (NSString *) contentType{
    [self setValueWithIndex:[self contentTypeColumnIndex] andValue:contentType];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGMediaRow *mediaRow = [super mutableCopyWithZone:zone];
    return mediaRow;
}

@end
