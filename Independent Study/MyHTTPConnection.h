
#import "HTTPConnection.h"

@class MyHTTPConnection;

@protocol MyHTTPConnectionDelegate
@required
- (void)didReceiveNewAccount;
@end

@interface MyHTTPConnection : HTTPConnection <UIAlertViewDelegate>

@property (strong, nonatomic) NSString *status;
@property (weak, nonatomic) id<MyHTTPConnectionDelegate> delegate;

@end