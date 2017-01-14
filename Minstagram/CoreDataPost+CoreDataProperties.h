//
//  CoreDataPost+CoreDataProperties.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/14/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "CoreDataPost+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CoreDataPost (CoreDataProperties)

+ (NSFetchRequest<CoreDataPost *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, retain) NSData *imageData;
@property (nullable, nonatomic, copy) NSString *imageId;
@property (nullable, nonatomic, retain) NSData *thumbnailData;
@property (nullable, nonatomic, copy) NSString *thumbnailId;

@end

NS_ASSUME_NONNULL_END
