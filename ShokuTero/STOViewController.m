//
//  STOViewController.m
//  ShokuTero
//
//  Created by himara2 on 2014/01/20.
//  Copyright (c) 2014年 himara2. All rights reserved.
//

#import "STOViewController.h"

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/AFNetworking.h>
#import <SVProgressHUD.h>

@interface STOViewController ()
{
    NSInteger _startIndex;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

static NSString *apiUrlFormat = @"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@$start=%d";

@implementation STOViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ramenBtnTouched:(id)sender {
    [self searchWithQuery:@"ramen"];
}

- (IBAction)sushiBtnTouched:(id)sender {
    [self searchWithQuery:@"sushi"];
}

- (IBAction)cakeBtnTouched:(id)sender {
    [self searchWithQuery:@"cake"];
}


- (void)searchWithQuery:(NSString *)query {
    [SVProgressHUD show];
    
    _startIndex = rand() % 10;
    NSString *fullApiUrl = [NSString stringWithFormat:apiUrlFormat, query, _startIndex];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue cancelAllOperations];
    
    NSMutableArray *imageUrls = [NSMutableArray array];
    
    [manager GET:fullApiUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *results = responseObject[@"responseData"][@"results"];
        NSLog(@"counts[%d]", [results count]);
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for (NSDictionary *result in results) {
//                NSLog(@"url[%@]", result[@"tbUrl"]);
                NSURL *url = [NSURL URLWithString:result[@"tbUrl"]];
                [imageUrls addObject:url];
            }
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        UIImage *compImage = [self compImages:imageUrls];
        _imageView.image = [self compFrame:compImage];
        
        [SVProgressHUD dismiss];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        [SVProgressHUD dismiss];
    }];

}


- (UIImage *)compImages:(NSArray *)imageUrls {
    UIGraphicsBeginImageContext(CGSizeMake(_imageView.frame.size.width, _imageView.frame.size.height));
    
    float x=0, y=0, w=160, h=160;
    
    for (int i=0; i<[imageUrls count]; i++) {
        NSData *data = [NSData dataWithContentsOfURL:imageUrls[i]];
        UIImage *img = [UIImage imageWithData:data];
    
        [img drawInRect:CGRectMake(x, y, w, h)];

        x += w;
        
        if (x >= 320) {
            x = 0;
            y += h;
        }
    
    }
    
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return capturedImage;
}


- (UIImage *)compFrame:(UIImage *)originImage {
    UIGraphicsBeginImageContext(CGSizeMake(_imageView.frame.size.width, _imageView.frame.size.height));
    
    float x=0, y=0, w=320, h=320;
    
//    UIImage *originImage = _imageView.image;
    [originImage drawInRect:CGRectMake(x, y, w, h)];
    
    UIImage *frameImage = [UIImage imageNamed:@"frame.png"];
    [frameImage drawInRect:CGRectMake(x, y, w, h)];
    
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return capturedImage;
    
}



@end
