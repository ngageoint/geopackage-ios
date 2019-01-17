//
//  GPKGColor.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/14/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGColor.h"
#import "GPKGColorUtils.h"

@implementation GPKGColor

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.red = 0.0;
        self.green = 0.0;
        self.blue = 0.0;
        self.opacity = 1.0;
    }
    return self;
}

-(instancetype) initWithHex: (NSString *) color{
    self = [self init];
    if(self != nil){
        [self setColorWithHex:color];
    }
    return self;
}

-(instancetype) initWithHex: (NSString *) color andOpacity: (float) opacity{
    self = [self init];
    if(self != nil){
        [self setColorWithHex:color andOpacity:opacity];
    }
    return self;
}

-(instancetype) initWithHex: (NSString *) color andAlpha: (int) alpha{
    self = [self init];
    if(self != nil){
        [self setColorWithHex:color andAlpha:alpha];
    }
    return self;
}

-(instancetype) initWithHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue{
    self = [self init];
    if(self != nil){
        [self setColorWithHexRed:red andGreen:green andBlue:blue];
    }
    return self;
}

-(instancetype) initWithHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andAlpha: (NSString *) alpha{
    self = [self init];
    if(self != nil){
        [self setColorWithHexRed:red andGreen:green andBlue:blue andAlpha:alpha];
    }
    return self;
}

-(instancetype) initWithHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andOpacity: (float) opacity{
    self = [self init];
    if(self != nil){
        [self setColorWithHexRed:red andGreen:green andBlue:blue andOpacity:opacity];
    }
    return self;
}

-(instancetype) initWithRed: (int) red andGreen: (int) green andBlue: (int) blue{
    self = [self init];
    if(self != nil){
        [self setColorWithRed:red andGreen:green andBlue:blue];
    }
    return self;
}

-(instancetype) initWithRed: (int) red andGreen: (int) green andBlue: (int) blue andAlpha: (int) alpha{
    self = [self init];
    if(self != nil){
        [self setColorWithRed:red andGreen:green andBlue:blue andAlpha:alpha];
    }
    return self;
}

-(instancetype) initWithRed: (int) red andGreen: (int) green andBlue: (int) blue andOpacity: (float) opacity{
    self = [self init];
    if(self != nil){
        [self setColorWithRed:red andGreen:green andBlue:blue andOpacity:opacity];
    }
    return self;
}

-(instancetype) initWithArithmeticRed: (float) red andGreen: (float) green andBlue: (float) blue{
    self = [self init];
    if(self != nil){
        [self setColorWithArithmeticRed:red andGreen:green andBlue:blue];
    }
    return self;
}

-(instancetype) initWithArithmeticRed: (float) red andGreen: (float) green andBlue: (float) blue andOpacity: (float) opacity{
    self = [self init];
    if(self != nil){
        [self setColorWithArithmeticRed:red andGreen:green andBlue:blue andOpacity:opacity];
    }
    return self;
}

-(instancetype) initWithHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    self = [self init];
    if(self != nil){
        [self setColorWithHue:hue andSaturation:saturation andLightness:lightness];
    }
    return self;
}

-(instancetype) initWithHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness andAlpha: (float) alpha{
    self = [self init];
    if(self != nil){
        [self setColorWithHue:hue andSaturation:saturation andLightness:lightness andAlpha:alpha];
    }
    return self;
}

-(instancetype) initWithColor: (int) color{
    self = [self init];
    if(self != nil){
        [self setColor:color];
    }
    return self;
}

-(instancetype) initWithUnsignedColor: (unsigned int) color{
    self = [self init];
    if(self != nil){
        [self setUnsignedColor:color];
    }
    return self;
}

-(void) setColorWithHex: (NSString *) color{
    [self setRedHex:[GPKGColorUtils redHexFromHex:color]];
    [self setGreenHex:[GPKGColorUtils greenHexFromHex:color]];
    [self setBlueHex:[GPKGColorUtils blueHexFromHex:color]];
    NSString *alpha = [GPKGColorUtils alphaHexFromHex:color];
    if(alpha != nil){
        [self setAlphaHex:alpha];
    }
}

-(void) setColorWithHex: (NSString *) color andOpacity: (float) opacity{
    [self setColorWithHex:color];
    [self setOpacity:opacity];
}

-(void) setColorWithHex: (NSString *) color andAlpha: (int) alpha{
    [self setColorWithHex:color];
    [self setAlpha:alpha];
}

-(void) setColorWithHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue{
    [self setRedHex:red];
    [self setGreenHex:green];
    [self setBlueHex:blue];
}

-(void) setColorWithHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andAlpha: (NSString *) alpha{
    [self setColorWithHexRed:red andGreen:green andBlue:blue];
    [self setAlphaHex:alpha];
}

-(void) setColorWithHexRed: (NSString *) red andGreen: (NSString *) green andBlue: (NSString *) blue andOpacity: (float) opacity{
    [self setColorWithHexRed:red andGreen:green andBlue:blue];
    [self setOpacity:opacity];
}

-(void) setColorWithRed: (int) red andGreen: (int) green andBlue: (int) blue{
    [self setRed:red];
    [self setGreen:green];
    [self setBlue:blue];
}

-(void) setColorWithRed: (int) red andGreen: (int) green andBlue: (int) blue andAlpha: (int) alpha{
    [self setColorWithRed:red andGreen:green andBlue:blue];
    [self setAlpha:alpha];
}

-(void) setColorWithRed: (int) red andGreen: (int) green andBlue: (int) blue andOpacity: (float) opacity{
    [self setColorWithRed:red andGreen:green andBlue:blue];
    [self setOpacity:opacity];
}

-(void) setColorWithArithmeticRed: (float) red andGreen: (float) green andBlue: (float) blue{
    [self setRedArithmetic:red];
    [self setGreenArithmetic:green];
    [self setBlueArithmetic:blue];
}

-(void) setColorWithArithmeticRed: (float) red andGreen: (float) green andBlue: (float) blue andOpacity: (float) opacity{
    [self setColorWithArithmeticRed:red andGreen:green andBlue:blue];
    [self setOpacity:opacity];
}

-(void) setColorWithHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness{
    float *arithmeticRGB = [GPKGColorUtils toArithmeticRGBFromHue:hue andSaturation:saturation andLightness:lightness];
    [self setRedArithmetic:arithmeticRGB[0]];
    [self setGreenArithmetic:arithmeticRGB[1]];
    [self setBlueArithmetic:arithmeticRGB[2]];
}

-(void) setColorWithHue: (float) hue andSaturation: (float) saturation andLightness: (float) lightness andAlpha: (float) alpha{
    [self setColorWithHue:hue andSaturation:saturation andLightness:lightness];
    [self setAlphaArithmetic:alpha];
}

-(void) setColor: (int) color{
    [self setRed:[GPKGColorUtils redFromColor:color]];
    [self setGreen:[GPKGColorUtils greenFromColor:color]];
    [self setBlue:[GPKGColorUtils blueFromColor:color]];
    if (color > 16777215 || color < 0) {
        [self setAlpha:[GPKGColorUtils alphaFromColor:color]];
    }
}

-(void) setUnsignedColor: (unsigned int) color{
    [self setColor:color];
}

-(void) setRedHex: (NSString *) red{
    [self setRedArithmetic:[GPKGColorUtils toArithmeticRGBFromHex:red]];
}

-(void) setGreenHex: (NSString *) green{
    [self setGreenArithmetic:[GPKGColorUtils toArithmeticRGBFromHex:green]];
}

-(void) setBlueHex: (NSString *) blue{
    [self setBlueArithmetic:[GPKGColorUtils toArithmeticRGBFromHex:blue]];
}

-(void) setAlphaHex: (NSString *) alpha{
    [self setAlphaArithmetic:[GPKGColorUtils toArithmeticRGBFromHex:alpha]];
}

-(void) setRed: (int) red{
    [self setRedHex:[GPKGColorUtils toHexFromRGB:red]];
}

-(void) setGreen: (int) green{
    [self setGreenHex:[GPKGColorUtils toHexFromRGB:green]];
}

-(void) setBlue: (int) blue{
    [self setBlueHex:[GPKGColorUtils toHexFromRGB:blue]];
}

-(void) setAlpha: (int) alpha{
    [self setOpacity:[GPKGColorUtils toArithmeticRGBFromRGB:alpha]];
}

-(void) setRedArithmetic: (float) redArithmetic{
    [GPKGColorUtils validateArithmeticRGB:redArithmetic];
    _redArithmetic = redArithmetic;
}

-(void) setGreenArithmetic: (float) greenArithmetic{
    [GPKGColorUtils validateArithmeticRGB:greenArithmetic];
    _greenArithmetic = greenArithmetic;
}

-(void) setBlueArithmetic: (float) blueArithmetic{
    [GPKGColorUtils validateArithmeticRGB:blueArithmetic];
    _blueArithmetic = blueArithmetic;
}

-(void) setOpacity: (float) opacity{
    [GPKGColorUtils validateArithmeticRGB:opacity];
    _opacity = opacity;
}

-(void) setAlphaArithmetic: (float) alpha{
    [self setOpacity:alpha];
}

-(BOOL) isOpaque{
    return self.opacity == 1.0;
}

-(NSString *) colorHex{
    return [GPKGColorUtils toColorFromHexRed:[self redHex] andGreen:[self greenHex] andBlue:[self blueHex]];
}

-(NSString *) colorHexWithAlpha{
    return [GPKGColorUtils toColorWithAlphaFromHexRed:[self redHex] andGreen:[self greenHex] andBlue:[self blueHex] andAlpha:[self alphaHex]];
}

-(NSString *) colorHexShorthand{
    return [GPKGColorUtils toColorShorthandFromHexRed:[self redHex] andGreen:[self greenHex] andBlue:[self blueHex]];
}

-(NSString *) colorHexShorthandWithAlpha{
    return [GPKGColorUtils toColorShorthandWithAlphaFromHexRed:[self redHex] andGreen:[self greenHex] andBlue:[self blueHex] andAlpha:[self alphaHex]];
}

-(int) color{
    return [GPKGColorUtils toColorFromRed:[self red] andGreen:[self green] andBlue:[self blue]];
}

-(unsigned int) unsignedColor{
    return [self color];
}

-(int) colorWithAlpha{
    return [GPKGColorUtils toColorWithAlphaFromRed:[self red] andGreen:[self green] andBlue:[self blue] andAlpha:[self alpha]];
}

-(unsigned int) unsignedColorWithAlpha{
    return [self colorWithAlpha];
}

-(NSString *) redHex{
    return [GPKGColorUtils toHexFromArithmeticRGB:self.redArithmetic];
}

-(NSString *) greenHex{
    return [GPKGColorUtils toHexFromArithmeticRGB:self.greenArithmetic];
}

-(NSString *) blueHex{
    return [GPKGColorUtils toHexFromArithmeticRGB:self.blueArithmetic];
}

-(NSString *) alphaHex{
    return [GPKGColorUtils toHexFromArithmeticRGB:self.opacity];
}

-(NSString *) redHexShorthand{
    return [GPKGColorUtils shorthandHexSingle:[self redHex]];
}

-(NSString *) greenHexShorthand{
    return [GPKGColorUtils shorthandHexSingle:[self greenHex]];
}

-(NSString *) blueHexShorthand{
    return [GPKGColorUtils shorthandHexSingle:[self blueHex]];
}

-(NSString *) alphaHexShorthand{
    return [GPKGColorUtils shorthandHexSingle:[self alphaHex]];
}

-(int) red{
    return [GPKGColorUtils toRGBFromArithmeticRGB:self.redArithmetic];
}

-(int) green{
    return [GPKGColorUtils toRGBFromArithmeticRGB:self.greenArithmetic];
}

-(int) blue{
    return [GPKGColorUtils toRGBFromArithmeticRGB:self.blueArithmetic];
}

-(int) alpha{
    return [GPKGColorUtils toRGBFromArithmeticRGB:self.opacity];
}

-(float) alphaArithmetic{
    return self.opacity;
}

-(float *) hsl{
    return [GPKGColorUtils toHSLFromArithmeticRed:self.redArithmetic andGreen:self.greenArithmetic andBlue:self.blueArithmetic];
}

-(float) hue{
    return [self hsl][0];
}

-(float) saturation{
    return [self hsl][1];
}

-(float) lightness{
    return [self hsl][2];
}

@end
