//
//  CoreDataPost+CoreDataProperties.m
//  Minstagram
//
//  Created by Mincho Dzhagalov on 1/13/17.
//  Copyright © 2017 Mincho Dzhagalov. All rights reserved.
//  This file was automatically generated and should not be edited.
//

#import "CoreDataPost+CoreDataProperties.h"

@implementation CoreDataPost (CoreDataProperties)

+ (NSFetchRequest<CoreDataPost *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"CoreDataPost"];
}

@dynamic identifier;
@dynamic photo;
@dynamic photoId;
@dynamic thumbnail;

@end
