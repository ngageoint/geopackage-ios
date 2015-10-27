//
//  GPKGNumberFeaturesTile.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGNumberFeaturesTile.h"
#import <CoreText/CoreText.h>

@implementation GPKGNumberFeaturesTile

-(instancetype) init{
    self = [super init];
    if(self != nil){
        
        // Set the default text paint values
        self.textFontSize = 7.0 * [[UIScreen mainScreen] scale]; // TODO
        self.textColor = [UIColor magentaColor]; // TODO
        
        // Set the default circle values
        self.drawCircle = true; // TODO
        self.circleColor = [UIColor redColor]; // TODO
        self.circleStrokeWidth = 5.0; // TODO
        
        // Set the default circle fill values
        self.fillCircle = true; // TODO
        self.circleFillColor = [UIColor darkGrayColor]; // TODO
        
        // Set the default tile border values
        self.drawTileBorder = true; // TODO
        self.tileBorderColor = [UIColor blueColor]; // TODO
        self.tileBorderStrokeWidth = 2.0; // TODO
        
        // Set the default tile fill values
        self.fillTile = true; // TODO
        self.tileFillColor = [UIColor yellowColor]; // TODO
        
        // Set the default circle padding percentage
        self.circlePaddingPercentage = .1; // TODO
        
        // Set the default draw unindexed tiles value
        self.drawUnindexedTiles = true; // TODO
    }
    return self;
}

-(UIImage *) drawTileWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andTileFeatureCount: (int) tileFeatureCount andFeatureIndexResults: (GPKGFeatureIndexResults *) featureIndexResults{
    
    NSString * featureText = [NSString stringWithFormat:@"%d",tileFeatureCount];
    UIImage * image = [self drawTileWithTileWidth:tileWidth andTileHeight:tileHeight andText:featureText];
    
    return image;
}

-(UIImage *) drawUnindexedTileWithTileWidth: (int) tileWidth andTileHeight: (int) tileHeight andTotalFeatureCount: (int) totalFeatureCount andFeatureDao: (GPKGFeatureDao *) featureDao andResults: (GPKGResultSet *) results{
    
    UIImage * image = nil;
    
    if(self.drawUnindexedTiles){
        // Draw a tile indicating we have no idea if there are features inside.
        // The table is not indexed and more features exist than the max feature count set.
        image = [self drawTileWithTileWidth:tileWidth andTileHeight:tileHeight andText:@"?"];
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
    UIFont * font = [UIFont boldSystemFontOfSize:self.textFontSize];
    CGSize textSize = [text sizeWithFont:font];
    
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
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGRect bounds = CGRectMake(centerX - (textSize.width / 2.0), centerY - (textSize.height / 2.0), textSize.width, textSize.height);
    CGPathAddRect(textPath, NULL, bounds );
    
    NSMutableAttributedString* attString = [[NSMutableAttributedString alloc] initWithString:text];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    [attString beginEditing];
    
    [attString addAttribute:NSForegroundColorAttributeName value:self.textColor range:NSMakeRange(0, text.length)];
    [attString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, text.length)];
    [attString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, text.length)];
    
    [attString endEditing];
    
    CTFramesetterRef textFramesetter =
        CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    CTFrameRef textFrame =
        CTFramesetterCreateFrame(textFramesetter,
                             CFRangeMake(0, [attString length]), textPath, NULL);
    
    CTFrameDraw(textFrame, context);
    
    CFRelease(textFrame);
    CFRelease(textPath);
    CFRelease(textFramesetter);
    
    
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
