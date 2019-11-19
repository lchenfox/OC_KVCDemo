//
//  AppDelegate.m
//  KVCDemo
//
//  Created by langke on 2019/11/19.
//  Copyright © 2019 langke. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

#define KVC_TITLE @"Welcome to KVC"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	[self createWindow];
	return YES;
}

- (void)createWindow
{
	self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
	self.window.backgroundColor = [UIColor whiteColor];
	ViewController *vc = [[ViewController alloc] init];
	vc.title = KVC_TITLE;
	UINavigationController *rootNC = [[UINavigationController alloc] initWithRootViewController:vc];
	self.window.rootViewController = rootNC;
	[self.window makeKeyAndVisible];
}

@end
