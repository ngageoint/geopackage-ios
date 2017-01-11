//
//  TIFFFileDirectoryEntry.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "TIFFFileDirectoryEntry.h"
#import "TIFFConstants.h"

@interface TIFFFileDirectoryEntry()

@property (nonatomic) enum TIFFFieldTagType fieldTag;
@property (nonatomic) enum TIFFFieldType fieldType;
@property (nonatomic) int typeCount;
@property (nonatomic, strong) NSObject * values;

@end

@implementation TIFFFileDirectoryEntry

-(instancetype)initWithFieldTag: (enum TIFFFieldTagType) fieldTag andFieldType: (enum TIFFFieldType) fieldType andTypeCount: (int) typeCount andValues: (NSObject *) values{
    self = [super init];
    if(self){
        self.fieldTag = fieldTag;
        self.fieldType = fieldType;
        self.typeCount = typeCount;
        self.values = values;
    }
    return self;
}

-(enum TIFFFieldTagType) fieldTag{
    return _fieldTag;
}

-(enum TIFFFieldType) fieldType{
    return _fieldType;
}

-(int) typeCount{
    return _typeCount;
}

-(NSObject *) values{
    return _values;
}

-(int) sizeWithValues{
    int size = (int)TIFF_IFD_ENTRY_BYTES + [self sizeOfValues];
    return size;
}

-(int) sizeOfValues{
    int size = 0;
    int valueBytes = [TIFFFieldTypes bytes:self.fieldType] * self.typeCount;
    if(valueBytes > 4){
        size = valueBytes;
    }
    return size;
}

@end
