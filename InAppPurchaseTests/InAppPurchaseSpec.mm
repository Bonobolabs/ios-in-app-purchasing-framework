#import <Cedar-iOS/SpecHelper.h>
#import "IAPCatalogue.h"
#import "SKProductsRequest+Test.h"
#import "MockIAPCatalogueDelegate.h"


using namespace Cedar::Matchers;

SPEC_BEGIN(InAppPurchaseSpec)

describe(@"IAPCatalogue", ^{
    __block IAPCatalogue *catalogue;
    __block id mockDelegate;
    
    beforeEach(^{
        [SKProductsRequest resetAll];
        catalogue = [[IAPCatalogue alloc] init];
        // OCMock was buggy for this use case
        mockDelegate = [[MockIAPCatalogueDelegate alloc] init]; 
    });
    
    describe(@"loadProducts", ^{
        __block SKProductsRequest* request;
        
        beforeEach(^{
            [catalogue load:mockDelegate];
            request = [SKProductsRequest lastRequest];
        });
        
        it(@"should request the products from Apple", ^{
            int requestCount = [SKProductsRequest requestCount];
            BOOL wasStarted = [request wasStarted];
            expect(requestCount).to(equal(1));
            expect(wasStarted).to(be_truthy());
        });
        
        describe(@"on success", ^{            
            it(@"should pass along the products, and notify the delegate when the load has completed", ^{
                NSArray* products = [NSArray array];
                [request respondSuccess:products];
                BOOL notifiedDidLoadProducts = [mockDelegate notifiedIAPCatalogue:catalogue didLoadProducts:products];
                BOOL notifiedDidFinishLoading = [mockDelegate notifiedIAPCatalogueDidFinishLoading:catalogue];
                expect(notifiedDidLoadProducts).to(be_truthy());
                expect(notifiedDidFinishLoading).to(be_truthy());
            });                        
        });
        
        describe(@"on cache hit", ^{
            it(@"should pass along the cached products, followed by fresh products and notify the delegate when the load has completed", ^{                
                NSArray* products = [NSArray array];
                [request respondSuccess:products]; // Prime cache
                // Reset mockDelegate
                mockDelegate = [[MockIAPCatalogueDelegate alloc] init]; 
                [catalogue load:mockDelegate];
                [request respondSuccess:products];
                BOOL notifiedDidLoadProductsFromCache = [mockDelegate notifiedIAPCatalogue:catalogue didLoadProductsFromCache:products];
                BOOL notifiedDidFinishLoading = [mockDelegate notifiedIAPCatalogueDidFinishLoading:catalogue];
                BOOL notifiedDidLoadProducts = [mockDelegate notifiedIAPCatalogue:catalogue didLoadProducts:products];
                expect(notifiedDidLoadProductsFromCache).to(be_truthy());
                expect(notifiedDidLoadProducts).to(be_truthy());
                expect(notifiedDidFinishLoading).to(be_truthy());
            });                        
        });
        
        describe(@"on error", ^{
            it(@"should pass along the error and notify the delegate when the load has completed", ^{
                NSError* error = [request respondError:@"Oh no an error is happening!"];
                BOOL notifiedDidFailWithError = [mockDelegate notifiedIAPCatalogue:catalogue didFailWithError:error];
                BOOL notifiedDidFinishLoading = [mockDelegate notifiedIAPCatalogueDidFinishLoading:catalogue];
                expect(notifiedDidFailWithError).to(be_truthy());
                expect(notifiedDidFinishLoading).to(be_truthy());
            });  
        });
        
        describe(@"on cancel", ^{
            it(@"should not notify the delegate that the load has completed", ^{
                NSArray* products = [NSArray array];
                [catalogue cancel];
                [request respondSuccess:products];
                NSError* error = [request respondError:@"Oh no an error is happening!"];
                BOOL notifiedDidFailWithError = [mockDelegate notifiedIAPCatalogue:catalogue didFailWithError:error];
                BOOL notifiedDidFinishLoading = [mockDelegate notifiedIAPCatalogueDidFinishLoading:catalogue];
                expect(notifiedDidFailWithError).to_not(be_truthy());
                expect(notifiedDidFinishLoading).to_not(be_truthy());
            });
        });    
    });
});

SPEC_END