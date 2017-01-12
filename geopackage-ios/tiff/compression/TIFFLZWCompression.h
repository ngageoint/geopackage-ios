//
//  TIFFLZWCompression.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFCompressionDecoder.h"
#import "TIFFCompressionEncoder.h"

/**
 * LZW Compression
 */
@interface TIFFLZWCompression : NSObject<TIFFCompressionDecoder, TIFFCompressionEncoder>

@end
