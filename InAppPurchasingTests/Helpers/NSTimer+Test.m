#import "NSTimer+Test.h"

@implementation NSTimer (Test)

static NSMutableArray *timers;
    
+ (void)initialize {
    timers = [NSMutableArray array];
}

+ (NSTimer*)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    NSTimer* timer = [NSTimer timerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    [timers addObject:timer];
    return timer;    
}

+ (int)timerCount {
    return [timers count];
}

+ (NSTimer*)lastTimer {
    return [timers lastObject];
}

@end