//
//  Person.m
//  OC_KVC
//
//  Created by chenlong on 2019/11/16.
//  Copyright © 2019 langke. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype)init
{
	self = [super init];
	if (self) {
		age = 99.66;
		name = @"chenlong";
	}
	return self;
}

@end
