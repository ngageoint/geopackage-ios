//
//  TIFFDeflateCompression.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/9/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFCompressionDecoder.h"
#import "TIFFCompressionEncoder.h"

/**
 * Deflate Compression
 *
 * @author osbornb
 */
@interface TIFFDeflateCompression : NSObject<TIFFCompressionDecoder, TIFFCompressionEncoder>

@end
