//
//  BusinessVC.m
//  JoinShow
//
//  Created by Heaven on 13-10-31.
//  Copyright (c) 2013年 Heaven. All rights reserved.
//

#import "BusinessVC.h"



#import "XYExternal.h"

#import "RubyChinaNodeEntity.h"


@implementation BusinessVCRequest
+(id) defaultSettings{
    // 参考
    BusinessVCRequest *eg = [[[BusinessVCRequest alloc] initWithHostName:@"www.ruby-china.org" customHeaderFields:@{@"x-client-identifier" : @"iOS"}] autorelease];
    eg.freezable = YES;
    eg.forceReload = YES;
    return eg;
}
@end


@interface BusinessVC ()
// get
@property (nonatomic, retain) RequestHelper *networkEngine;
@property (nonatomic, retain) NSArray *model;

@end

@implementation BusinessVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.networkEngine = [BusinessVCRequest defaultSettings];
        [_networkEngine useCache];
    }
    return  self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}
- (void)dealloc
{
    NSLogDD;
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickStart:(id)sender {
    for (int i = 0; i < 6; i++) {
        UILabel *label = (UILabel *)[self.view viewWithTag:i + 10000];
        label.textColor = [UIColor blueColor];
    }
    
   [self performSelector:@selector(start) withObject:nil afterDelay:1];
    
    
    }

- (IBAction)clickLoad:(id)sender {
    UITextField *textField = (UITextField *)[self.view viewWithTag:11000];
    [self.view endEditing:YES];
    
    RubyChinaNodeEntity *anObject = [[RubyChinaNodeEntity alloc] init];
    anObject.nodeID = [textField.text intValue];
    [anObject loadFromDB];
    NSString *str = [anObject YYJSONString];
    SHOWMBProgressHUD(@"Data", str, nil, NO, 3);
    [anObject release];
}


-(void) start{
    UILabel *label = (UILabel *)[self.view viewWithTag:0 + 10000];
    label.textColor = [UIColor redColor];
    [self performSelector:@selector(httpGET) withObject:nil afterDelay:1];
}
-(void) httpGET{
    UILabel *label = (UILabel *)[self.view viewWithTag:1 + 10000];
    label.textColor = [UIColor redColor];
    __block id myself =self;
    MKNetworkOperation *mk = [self.networkEngine get:@"api/nodes.json" params:nil succeed:^(MKNetworkOperation *op) {
        UILabel *label = (UILabel *)[self.view viewWithTag:2 + 10000];
        label.textColor = [UIColor redColor];
        
        if([op isCachedResponse]) {
             NSLog(@"Data from cache %@", [op responseString]);
            [myself parseData:[op responseString] isCachedResponse:YES];
        }
        else {
              NSLog(@"Data from server %@", [op responseString]);
            [myself parseData:[op responseString] isCachedResponse:NO];
        }
    } failed:^(MKNetworkOperation *op, NSError *err) {
        NSString *str = [NSString stringWithFormat:@"MKNetwork request error : %@", [err localizedDescription]];
        NSLogD(@"%@", str);
        
        // SHOWMBProgressHUD(@"Message", str, nil, NO, 3);
        [self loadFromDBProcess];
    }];

    [self.networkEngine submit:mk];
}
-(void) parseData:(NSString *)str isCachedResponse:(BOOL)isCachedResponse{
    UILabel *label = (UILabel *)[self.view viewWithTag:3 + 10000];
    label.textColor = [UIColor redColor];
    
    self.model = [str toModels:[RubyChinaNodeEntity class]];
    
    [self performSelector:@selector(refreshUI) withObject:nil afterDelay:1];
    
    if (isCachedResponse) {
        ;
    }else{
        [self performSelector:@selector(saveToDBProcess) withObject:nil afterDelay:1];
    }
}
-(void) saveToDBProcess{
    UILabel *label = (UILabel *)[self.view viewWithTag:4 + 10000];
    label.textColor = [UIColor redColor];
    PERF_ENTER_( saveAllToDB )
    [self.model saveAllToDB];
    PERF_LEAVE_( saveAllToDB )
}
-(void) refreshUI{
    UILabel *label = (UILabel *)[self.view viewWithTag:5 + 10000];
    label.textColor = [UIColor redColor];
    
    if (self.model && self.model.count > 0) {
        NSString *str = [[self.model objectAtIndex:0] YYJSONString];
        SHOWMBProgressHUD(@"Data", str, nil, NO, 3);
    }
}
-(void) loadFromDBProcess{
    self.model = [NSArray loadFromDBWithClass:[RubyChinaNodeEntity class]];
    
    [self performSelector:@selector(refreshUI) withObject:nil afterDelay:1];
}
@end
