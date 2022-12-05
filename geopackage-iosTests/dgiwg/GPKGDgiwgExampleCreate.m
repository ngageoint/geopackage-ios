//
//  GPKGDgiwgExampleCreate.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 12/2/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgExampleCreate.h"

@implementation GPKGDgiwgExampleCreate

+(GPKGDgiwgExampleCreate *) base{
    return [[GPKGDgiwgExampleCreate alloc] init];
}

+(GPKGDgiwgExampleCreate *) all{
    GPKGDgiwgExampleCreate *create = [self featuresAndTiles];
    create.nationalMetadata = YES;
    create.featuresMetadata = YES;
    create.tilesMetadata = YES;
    create.schema = YES;
    create.coverage = YES;
    create.relatedMedia = YES;
    create.relatedTiles = YES;
    return create;
}

+(GPKGDgiwgExampleCreate *) featuresAndTiles{
    GPKGDgiwgExampleCreate *create = [self base];
    create.features = YES;
    create.tiles = YES;
    return create;
}

+(GPKGDgiwgExampleCreate *) features{
    GPKGDgiwgExampleCreate *create = [self base];
    create.features = YES;
    return create;
}

+(GPKGDgiwgExampleCreate *) tiles{
    GPKGDgiwgExampleCreate *create = [self base];
    create.tiles = YES;
    return create;
}

-(instancetype) init{
    self = [super init];
    if(self != nil){
        _features = NO;
        _tiles = NO;
        _nationalMetadata = NO;
        _featuresMetadata = NO;
        _tilesMetadata = NO;
        _schema = NO;
        _coverage = NO;
        _relatedMedia = NO;
        _relatedTiles = NO;
    }
    return self;
}

@end
