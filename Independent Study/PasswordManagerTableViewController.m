//
//  PasswordManagerTableViewController.m
//  Independent Study
//
//  Created by Anggi Arlandi Priatmadi on 12/1/13.
//  Copyright (c) 2013 Anggi. All rights reserved.
//

#import "PasswordManagerTableViewController.h"
#import "FMDatabase.h"
#import "AppDelegate.h"
#import "AccountCell.h"
#import "MyHTTPConnection.h"
#import "FMDatabase.h"
#import "FMResultSet.h"

@interface PasswordManagerTableViewController ()

@end

@implementation PasswordManagerTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    MyHTTPConnection *new = [[MyHTTPConnection alloc] init];
    [new setDelegate:self];
    [self reloadAccounts];
    
}

- (void)reloadAccounts
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    FMResultSet *results = [db executeQuery:@"SELECT * FROM passwords"];
    
    while([results next])
    {
        NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
        
        [item setValue:[results stringForColumn:@"id"] forKey:@"id"];
        [item setValue:[results stringForColumn:@"website"] forKey:@"website"];
        [item setValue:[results stringForColumn:@"username"] forKey:@"username"];
        [item setValue:[results stringForColumn:@"password"] forKey:@"password"];
        
        [groups addObject:item];
    }
    
    [db close];
    
    _passwords = groups;

}

-(NSString*) getDatabasePath
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.databasePath;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _passwords.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AccountCell" forIndexPath:indexPath];
    
    NSDictionary *account = _passwords[indexPath.row];
    
    cell.website.text = account[@"website"];
    cell.username.text = account[@"username"];
    cell.password.text = account[@"password"];
    
    return cell;
}

- (IBAction)Refresh:(id)sender{
    [self reloadAccounts];
    [self.tableView reloadData];
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableArray *groups = [(NSArray*)_passwords mutableCopy];
        
        NSDictionary *account = _passwords[indexPath.row];
        
        [self deleteAccount:account];
        
        [groups removeObjectAtIndex:indexPath.row];
        _passwords = groups;
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(BOOL) deleteAccount:(NSDictionary *) data
{
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"delete from passwords where id = ?;", [data valueForKey:@"id"]];
    
    [db close];
    
    NSLog(@"%d",success);
    
    return success;
    
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
