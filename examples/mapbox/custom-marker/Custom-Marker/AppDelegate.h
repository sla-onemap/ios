//
//  AppDelegate.h
//  Custom-Marker
//
//  Created by Alan Zhu on 17/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

