#import "NSTimer+Test.h"
// We know we're being bad and overriding methods implemented in the primary class but it's just for testing
#pragma GCC diagnostic ignored "-Wobjc-protocol-method-implementation"


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