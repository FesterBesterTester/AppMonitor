//
//  ViewController.m
//  tests
//
//  Created by Randall Salvo on 11/7/18.
//  Copyright © 2018 Candoran LLC. All rights reserved.
//

#import "ViewController.h"
#import "AppMonitor.h"


@interface ViewController ()
@property (strong, nonatomic) IBOutlet UILabel *runCount;
@property (strong, nonatomic) IBOutlet UILabel *cumulativeAppTaps;
@property (strong, nonatomic) IBOutlet UILabel *cumulativeAppRunTime;
@property (strong, nonatomic) IBOutlet UILabel *currentInstanceRunTime;

@end

@implementation ViewController

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/* Handle tap like a browser back button */
- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [AppMonitor.sharedInstance logTap];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [tap setNumberOfTapsRequired:1];
    [tap setNumberOfTouchesRequired:1];
    [self.view addGestureRecognizer:tap];
    [tap setDelegate:self];

    action_block_t actionBlock = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.runCount setText:[[NSString alloc] initWithFormat:@"runCount: %ld", (long)AppMonitor.sharedInstance.runCount]];
            [self.cumulativeAppTaps setText:[[NSString alloc] initWithFormat:@"cumulativeAppTaps: %ld", (long)AppMonitor.sharedInstance.cumulativeAppTaps]];
            [self.cumulativeAppRunTime setText:[[NSString alloc] initWithFormat:@"cumulativeAppRunTime: %ld", (long)AppMonitor.sharedInstance.cumulativeAppRunTime]];
            [self.currentInstanceRunTime setText:[[NSString alloc] initWithFormat:@"currentInstanceRunTime: %ld", (long)AppMonitor.sharedInstance.currentInstanceRunTime]];
        });
    };

    condition_block_t conditionBlock = ^{
        return (bool)true;
    };
    
    [AppMonitor.sharedInstance addAction:actionBlock
                            forCondition:conditionBlock];
}


@end
