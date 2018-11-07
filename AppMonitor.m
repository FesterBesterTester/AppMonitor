//
//  AppMonitor.m
//  Meow Soundboard
//
//  Created by Randall Salvo on 10/20/2018.
//  Copyright © 2018 Candoran LLC. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "AppMonitor.h"

#define APP_RUNCOUNT @"APPMONITOR_APP_RUNCOUNT"
#define APP_RUNTIME @"APPMONITOR_APP_RUNTIME"
#define APP_TAPS @"APPMONITOR_TAPS"

@interface AppMonitor ()
@property (strong, nonatomic) NSDate *startTime;
@end

@implementation AppMonitor

static AppMonitor *sharedAppMonitor = nil;
static condition_block_t _cond = nil;
static action_block_t _acti = nil;


- (void)addAction:(action_block_t)action forCondition:(condition_block_t)condition;
{
    NSAssert(nil == _cond && nil == _acti, @"AppMonitor conditional action already set.");
    _cond = condition;
    _acti = action;
}


- (void)doConditionalActions
{
    if ((_cond && _acti) && _cond())
    {
        _acti();
    }
}


// AppMonitor is a singleton. Access it via [AppMonitor sharedInstance] rather than [[AppMonitor alloc] init]
- (id)init
{
    NSAssert(nil == sharedAppMonitor,
             @"AppMonitor is a singleton. Access it via [AppMontior sharedInstance] rather than [[AppMonitor alloc] init]");

    self = [super init];
    if (self)
    {
        _startTime = [NSDate date];
    }
    return self;
}


- (NSInteger)cumulativeAppRunTime
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:APP_RUNTIME];
}


- (NSInteger)currentInstanceRunTime
{
    return (NSInteger)(_startTime.timeIntervalSinceNow * -1);
}


- (void)logTap
{
    @synchronized ([AppMonitor class])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        [defaults setInteger:self.cumulativeAppTaps + 1 forKey:APP_TAPS];
        [defaults synchronize];
    }
    [self doConditionalActions];
}


- (id)objectForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}


- (void)setObject:(id)value forKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    @synchronized ([AppMonitor class])
    {
        [defaults setObject:value forKey:key];
    }
}


- (NSInteger)runCount
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:APP_RUNCOUNT];
}


- (void)start
{
    _startTime = [NSDate date];
}


- (void)stop
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    @synchronized ([AppMonitor class])
    {
        [defaults setInteger:self.runCount + 1 forKey:APP_RUNCOUNT];
        [defaults setInteger:self.cumulativeAppRunTime + self.currentInstanceRunTime forKey:APP_RUNTIME];
        [defaults synchronize];
    }
}

- (NSInteger)cumulativeAppTaps
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults integerForKey:APP_TAPS];
}


// This is a singleton class. Access it through sharedInstance.
+ (AppMonitor*)sharedInstance
{
    if (nil == sharedAppMonitor)
    {
        @synchronized ([AppMonitor class])
        {
            AppMonitor *monitor = [[super allocWithZone:NULL] init];
            if (nil == sharedAppMonitor)
            {
                sharedAppMonitor = monitor;
            }
        }
    }
    return sharedAppMonitor;
}


// Needed to make this a singleton class. Access it through sharedInstance.
+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedInstance];
}


// Needed to make this a singleton class. Access it through sharedInstance.
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}


@end
