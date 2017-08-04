//
//  AppDelegate.h
//  Maps
//
//  Created by Alan Zhu on 4/8/17.
//  Copyright © 2017 Singapore Land Authority. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

