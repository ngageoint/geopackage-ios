//
//  TIFFImage.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFImage.h"
#import "TIFFConstants.h"

@interface TIFFImage()

/**
 * File directories
 */
@property (nonatomic, strong) NSMutableArray<TIFFFileDirectory *> * fileDirectories;

@end

@implementation TIFFImage

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.fileDirectories = [[NSMutableArray alloc] init];
    }
    return self;
}

-(instancetype) initWithFileDirectory: (TIFFFileDirectory *) fileDirectory{
    self = [super init];
    if(self != nil){
        self.fileDirectories = [[NSMutableArray alloc] initWithObjects:fileDirectory, nil];
    }
    return self;
}

-(instancetype) initWithFileDirectories: (NSArray<TIFFFileDirectory *> *) fileDirectories{
    self = [super init];
    if(self != nil){
        self.fileDirectories = [[NSMutableArray alloc] initWithArray:fileDirectories];
    }
    return self;
}

-(void) addFileDirectory: (TIFFFileDirectory *) fileDirectory{
    [_fileDirectories addObject:fileDirectory];
}

-(NSArray<TIFFFileDirectory *> *) fileDirectories{
    return _fileDirectories;
}

-(TIFFFileDirectory *) fileDirectory{
    return [_fileDirectories objectAtIndex:0];
}

-(TIFFFileDirectory *) fileDirectoryAtIndex: (int) index{
    return [_fileDirectories objectAtIndex:index];
}

-(int) sizeHeaderAndDirectories{
    int size = (int)TIFF_HEADER_BYTES;
    for (TIFFFileDirectory * directory in _fileDirectories) {
        size += [directory size];
    }
    return size;
}

-(int) sizeHeaderAndDirectoriesWithValues{
    int size = (int)TIFF_HEADER_BYTES;
    for (TIFFFileDirectory * directory in _fileDirectories) {
        size += [directory sizeWithValues];
    }
    return size;
}

@end
