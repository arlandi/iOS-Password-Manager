//
//  PasswordManagerTableViewController.h
//  Independent Study
//
//  Created by Anggi Arlandi Priatmadi on 12/1/13.
//  Copyright (c) 2013 Anggi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyHTTPConnection.h"

@interface PasswordManagerTableViewController : UITableViewController <MyHTTPConnectionDelegate>{
    NSArray *passwords;
}

@property (strong, nonatomic) NSArray *passwords;
- (IBAction)Refresh:(id)sender;

@end
