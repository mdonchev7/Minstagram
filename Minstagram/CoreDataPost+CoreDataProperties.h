//
//  CoreDataPost+CoreDataProperties.h
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/11/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "CoreDataPost+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface CoreDataPost (CoreDataProperties)

+ (NSFetchRequest<CoreDataPost *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *identifier;
@property (nullable, nonatomic, retain) NSData *photo;
@property (nullable, nonatomic, retain) NSData *thumbnail;
@property (nonatomic) int16_t likes;
@property (nullable, nonatomic, copy) NSDate *postedOn;
@property (nullable, nonatomic, copy) NSString *photoId;

@end

NS_ASSUME_NONNULL_END
