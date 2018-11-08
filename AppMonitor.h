//
//  AppMonitor.h
//  Meow Soundboard
//
//  Created by Randall Salvo on 10/20/2018.
//  Copyright © 2018 Candoran LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef bool (^condition_block_t)(void);
typedef void (^action_block_t)(void);

@interface AppMonitor : NSObject
@property (readonly) NSInteger cumulativeAppRunTime;
@property (readonly) NSInteger currentInstanceRunTime;
@property (readonly) NSInteger runCount;
@property (readonly) NSInteger cumulativeAppTaps;

+ (AppMonitor*)sharedInstance;

- (void)addAction:(action_block_t)action forCondition:(condition_block_t)condition;
- (void)doConditionalActions;
- (void)logTap;
- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key;
- (void)start;
- (void)stop;

@end
