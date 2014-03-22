#import "MyHTTPConnection.h"
#import "HTTPMessage.h"
#import "HTTPDataResponse.h"
#import "DDNumber.h"
#import "HTTPLogging.h"
#import "UIAlertView+Blocks.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "AppDelegate.h"
#import "PasswordManagerTableViewController.h"
#import "FMDatabaseAdditions.h"

// Log levels : off, error, warn, info, verbose
// Other flags: trace
static const int httpLogLevel = HTTP_LOG_LEVEL_WARN; // | HTTP_LOG_FLAG_TRACE;


/**
 * All we have to do is override appropriate methods in HTTPConnection.
 **/

@implementation MyHTTPConnection

- (BOOL)supportsMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Add support for POST
	
	if ([method isEqualToString:@"POST"])
	{
		if ([path isEqualToString:@"/post.html"])
		{
			// Let's be extra cautious, and make sure the upload isn't 5 gigs
			
			return true;
		}
        if ([path isEqualToString:@"/test.html"])
		{
			return true;
		}
        if ([path isEqualToString:@"/addnewpass.html"]) {
            return true;
        }
        if ([path isEqualToString:@"/check.html"]) {
            return true;
        }
	}
	
	return [super supportsMethod:method atPath:path];
}

- (BOOL)expectsRequestBodyFromMethod:(NSString *)method atPath:(NSString *)path
{
	HTTPLogTrace();
	
	// Inform HTTP server that we expect a body to accompany a POST request
	
	if([method isEqualToString:@"POST"])
		return YES;
	
	return [super expectsRequestBodyFromMethod:method atPath:path];
}

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
	HTTPLogTrace();
	
	if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/post.html"])
	{
		HTTPLogVerbose(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSData *response = nil;
        NSData *postData = [request body];
        
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:postData options:0 error:NULL];
        
        /*
        if([_status isEqualToString:@"yes"]){
            response = [@"yes" dataUsingEncoding:NSUTF8StringEncoding];
            [self insertCustomer:parsedObject];
            return [[HTTPDataResponse alloc] initWithData:response];
        }else{
            response = [@"no" dataUsingEncoding:NSUTF8StringEncoding];
            return [[HTTPDataResponse alloc] initWithData:response];
        }*/
        
        response = [@"{\"response\":1}" dataUsingEncoding:NSUTF8StringEncoding];
        [self insertCustomer:parsedObject];
        return [[HTTPDataResponse alloc] initWithData:response];
		
	}
    
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/check.html"])
	{
		HTTPLogVerbose(@"%@[%p]: postContentLength: %qu", THIS_FILE, self, requestContentLength);
		
		NSData *response = nil;
        NSData *postData = [request body];
        
        NSDictionary *parsedObject = [NSJSONSerialization JSONObjectWithData:postData options:0 error:NULL];
        
        BOOL check = [self checkForDomain:parsedObject];
        
        if (check) {
            
            NSMutableArray *accounts = [self getAccountForDomain:parsedObject];
            
            NSMutableDictionary *status = [[NSMutableDictionary alloc] init];
            
            [status setValue:@1 forKey:@"response"];
            
            [accounts insertObject:status atIndex:0];
            
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:accounts
                                                               options:0
                                                                 error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            NSLog(@"%@",jsonString);
            
            response = jsonData;
        }else{
            response = [@"[{\"response\":0}]" dataUsingEncoding:NSUTF8StringEncoding];
        }
        return [[HTTPDataResponse alloc] initWithData:response];
		
	}
    
    if ([method isEqualToString:@"POST"] && [path isEqualToString:@"/test.html"]) {
        NSData *response = nil;
        NSString *postStr = nil;
        NSData *postData = [request body];
		if (postData)
		{
			postStr = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
		}
        
        NSLog(@"%@",postStr);
        
        [self performSelectorOnMainThread:@selector(showAlertWithTitle:)
                               withObject:@"Here comes the title"
                            waitUntilDone:YES];
        
        if([_status isEqualToString:@"yes"]){
            response = [@"yes" dataUsingEncoding:NSUTF8StringEncoding];
        }else{
            response = [@"no" dataUsingEncoding:NSUTF8StringEncoding];
        }
		return [[HTTPDataResponse alloc] initWithData:response];
    }
	
	return [super httpResponseForMethod:method URI:path];
}

-(BOOL) insertCustomer:(NSDictionary *) data
{
    // insert customer into database
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"INSERT INTO passwords (website,username,password) VALUES (?,?,?);", [data valueForKey:@"website"], [data valueForKey:@"username"], [data valueForKey:@"password"]];
    
    [db close];
    
    return success;
    
}

-(NSMutableArray *) getAccountForDomain:(NSDictionary *) data
{
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    FMResultSet *results = [db executeQuery:@"select * from passwords where website = ?", [data valueForKey:@"domain"]];
    
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
    
    return groups;
    
}

- (BOOL) checkForDomain:(NSDictionary *)data
{
    
    NSLog(@"%@",[data valueForKey:@"domain"]);
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDatabasePath]];
    
    [db open];
    
    //FMResultSet *rs = [db executeQuery:@"select * from passwords where website = ?", [data valueForKey:@"domain"]];
    
    NSUInteger count = [db intForQuery:@"select count(website) from passwords where website = ?", [data valueForKey:@"domain"]];
    
    /*
    while ([rs next]) {
        NSLog(@"%@",[rs stringForColumn:@"username"]);
    }*/
    
    //[rs close];
    [db close];
    
    if (count > 0) {
        return true;
    }else{
        return false;
    }
}

-(NSString*) getDatabasePath
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return appDelegate.databasePath;
}

- (void)showAlertWithTitle:(NSString *)t
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm PC Connect"
                                                    message:@"Please confirm that you're connecting to a PC"
                                                   delegate:nil // Can be another value but will be overridden when showing with handler.
                                          cancelButtonTitle:@"Confirm"
                                          otherButtonTitles:@"Cancel", nil];
    
    [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == [alertView cancelButtonIndex]) {
            _status = @"yes";
            
        } else {
            _status = @"no";
        }
    }];
    
    NSRunLoop *rl = [NSRunLoop currentRunLoop];
    NSDate *d;
    while ([alert isVisible]) {
        d = [[NSDate alloc] init];
        [rl runUntilDate:d];
    }
}

- (void)prepareForBodyWithSize:(UInt64)contentLength
{
	HTTPLogTrace();
	
	// If we supported large uploads,
	// we might use this method to create/open files, allocate memory, etc.
}

- (void)processBodyData:(NSData *)postDataChunk
{
	HTTPLogTrace();
	
	// Remember: In order to support LARGE POST uploads, the data is read in chunks.
	// This prevents a 50 MB upload from being stored in RAM.
	// The size of the chunks are limited by the POST_CHUNKSIZE definition.
	// Therefore, this method may be called multiple times for the same POST request.
	
	BOOL result = [request appendData:postDataChunk];
	if (!result)
	{
		HTTPLogError(@"%@[%p]: %@ - Couldn't append bytes!", THIS_FILE, self, THIS_METHOD);
	}
}

@end
