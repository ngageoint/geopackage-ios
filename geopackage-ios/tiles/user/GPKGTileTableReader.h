//
//  GPKGTileTableReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileTable.h"

@interface GPKGTileTableReader : GPKGUserTableReader

@property (nonatomic, strong) GPKGTileMatrixSet * tileMatrixSet;

-(instancetype) initWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

-(GPKGTileTable *) readTileTableWithConnection: (GPKGConnection *) db;

@end
