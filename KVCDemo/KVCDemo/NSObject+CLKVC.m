//
//  NSObject+CLKVC.m
//  OC_KVC
//
//  Created by chenlong on 2019/11/16.
//  Copyright © 2019 langke. All rights reserved.
//

#import "NSObject+CLKVC.h"
#import <objc/runtime.h>

@implementation NSObject (CLKVC)

#pragma mark - Custom KVC setter

- (void)cl_setValue:(nullable id)value forKey:(nonnull NSString *)key
{
	if (!key || !key.length) {
		[self setValue:value forUndefinedKey:key];
		return;
	}
	
	// setKey
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	NSString *setKey = [NSString stringWithFormat:@"set%@:", key.capitalizedString];
	SEL setKeySEL = NSSelectorFromString(setKey);
	if ([self respondsToSelector:setKeySEL]) {
		[self performSelector:setKeySEL withObject:value];
		return;
	}
	
	// _setKey
	NSString *_setKey = [NSString stringWithFormat:@"_set%@:", key.capitalizedString];
	SEL _setKeySEL = NSSelectorFromString(_setKey);
	if ([self respondsToSelector:_setKeySEL]) {
		[self performSelector:_setKeySEL withObject:value];
		return;
	}
	
	// setIsKey
	NSString *setIsKey = [NSString stringWithFormat:@"setIs%@:", key.capitalizedString];
	SEL setIsKeySEL = NSSelectorFromString(setIsKey);
	if ([self respondsToSelector:setIsKeySEL]) {
		[self performSelector:setIsKeySEL withObject:value];
		return;
	}
	#pragma clang diagnostic pop
	
	// access instance variable method to check. If NO, throw an exception.
	if (![[self class] accessInstanceVariablesDirectly]) {
		NSException *exception = [NSException exceptionWithName:@"CL KVC"
														 reason:@"accessInstanceVariablesDirectly method returns NO"
													   userInfo:nil];
		@throw exception;
		return;
	}
	
	unsigned int outCount = 0;
	Ivar *ivars = class_copyIvarList([self class], &outCount);
	
	// _key
	NSString *_key = [NSString stringWithFormat:@"_%@", key];
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:_key]) {
			[self setValueWithIvar:ivar key:key value:value];
			free(ivars);
			return;
		}
	}
	
	// _isKey
	NSString *_isKey = [NSString stringWithFormat:@"_is%@", key.capitalizedString];
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:_isKey]) {
			[self setValueWithIvar:ivar key:key value:value];
			free(ivars);
			return;
		}
	}
	
	// key
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:key]) {
			[self setValueWithIvar:ivar key:key value:value];
			free(ivars);
			return;
		}
	}
	
	// isKey
	NSString *isKey = [NSString stringWithFormat:@"is%@", key.capitalizedString];
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:isKey]) {
			[self setValueWithIvar:ivar key:key value:value];
			free(ivars);
			return;
		}
	}
	
	// no setter method or no corresponding instance variables
	[self setValue:value forUndefinedKey:key];
	free(ivars);
}

- (void)setValueWithIvar:(Ivar)ivar key:(NSString *)key value:(id)value
{
	const char *ivarEncodingType = ivar_getTypeEncoding(ivar);
	NSString *ivarType = [NSString stringWithUTF8String:ivarEncodingType];
	ptrdiff_t ivarOffset = ivar_getOffset(ivar);
	
	// object type
	if ([ivarType hasPrefix:@"@"]) {
		object_setIvar(self, ivar, value);
		// int type
	} else if ([ivarType hasPrefix:@"i"]) {
		if (value == nil) {
			[self setNilValueForKey:key];
		} else {
			int *intIvar = (int *)((uint8_t *)(__bridge void *)self + ivarOffset);
			*intIvar = [value intValue];
		}
		// float type
	} else if ([ivarType hasPrefix:@"f"]) {
		if (value == nil) {
			[self setNilValueForKey:key];
		} else {
			float *floatIvar = (float *)((uint8_t *)(__bridge void *)self + ivarOffset);
			*floatIvar = [value floatValue];
		}
		// double type
	} else if ([ivarType hasPrefix:@"d"]) {
		if (value == nil) {
			[self setNilValueForKey:key];
		} else {
			CFTypeRef thisSelf = CFBridgingRetain(self);
			double *doubleIvar = (double *)((uint8_t *)thisSelf + ivar_getOffset(ivar));
			*doubleIvar = [value doubleValue];
			CFBridgingRelease(thisSelf);
		}
		// other unresolved types
	} else {
		NSString *exceptionReason = [NSString stringWithFormat:@"The ivarType encoding type is %@, but it is undefined. See the official website for more details: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1", ivarType];
		NSException *exception = [NSException exceptionWithName: @"CL_KVC cl_setValue: forKey:"
														 reason: exceptionReason
													   userInfo: nil];
		@throw exception;
	}
}

#pragma mark - Custom kvc getter

- (nullable id)cl_valueForKey:(nonnull NSString *)key
{
	if (!key || !key.length) {
		[self valueForUndefinedKey:key];
		return nil;
	}
	
	// getKey
	#pragma clang diagnostic push
	#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
	NSString *getKey = [NSString stringWithFormat:@"get%@", key.capitalizedString];
	SEL getKeySEL = NSSelectorFromString(getKey);
	if ([self respondsToSelector:getKeySEL]) {
		return [self performSelector:getKeySEL];
	}
	
	// key
	SEL keySEL = NSSelectorFromString(key);
	if ([self respondsToSelector:keySEL]) {
		return [self performSelector:keySEL];
	}
    // isKey
    NSString *is_Key = [NSString stringWithFormat:@"is%@", key.capitalizedString];
    SEL isKeySEL = NSSelectorFromString(is_Key);
    if ([self respondsToSelector:isKeySEL]) {
        return [self performSelector:isKeySEL];
    }
    
    // _getKey
    NSString *_getKey = [NSString stringWithFormat:@"_get%@", key.capitalizedString];
    SEL _getKeySEL = NSSelectorFromString(_getKey);
    if ([self respondsToSelector:_getKeySEL]) {
        return [self performSelector:_getKeySEL];
    }
    
    // _key
    NSString *underlineKey = [NSString stringWithFormat:@"_%@", key];
    SEL _keySEL = NSSelectorFromString(underlineKey);
    if ([self respondsToSelector:_keySEL]) {
        return [self performSelector:_keySEL];
    }
	
	// getIsKey
	NSString *getIsKey = [NSString stringWithFormat:@"getIs%@", key.capitalizedString];
	SEL getIsKeySEL = NSSelectorFromString(getIsKey);
	if ([self respondsToSelector:getIsKeySEL]) {
		return [self performSelector:getIsKeySEL];
	}
	#pragma clang diagnostic pop

	// access instance variable method to check. If NO, throw an exception.
	if (![[self class] accessInstanceVariablesDirectly]) {
		NSException *exception = [NSException exceptionWithName:@"CL KVC"
														 reason:@"accessInstanceVariablesDirectly method returns NO"
													   userInfo:nil];
		@throw exception;
		return nil;
	}
	
	unsigned int outCount = 0;
	Ivar *ivars = class_copyIvarList([self class], &outCount);
	
	// _key
	NSString *_key = [NSString stringWithFormat:@"_%@", key];
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:_key]) {
			free(ivars);
			return [self valueWithIvar:ivar];
		}
	}
	
	// _isKey
	NSString *_isKey = [NSString stringWithFormat:@"_is%@", key.capitalizedString];
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:_isKey]) {
			free(ivars);
			return [self valueWithIvar:ivar];
		}
	}
	
	// key
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:key]) {
			free(ivars);
			return [self valueWithIvar:ivar];
		}
	}
	
	// isKey
	NSString *isKey = [NSString stringWithFormat:@"is%@", key.capitalizedString];
	for (int i = 0; i < outCount; i++) {
		Ivar ivar = ivars[i];
		const char *ivarName = ivar_getName(ivar);
		NSString *ivarKey = [NSString stringWithUTF8String:ivarName];
		if ([ivarKey isEqualToString:isKey]) {
			free(ivars);
			return [self valueWithIvar:ivar];
		}
	}

	free(ivars);
	return [self valueForUndefinedKey:key];
}

- (nullable id)valueWithIvar:(Ivar)ivar
{
	const char *ivarEncodingType = ivar_getTypeEncoding(ivar);
	NSString *ivarType = [NSString stringWithUTF8String:ivarEncodingType];
	ptrdiff_t ivarOffset = ivar_getOffset(ivar);
	
	// object type
	if ([ivarType hasPrefix:@"@"]) {
		return object_getIvar(self, ivar);
		// int type, return a NSNumber object
	} else if ([ivarType hasPrefix:@"i"]) {
		int intValue = *(int *)((uint8_t *)(__bridge void *)(self) + ivarOffset);
		return [NSNumber numberWithInt:intValue];
		// float type, return a NSNumber object
	} else if ([ivarType hasPrefix:@"f"]) {
		float floatValue = *(float *)((uint8_t *)(__bridge void *)(self) + ivarOffset);
		return [NSNumber numberWithFloat:floatValue];
		// double type, return a NSNumber object
	} else if ([ivarType hasPrefix:@"d"]) {
		CFTypeRef thisSelf = CFBridgingRetain(self);
		double doubleValue = *(double *)((uint8_t *)thisSelf + ivarOffset);
		CFBridgingRelease(thisSelf);
		return [NSNumber numberWithDouble:doubleValue];
		// other unresolved data types
	} else {
		NSString *exceptionReason = [NSString stringWithFormat:@"ivar type is %@, but it is undefined. See the official website for more details: https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1", ivarType];
		NSException *exception = [NSException exceptionWithName: @"CL_KVC cl_valueForKey: forKey:"
														 reason: exceptionReason
													   userInfo: nil];
		@throw exception;
		return nil;
	}
}

@end
