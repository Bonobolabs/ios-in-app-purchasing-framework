#import <Cedar-iOS/SpecHelper.h>
#import <OCMock/OCMock.h>
#import "IAPCatalogue+Test.h"
#import "IAPProduct+Test.h"
#import "SKProductsRequest+Test.h"
#import "MockIAPCatalogueDelegate.h"
#import "SKProduct+PriceWithCurrency.h"


using namespace Cedar::Matchers;

SPEC_BEGIN(IAPCatalogueSpec)

describe(@"IAPCatalogue", ^{
    __block IAPCatalogue *catalogue;
    __block id mockDelegate;
    __block NSArray* productIdentifiers;
    
    beforeEach(^{
        [SKProductsRequest resetAll];
        catalogue = [[IAPCatalogue alloc] init];
        // OCMock was buggy for this use case
        mockDelegate = [[MockIAPCatalogueDelegate alloc] init]; 
        NSString *path = [[NSBundle mainBundle] pathForResource:@"IAPInfo" ofType:@"plist"];
        NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:path];
        productIdentifiers = [plist objectForKey:@"products"];
    });
    
    describe(@"productForKey", ^{
        it(@"should return nil for an invalid identifier", ^{
            NSString* invalidIdentifier = @"";
            IAPProduct* product = [catalogue productForIdentifier:invalidIdentifier];
            BOOL isProductInvalid = product == nil;
            expect(isProductInvalid).to(be_truthy());
        });
        
        it(@"should return a product for a valid identifier", ^{\
            NSString* validIdentifier = [productIdentifiers objectAtIndex:0]; 
            IAPProduct* product = [catalogue productForIdentifier:validIdentifier];
            BOOL isProductValid = product != nil;
            expect(isProductValid).to(be_truthy());
        });
    });
    
    describe(@"update", ^{
        __block SKProductsRequest* request;
        __block NSSet* requestedProductIdentifiers;
        
        beforeEach(^{
            [catalogue update:mockDelegate];
            request = [SKProductsRequest lastRequest];
            requestedProductIdentifiers = [SKProductsRequest lastProductIdentifiers];
        });
        
        it(@"should request the products from Apple", ^{
            int requestCount = [SKProductsRequest requestCount];
            BOOL wasStarted = [request wasStarted];
            expect(requestCount).to(equal(1));
            expect(wasStarted).to(be_truthy());
        });
        
        it(@"should request the configured set of product identifiers", ^{
            NSSet* configuredProductIdentifiers = [NSSet setWithArray:productIdentifiers];
            BOOL configuredAndRequestedIdentifiersEqual = [configuredProductIdentifiers isEqualToSet:requestedProductIdentifiers];            
            expect(configuredAndRequestedIdentifiersEqual).to(be_truthy());
        });
        
        describe(@"on success", ^{            
            it(@"should notify the delegate when the update has completed", ^{
                NSArray* products = [NSArray array];
                [request respondSuccess:products];
                BOOL notifiedDidUpdate = [mockDelegate notifiedIAPCatalogueDidUpdate:catalogue];
                BOOL notifiedDidFinishUpdating = [mockDelegate notifiedIAPCatalogueDidFinishUpdating:catalogue];
                expect(notifiedDidUpdate).to(be_truthy());
                expect(notifiedDidFinishUpdating).to(be_truthy());
            });   
            
            it(@"should update the catalogue with the product details", ^{
                NSString* priceWithCurrency = @"$1.99";
                NSString* productIdentifier = [requestedProductIdentifiers anyObject];
                id mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
                [[[mockSKProduct stub] andReturn:priceWithCurrency] priceWithCurrency];
                [[[mockSKProduct stub] andReturn:productIdentifier] productIdentifier];
                NSArray* products = [NSArray arrayWithObject:mockSKProduct];
                [request respondSuccess:products];
                IAPProduct* updatedProduct = [catalogue productForIdentifier:productIdentifier];
                BOOL samePrice = updatedProduct.price == [mockSKProduct priceWithCurrency];
                expect(samePrice).to(be_truthy());                
            });
            
            it(@"should update the last updated date", ^{
                NSArray* products = [NSArray array];
                NSDate* dateBefore = catalogue.lastUpdatedAt;
                [request respondSuccess:products];
                NSDate* dateAfter = catalogue.lastUpdatedAt;
                BOOL lastUpdatedAtChanged = ![dateAfter isEqualToDate:dateBefore];
                expect(lastUpdatedAtChanged).to(be_truthy());
            });
        });
        
        describe(@"on error", ^{
            it(@"should pass along the error and notify the delegate when the load has completed", ^{
                NSError* error = [request respondError:@"Oh no an error is happening!"];
                BOOL notifiedUpdateFailedWithError = [mockDelegate notifiedIAPCatalogue:catalogue updateFailedWithError:error];
                BOOL notifiedDidFinishUpdating = [mockDelegate notifiedIAPCatalogueDidFinishUpdating:catalogue];
                expect(notifiedUpdateFailedWithError).to(be_truthy());
                expect(notifiedDidFinishUpdating).to(be_truthy());
            });  
        });
        
        describe(@"on cancel", ^{
            it(@"should not notify the delegate that the load has completed", ^{
                NSArray* products = [NSArray array];
                [catalogue cancel];
                [request respondSuccess:products];
                NSError* error = [request respondError:@"Oh no an error is happening!"];
                BOOL notifiedUpdateFailedWithError = [mockDelegate notifiedIAPCatalogue:catalogue updateFailedWithError:error];
                BOOL notifiedDidFinishUpdating = [mockDelegate notifiedIAPCatalogueDidFinishUpdating:catalogue];
                expect(notifiedUpdateFailedWithError).to_not(be_truthy());
                expect(notifiedDidFinishUpdating).to_not(be_truthy());
            });
        });
    });
    
    describe(@"purchaseProduct:", ^{
        __block id mockPaymentQueue;
        __block id mockProduct;
        __block id mockSKProduct;
        __block id mockTransaction;
        __block NSArray* mockTransactions;
        
        beforeEach(^{
            mockProduct = [OCMockObject mockForClass:[IAPProduct class]];
            [[[mockProduct stub] andReturn:@"com.iap.product1"] identifier];
            NSDictionary* mockProducts = [NSDictionary dictionaryWithObject:mockProduct forKey:@"com.iap.product1"];
            catalogue.products = mockProducts;
            mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
            [[[mockSKProduct stub] andReturn:@"com.iap.product1"] productIdentifier];
            mockPaymentQueue = [OCMockObject niceMockForClass:[SKPaymentQueue class]];
            catalogue.paymentQueue = mockPaymentQueue;
            mockTransaction = [OCMockObject mockForClass:[SKPaymentTransaction class]];
            id mockSKPayment = [OCMockObject mockForClass:[SKPayment class]];
            [[[mockSKPayment stub] andReturn:@"com.iap.product1"] productIdentifier];
            [[[mockTransaction stub] andReturn:mockSKPayment] payment];
            mockTransactions = [NSArray arrayWithObject:mockTransaction];
        });
                
        it(@"should raise an exception if the product hasn't been loaded from Apple yet", ^{
            BOOL raised = NO;
            try {
                [catalogue purchaseProduct:mockProduct];
            }
            catch(NSException* e) {
                raised = YES;
            }
            // Cedar expect(^{}).to(raise_exception) wasn't working for me
            expect(raised).to(be_truthy);
        });
        
        it(@"should send the purchase request to Apple and update the product with the payment info if the product has been loaded from Apple", ^{
            NSArray* mockSKProducts = [NSArray arrayWithObject:mockSKProduct];
            [[mockPaymentQueue expect] addPayment:[OCMArg isNotNil]];
            [[mockProduct expect] updateWithSKPayment:[OCMArg isNotNil]];
            [[mockProduct expect] updateWithSKProduct:[OCMArg isNotNil]];
            [catalogue updateProducts:mockSKProducts];
            [catalogue purchaseProduct:mockProduct];
            [mockPaymentQueue verify];
            [mockProduct verify];
        });
        
        describe(@"on success", ^{
            it(@"should update the product using the transaction given by apple and finish the transaction", ^ {
                int transactionState = SKPaymentTransactionStatePurchased;
                [[[mockTransaction stub] andReturn:OCMOCK_VALUE(transactionState)] transactionState]; 
                [[mockProduct expect] updateWithSKPaymentTransaction:mockTransaction];
                [[mockPaymentQueue expect] finishTransaction:mockTransaction];
                [catalogue paymentQueue:mockPaymentQueue updatedTransactions:mockTransactions]; 
                [mockProduct verify];
                [mockPaymentQueue verify];
            });
        });
        
        describe(@"on error", ^{
            it(@"should update the product using the transaction given by apple and finish the transaction", ^ {
                int transactionState = SKPaymentTransactionStateFailed;
                [[[mockTransaction stub] andReturn:OCMOCK_VALUE(transactionState)] transactionState]; 
                [[mockProduct expect] updateWithSKPaymentTransaction:mockTransaction];
                [[mockPaymentQueue expect] finishTransaction:mockTransaction];
                [catalogue paymentQueue:mockPaymentQueue updatedTransactions:mockTransactions];    
                [mockProduct verify];
                [mockPaymentQueue verify];
            });
            
        });
        
        describe(@"on restore", ^{
            it(@"should update the product using the transaction given by apple and finish the transaction", ^ {
                int transactionState = SKPaymentTransactionStateRestored;
                [[[mockTransaction stub] andReturn:OCMOCK_VALUE(transactionState)] transactionState]; 
                [[mockProduct expect] updateWithSKPaymentTransaction:mockTransaction];
                [[mockPaymentQueue expect] finishTransaction:mockTransaction];
                [catalogue paymentQueue:mockPaymentQueue updatedTransactions:mockTransactions];    
                [mockProduct verify];
                [mockPaymentQueue verify];
            });
        });
    });
});

SPEC_END