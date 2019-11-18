//
//  ViewController.m
//  KVCDemo
//
//  Created by chenlong on 2019/11/18.
//  Copyright © 2019 langke. All rights reserved.
//

#import "ViewController.h"
#import "NSObject+CLKVC.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self triggerKVC];
}

- (void)triggerKVC
{
	Person *person = [[Person alloc] init];
	[person cl_setValue:@89.88 forKey:@"age"];
	id age = [person cl_valueForKey:@"age"];
	NSLog(@"age: %@", age);
	
	[person cl_setValue:@"langke" forKey:@"name"];
	id name = [person cl_valueForKey:@"name"];
	NSLog(@"name: %@", name);
}

@end
