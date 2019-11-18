//
//  NSObject+CLKVC.h
//  OC_KVC
//
//  Created by chenlong on 2019/11/16.
//  Copyright © 2019 langke. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSObject (CLKVC)

// KVC setter method
- (void)cl_setValue:(nullable id)value forKey:(nonnull NSString *)key;

// KVC getter method
- (nullable id)cl_valueForKey:(nonnull NSString *)key;

@end
