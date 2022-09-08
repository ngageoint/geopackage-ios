//
//  GPKGNumberFeaturesTile.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGNumberFeaturesTile.h"
#import <CoreText/CoreText.h>
#import "GPKGUtils.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

@implementation GPKGNumberFeaturesTile

-(instancetype) init{
    self = [super init];
    if(self != nil){
        
        // Set the default text paint values
        self.textFont = [GPKGProperties valueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_TEXT_FONT];
        self.textFontSize = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_TEXT_FONT_SIZE] floatValue];
        self.textColor = [GPKGUtils color:[GPKGProperties dictionaryValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_TEXT_COLOR]];
        
        // Set the default circle values
        self.drawCircle = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_DRAW_CIRCLE];
        self.circleColor = [GPKGUtils color:[GPKGProperties dictionaryValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_COLOR]];
        self.circleStrokeWidth = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_STROKE_WIDTH] floatValue];
        
        // Set the default circle fill values
        self.fillCircle = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_FILL_CIRCLE];
        self.circleFillColor = [GPKGUtils color:[GPKGProperties dictionaryValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_FILL_COLOR]];
        
        // Set the default tile border values
        self.drawTileBorder = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_DRAW_TILE_BORDER];
        self.tileBorderColor = [GPKGUtils color:[GPKGProperties dictionaryValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_TILE_BORDER_COLOR]];
        self.tileBorderStrokeWidth = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_TILE_BORDER_STROKE_WIDTH] floatValue];
        
        // Set the default tile fill values
        self.fillTile = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_FILL_TILE];
        self.tileFillColor = [GPKGUtils color:[GPKGProperties dictionaryValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_TILE_FILL_COLOR]];
        
        // Set the default circle padding percentage
        self.circlePaddingPercentage = [[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_CIRCLE_PADDING_PERCENTAGE] floatValue];
        
        // Set the default draw unindexed tiles value
        self.drawUnindexedTiles = [GPKGProperties boolValueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_DRAW_UNINDEXED_TILES];
        self.unindexedText = [GPKGProperties valueOfBaseProperty:GPKG_PROP_NUMBER_FEATURE_TILES andProperty:GPKG_PROP_NUMBER_FEATURE_TILES_UNINDEXED_TEXT];
    }
    return self;
}

-(UIImage *) drawTileWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andTileFeatureCount: (int) tileFeatureCount andFeatureIndexResults: (GPKGFeatureIndexResults *) featureIndexResults{
    
    NSString *featureText = [NSString stringWithFormat:@"%d",tileFeatureCount];
    UIImage *image = [self drawTileWithTileWidth:tileWidth andTileHeight:tileHeight andText:featureText];
    
    return image;
}

-(UIImage *) drawUnindexedTileWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andTotalFeatureCount: (int) totalFeatureCount andFeatureDao: (GPKGFeatureDao *) featureDao andResults: (GPKGResultSet *) results{
    
    UIImage *image = nil;
    
    if(self.drawUnindexedTiles){
        // Draw a tile indicating we have no idea if there are features inside.
        // The table is not indexed and more features exist than the max feature count set.
        image = [self drawTileWithTileWidth:tileWidth andTileHeight:tileHeight andText:self.unindexedText];
    }
    
    return image;
}

-(UIImage *) drawTileWithTileWidth:(int)tileWidth andTileHeight:(int)tileHeight andText: (NSString *) text{
    
    UIGraphicsBeginImageContext(CGSizeMake(tileWidth, tileHeight));
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw from the top left
    CGContextTranslateCTM(context, 0, tileHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    if(self.drawTileBorder || self.fillTile){
    
        // Create the tile path
        CGMutablePathRef tilePath = CGPathCreateMutable();
        CGPathMoveToPoint(tilePath, NULL, 0, 0);
        CGPathAddLineToPoint(tilePath, NULL, 0, tileHeight);
        CGPathAddLineToPoint(tilePath, NULL, tileWidth, tileHeight);
        CGPathAddLineToPoint(tilePath, NULL, tileWidth, 0);
        CGPathAddLineToPoint(tilePath, NULL, 0, 0);
        CGPathCloseSubpath(tilePath);
        
        // Draw the tile border and fill
        CGContextSetLineWidth(context, self.tileBorderStrokeWidth);
        CGContextSetStrokeColorWithColor(context, self.tileBorderColor.CGColor);
        CGContextSetFillColorWithColor(context, self.tileFillColor.CGColor);
        CGContextAddPath(context, tilePath);
        CGPathDrawingMode tileMode;
        if(self.drawTileBorder && self.fillTile){
            tileMode = kCGPathEOFillStroke;
        }else if(self.fillTile){
            tileMode = kCGPathFill;
        }else{
            tileMode = kCGPathStroke;
        }
        CGContextDrawPath(context, tileMode);
        CGPathRelease(tilePath);
        
    }
    
    // Determine the text bounds
    UIFont *font = [UIFont fontWithName:self.textFont size:self.textFontSize];
    CGSize textSize = [text sizeWithAttributes:@{ NSFontAttributeName : font }];
    textSize = CGSizeMake(ceil(textSize.width), ceil(textSize.height));
    
    // Determine the center of the tile
    double centerX = tileWidth / 2.0;
    double centerY = tileHeight / 2.0;
    
    // Draw the circle
    if(self.drawCircle || self.fillCircle){
        
        double diameter = MAX(textSize.width, textSize.height);
        diameter = diameter + (diameter * self.circlePaddingPercentage * 2);
        double radius = diameter / 2.0;
        CGRect circleRect = CGRectMake(centerX - radius, centerY - radius, diameter, diameter);
        
        // Draw the filled circle
        if(self.fillCircle){
            CGContextSetFillColorWithColor(context, self.circleFillColor.CGColor);
            CGContextFillEllipseInRect(context, circleRect);
        }
        
        // Draw the circle
        if(self.drawCircle){
            CGContextSetLineWidth(context, self.circleStrokeWidth);
            CGContextSetStrokeColorWithColor(context, self.circleColor.CGColor);
            CGContextStrokeEllipseInRect(context, circleRect);
        }

    }
    
    // Draw the text
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                            NSFontAttributeName: font,
                            NSForegroundColorAttributeName: self.textColor,
                            NSParagraphStyleAttributeName: paragraphStyle,
                            };
    
    CGRect bounds = CGRectMake(centerX - (textSize.width / 2.0), centerY - (textSize.height / 2.0), textSize.width, textSize.height);
    
    CGContextTranslateCTM(context, 0, tileHeight);
    CGContextScaleCTM(context, 1.0, -1.0);
    [text drawInRect:bounds withAttributes:attributes];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
