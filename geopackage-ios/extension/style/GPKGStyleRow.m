//
//  GPKGStyleRow.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleRow.h"

NSString *const colorPattern = @"^#([0-9a-fA-F]{3}){1,2}$";

@implementation GPKGStyleRow

static NSRegularExpression *colorExpression = nil;

-(instancetype) init{
    self = [self initWithStyleTable:[[GPKGStyleTable alloc] init]];
    return self;
}

-(instancetype) initWithStyleTable: (GPKGStyleTable *) table{
    self = [super initWithAttributesTable:table];
    return self;
}

-(GPKGStyleTable *) table{
    return (GPKGStyleTable *) [super table];
}

-(int) nameColumnIndex{
    return [[self table] nameColumnIndex];
}

-(GPKGAttributesColumn *) nameColumn{
    return [[self table] nameColumn];
}

-(NSString *) name{
    return (NSString *)[self getValueWithIndex:[self nameColumnIndex]];
}

-(void) setName: (NSString *) name{
    [self setValueWithIndex:[self nameColumnIndex] andValue:name];
}

-(int) descriptionColumnIndex{
    return [[self table] descriptionColumnIndex];
}

-(GPKGAttributesColumn *) descriptionColumn{
    return [[self table] descriptionColumn];
}

-(NSString *) description{
    return (NSString *)[self getValueWithIndex:[self descriptionColumnIndex]];
}

-(void) setDescription: (NSString *) description{
    [self setValueWithIndex:[self descriptionColumnIndex] andValue:description];
}

-(int) colorColumnIndex{
    return [[self table] colorColumnIndex];
}

-(GPKGAttributesColumn *) colorColumn{
    return [[self table] colorColumn];
}

-(GPKGColor *) color{
    return [self createColorWithHex:[self hexColor] andOpacity:[self opacity]];
}

-(BOOL) hasColor{
    return [self hasColorWithHex:[self hexColor] andOpacity:[self opacity]];
}

-(NSString *) hexColor{
    return (NSString *)[self getValueWithIndex:[self colorColumnIndex]];
}

-(void) setColor: (GPKGColor *) color{
    NSString *hex = nil;
    NSDecimalNumber *opacity = nil;
    if(color != nil){
        hex = [color colorHexShorthand];
        opacity = [[NSDecimalNumber alloc] initWithFloat:color.opacity];
    }
    [self setHexColor:hex];
    [self setOpacity:opacity];
}

-(void) setHexColor: (NSString *) color{
    color = [self validateColor:color];
    [self setValueWithIndex:[self colorColumnIndex] andValue:color];
}

-(GPKGColor *) colorOrDefault{
    GPKGColor *color = [self color];
    if(color == nil){
        color = [[GPKGColor alloc] init];
    }
    return color;
}

-(NSString *) hexColorOrDefault{
    NSString *color = [self hexColor];
    if(color == nil){
        color = @"#000000";
    }
    return color;
}

-(int) opacityColumnIndex{
    return [[self table] opacityColumnIndex];
}

-(GPKGAttributesColumn *) opacityColumn{
    return [[self table] opacityColumn];
}

-(NSDecimalNumber *) opacity{
    return (NSDecimalNumber *)[self getValueWithIndex:[self opacityColumnIndex]];
}

-(void) setOpacity: (NSDecimalNumber *) opacity{
    [self validateOpacity:opacity];
    [self setValueWithIndex:[self opacityColumnIndex] andValue:opacity];
}

-(double) opacityOrDefault{
    double opacityValue = 1.0;
    NSDecimalNumber *opacity = [self opacity];
    if(opacity != nil){
        opacityValue = [opacity doubleValue];
    }
    return opacityValue;
}

-(int) widthColumnIndex{
    return [[self table] widthColumnIndex];
}

-(GPKGAttributesColumn *) widthColumn{
    return [[self table] widthColumn];
}

-(NSDecimalNumber *) width{
    return (NSDecimalNumber *)[self getValueWithIndex:[self widthColumnIndex]];
}

-(void) setWidth: (NSDecimalNumber *) width{
    if(width != nil && [width doubleValue]  < 0.0){
        [NSException raise:@"Invalid Value" format:@"Width must be greater than or equal to 0.0, invalid value: %@", width];
    }
    [self setValueWithIndex:[self widthColumnIndex] andValue:width];
}

-(double) widthOrDefault{
    double widthValue = 1.0;
    NSDecimalNumber *width = [self width];
    if(width != nil){
        widthValue = [width doubleValue];
    }
    return widthValue;
}

-(int) fillColorColumnIndex{
    return [[self table] fillColorColumnIndex];
}

-(GPKGAttributesColumn *) fillColorColumn{
    return [[self table] fillColorColumn];
}

-(GPKGColor *) fillColor{
    return [self createColorWithHex:[self fillHexColor] andOpacity:[self fillOpacity]];
}

-(BOOL) hasFillColor{
    return [self hasColorWithHex:[self fillHexColor] andOpacity:[self fillOpacity]];
}

-(NSString *) fillHexColor{
    return (NSString *)[self getValueWithIndex:[self fillColorColumnIndex]];
}

-(void) setFillColor: (GPKGColor *) color{
    NSString *hex = nil;
    NSDecimalNumber *opacity = nil;
    if(color != nil){
        hex = [color colorHexShorthand];
        opacity = [[NSDecimalNumber alloc] initWithFloat:color.opacity];
    }
    [self setFillHexColor:hex];
    [self setFillOpacity:opacity];
}

-(void) setFillHexColor: (NSString *) fillColor{
    fillColor = [self validateColor:fillColor];
    [self setValueWithIndex:[self fillColorColumnIndex] andValue:fillColor];
}

-(int) fillOpacityColumnIndex{
    return [[self table] fillOpacityColumnIndex];
}

-(GPKGAttributesColumn *) fillOpacityColumn{
    return [[self table] fillOpacityColumn];
}

-(NSDecimalNumber *) fillOpacity{
    return (NSDecimalNumber *)[self getValueWithIndex:[self fillOpacityColumnIndex]];
}

-(void) setFillOpacity: (NSDecimalNumber *) fillOpacity{
    [self validateOpacity:fillOpacity];
    [self setValueWithIndex:[self fillOpacityColumnIndex] andValue:fillOpacity];
}

-(double) fillOpacityOrDefault{
    double fillOpacityValue = 1.0;
    NSDecimalNumber *fillOpacity = [self fillOpacity];
    if(fillOpacity != nil){
        fillOpacityValue = [fillOpacity doubleValue];
    }
    return fillOpacityValue;
}

/**
 * Validate and adjust the color value
 *
 * @param color color
 */
-(NSString *) validateColor: (NSString *) color{
    NSString *validated = color;
    if(color != nil){
        if(![color hasPrefix:@"#"]){
            validated = [NSString stringWithFormat:@"#%@", color];
        }
        if(colorExpression == nil){
            NSError  *error = nil;
            colorExpression = [NSRegularExpression regularExpressionWithPattern:colorPattern options:0 error:nil];
            if(error){
                [NSException raise:@"Hex Color Regular Expression" format:@"Failed to create hex color regular expression with error: %@", error];
            }
        }
        if([colorExpression numberOfMatchesInString:validated options:0 range:NSMakeRange(0, validated.length)] != 1){
            [NSException raise:@"Invalid Value" format:@"Color must be in hex format #RRGGBB or #RGB, invalid value: %@", color];
        }
        validated = [validated uppercaseString];
    }
    return validated;
}

/**
 * Validate the opacity value
 *
 * @param opacity opacity
 */
-(void) validateOpacity: (NSDecimalNumber *) opacity{
    if (opacity != nil) {
        double opacityValue = [opacity doubleValue];
        if(opacityValue < 0.0 || opacityValue > 1.0){
            [NSException raise:@"Invalid Value" format:@"Opacity must be set inclusively between 0.0 and 1.0, invalid value: %f", opacityValue];
        }
    }
}

/**
 * Create a color from the hex color and opacity
 *
 * @param hexColor hex color
 * @param opacity  opacity
 * @return color or null
 */
-(GPKGColor *) createColorWithHex: (NSString *) hexColor andOpacity: (NSDecimalNumber *) opacity{
    GPKGColor *color = nil;
    if(hexColor != nil || opacity != nil){
        color = [[GPKGColor alloc] init];
        if(hexColor != nil){
            [color setColorWithHex:hexColor];
        }
        if(opacity != nil){
            [color setOpacity:[opacity floatValue]];
        }
    }
    return color;
}

/**
 * Determine if a color exists from the hex color and opacity
 *
 * @param hexColor hex color
 * @param opacity  opacity
 * @return true if has a color
 */
-(BOOL) hasColorWithHex: (NSString *) hexColor andOpacity: (NSDecimalNumber *) opacity{
    return hexColor != nil || opacity != nil;
}

@end
