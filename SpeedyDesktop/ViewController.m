//
//  ViewController.m
//  SpeedyDesktop
//
//  Created by liajinfei on 15/8/26.
//  Copyright (c) 2015年 liajinfei. All rights reserved.
//

#import "ViewController.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"

// Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
@interface ViewController ()

@property (nonatomic,strong)HTTPServer *httpServer;

@end

@implementation ViewController

- (void)dealloc
{
    // 停止服务
    [_httpServer stop];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)startServer
{
    // Start the server (and check for problems)
    
    NSError *error;
    if([_httpServer start:&error])
    {
        DDLogInfo(@"Started HTTP Server on port %hu", [_httpServer listeningPort]);
        
        // open the url.
        NSString *urlStrWithPort = [NSString stringWithFormat:@"http://localhost:%d",[_httpServer listeningPort]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStrWithPort]];
    }
    else
    {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
}


- (IBAction)action:(id)sender
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    _httpServer = [[HTTPServer alloc] init];
    [_httpServer setType:@"_http._tcp."];
    NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Web"];
    
    DDLogInfo(@"Setting document root: %@", webPath);
    
    [_httpServer setDocumentRoot:webPath];
    
    [self startServer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
