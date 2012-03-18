#import <Cedar-iOS/SpecHelper.h>
#import <OCMock/OCMock.h>
#import "IAPStoreManager+Test.h"
#import "IAPCatalogue.h"
#import "NSTimer+Test.h"

using namespace Cedar::Matchers;

SPEC_BEGIN(IAPStoreManagerSpec)

describe(@"IAPStoreManager", ^{
    __block IAPStoreManager* storeManager;
    
    beforeEach(^{
        storeManager = [[IAPStoreManager alloc] init];
    });
    
    describe(@"autoUpdate", ^{
        __block NSTimer* timer;
        
        beforeEach(^{
            [storeManager autoUpdate];
            timer = [NSTimer lastTimer];
        });
        
        it(@"should check that the catalogue hasn't expired at regular intervals", ^{
            BOOL timerStarted = timer != nil;
            expect(timerStarted).to(be_truthy());
        });
        
        it(@"should quickly attempt to update the catalogue if it has expired", ^{            
            id mockExpiredCatalogue = [OCMockObject mockForClass:[IAPCatalogue class]];
            NSTimeInterval aboutTwoMonthsAgo = 60 * 60 * 24 * 60;
            NSDate* oldDate = [NSDate dateWithTimeIntervalSinceNow:aboutTwoMonthsAgo];
            [[mockExpiredCatalogue expect] update:storeManager];
            [[[mockExpiredCatalogue stub] andReturn:oldDate] lastUpdatedAt];
            [storeManager setCatalogue:mockExpiredCatalogue];
            [timer fire];
            [mockExpiredCatalogue verify];
        });        

        it(@"should not attempt to update the catalogue if it has expired", ^{            
            id mockExpiredCatalogue = [OCMockObject mockForClass:[IAPCatalogue class]];
            NSDate* now = [NSDate dateWithTimeIntervalSinceNow:0];
            [[mockExpiredCatalogue reject] update:storeManager];
            [[[mockExpiredCatalogue stub] andReturn:now] lastUpdatedAt];
            [storeManager setCatalogue:mockExpiredCatalogue];
            [timer fire];
            [mockExpiredCatalogue verify];
        });        
    });
});

SPEC_END