//
//  AppDelegate.h
//  Independent Study
//
//  Created by Anggi Arlandi Priatmadi on 11/30/13.
//  Copyright (c) 2013 Anggi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;
@class HTTPServer;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    HTTPServer *httpServer;
    ViewController *viewController;
    NSString *address;
    NSString *databaseName;
    NSString *databasePath;
}

@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSString *databaseName;
@property (strong, nonatomic) NSString *databasePath;

@end
