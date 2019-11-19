//
//  ViewController.m
//  KVCDemo
//
//  Created by langke on 2019/11/19.
//  Copyright © 2019 langke. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+CLKVC.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.navigationController.navigationBar setTranslucent:NO];
	[self.view setBackgroundColor:[UIColor yellowColor]];
	[self triggerKVC];
}

- (void)triggerKVC
{
	static NSString *ageKey = @"age";
	Person *person = [[Person alloc] init];
	[person cl_setValue:@89.88 forKey:ageKey];
	id age = [person cl_valueForKey:ageKey];
	NSLog(@"age: %@", age);
	
	static NSString *nameKey = @"name";
	[person cl_setValue:@"langke" forKey:nameKey];
	id name = [person cl_valueForKey:nameKey];
	NSLog(@"name: %@", name);
}

@end
