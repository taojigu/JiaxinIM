//
//  JXWebViewController.m
//

#import "JXWebViewController.h"
#import "JXHUD.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface JXWebViewController ()<UIWebViewDelegate, UIDocumentInteractionControllerDelegate>
@property(nonatomic, strong) UIWebView *webView;
@end

@implementation JXWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupDefaultLeftButtonItem];
    if (self.title.length == 0) {
        self.title = self.netString;
    }
    if (self.netString) {
        NSString *netString = [NSString stringWithFormat:@"%@", self.netString];
        NSURL *url = [NSURL URLWithString:netString];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        CGRect frame = self.view.bounds;
        frame.size.height -= 64;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
        webView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:webView];
        self.webView = webView;
        self.webView.delegate = self;
        [webView loadRequest:request];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showMessageWithActivityIndicator:JXUIString(@"loading")];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self hideHUD];
}

- (void)popSelf {
    if (self.isModal) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [super popSelf];
    }
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHUD];
    if (self.webView) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"window.close = function () { "
                                                             @"location.href = "
                                                             @"'jiaxin://window.close'; }"];
        JSContext *context =
                [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        context[@"window"][@"alert"] = ^(JSValue *message) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:JXUIString(@"tips title")
                                                            message:[message toString]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];

            [alert show];
        };
    }
}

- (BOOL)webView:(UIWebView *)webView
        shouldStartLoadWithRequest:(NSURLRequest *)request
                    navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = request.URL.absoluteString;
    NSString *scheme = @"jiaxin://";
    if ([urlString hasPrefix:scheme]) {
        NSString *function = [urlString substringFromIndex:scheme.length];
        if ([function isEqualToString:@"window.close"]) {
            [self popSelf];
        }
        return NO;
    }
    return YES;
}

@end
