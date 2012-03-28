#import <Cedar-iOS/SpecHelper.h>
#import <StoreKit/StoreKit.h>
#import <OCMock/OCMock.h>
#import <Foundation/NSKeyValueObserving.h>
#import "IAPProduct+Test.h"
#import "IAPCatalogue.h"
#import "SKProduct+PriceWithCurrency.h"


using namespace Cedar::Matchers;

SPEC_BEGIN(IAPProductSpec)

describe(@"IAPProduct", ^{
    __block IAPProduct* product;
    __block NSString* productIdentifier = @"com.test.identifier";
    __block id mockCatalogue;
    __block id mockDefaults;
    __block id mockProductObserver;
    
    beforeEach(^{
        mockCatalogue = [OCMockObject mockForClass:[IAPCatalogue class]];
        mockDefaults = [OCMockObject mockForClass:[NSUserDefaults class]];
        [[[mockDefaults stub] andReturn:NULL] valueForKey:[OCMArg any]];
        [[mockDefaults stub] setValue:[OCMArg any] forKey:[OCMArg any]];
        mockProductObserver = [OCMockObject mockForProtocol:@protocol(IAPProductObserver)];

        product = [[IAPProduct alloc] initWithCatalogue:mockCatalogue identifier:productIdentifier settings:mockDefaults];
        
    });
    
    describe(@"initWithIdentifier:", ^{
        it(@"should have set the product identifier", ^{
            NSString* identifier = product.identifier;
            expect(identifier).to(equal(productIdentifier));
        });
    });
    
    describe(@"identifierEquals:", ^{
        it(@"should be true if the product identifiers are equal", ^{
            BOOL identifierEquals = [product identifierEquals:productIdentifier];
            expect(identifierEquals).to(be_truthy());
        });
        
        it(@"should be false if the product identifiers are not equal", ^{
            BOOL identifierEquals = [product identifierEquals:@""];
            expect(identifierEquals).to_not(be_truthy());
        });
    });
    
    describe(@"updateWithSKProduct:", ^{
        it(@"should update the price of the product", ^{
            id mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
            [[[mockSKProduct stub] andReturn:@"$1.99"] priceWithCurrency];
            [product updateWithSKProduct:mockSKProduct];
            
            BOOL samePrice = [product.price isEqualToString: [mockSKProduct priceWithCurrency]];
            expect(samePrice).to(be_truthy());
        });
    });
    
    describe(@"updateWithSKPaymentTransaction:", ^{
        __block id mockTransaction;
        __block id mockSKProduct;
        __block id mockSKPayment;
        
        beforeEach(^{
            mockTransaction = [OCMockObject mockForClass:[SKPaymentTransaction class]];
            NSString* priceWithCurrency = @"$1.99";
            mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
            [[[mockSKProduct stub] andReturn:priceWithCurrency] priceWithCurrency];
            mockSKPayment = [OCMockObject mockForClass:[SKPayment class]];
        });
        
        it(@"should trigger an error and then revert to ready for sale if an error was encountered during purchasing", ^{    
            [product updateWithSKProduct:mockSKProduct];
            id mockSKPayment = [OCMockObject mockForClass:[SKPayment class]];
            [product updateWithSKPayment:mockSKPayment];
            int errorState = SKPaymentTransactionStateFailed;
            [[[mockTransaction stub] andReturnValue:OCMOCK_VALUE(errorState)] transactionState];
            [[mockProductObserver expect] iapProductJustErrored:product];
            [[mockProductObserver expect] iapProductJustBecameReadyForSale:product];
            [product addObserver:mockProductObserver];
            [product updateWithSKPaymentTransaction:mockTransaction];
            BOOL isReadyForSale = product.isReadyForSale; 
            expect(isReadyForSale).to(be_truthy());
            [mockProductObserver verify];
        });
        
        it(@"should be purchased if purchasing was successful", ^{
            [product updateWithSKProduct:mockSKProduct];
            [product updateWithSKPayment:mockSKPayment];
            int purchasedState = SKPaymentTransactionStatePurchased;
            [[[mockTransaction stub] andReturnValue:OCMOCK_VALUE(purchasedState)] transactionState];
            [[mockProductObserver expect] iapProductWasJustPurchased:product];
            [product addObserver:mockProductObserver];
            [product updateWithSKPaymentTransaction:mockTransaction];
            BOOL isPurchased = product.isPurchased; 
            expect(isPurchased).to(be_truthy());
            [mockProductObserver verify];
        });
        
        it(@"should be restored if purchase was successfully restored", ^{
            [product updateWithSKProduct:mockSKProduct];
            id mockSKPayment = [OCMockObject mockForClass:[SKPayment class]];
            [product updateWithSKPayment:mockSKPayment];
            int restoredState = SKPaymentTransactionStateRestored;
            [[[mockTransaction stub] andReturnValue:OCMOCK_VALUE(restoredState)] transactionState];
            [[mockProductObserver expect] iapProductWasJustRestored:product];
            [product addObserver:mockProductObserver];
            [product updateWithSKPaymentTransaction:mockTransaction];
            BOOL isRestored = product.isRestored; 
            expect(isRestored).to(be_truthy());
            [mockProductObserver verify];
        });
    });     
    
    describe(@"updateWithSKPayment:", ^{        
        it(@"should be purchasing", ^{
            NSString* priceWithCurrency = @"$1.99";
            id mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
            [[[mockSKProduct stub] andReturn:priceWithCurrency] priceWithCurrency];
            id mockSKPayment = [OCMockObject mockForClass:[SKPayment class]];
            [[mockProductObserver expect] iapProductJustBecameReadyForSale:product];
            [[mockProductObserver expect] iapProductIsPurchasing:product];
            [product addObserver:mockProductObserver];
            [product updateWithSKProduct:mockSKProduct];
            [product updateWithSKPayment:mockSKPayment];
            BOOL isPurchasing = product.isPurchasing; 
            expect(isPurchasing).to(be_truthy());  
            [mockProductObserver verify];
        });
    });    
    
    describe(@"isLoading", ^{
        it(@"should be loading if the product hasn't been updated with an SKProduct", ^{
            BOOL isLoading = product.isLoading;
            expect(isLoading).to(be_truthy());
        });
        
        it(@"shouldn't be loading if the product has been updated with an SKProduct", ^{
            NSString* priceWithCurrency = @"$1.99";
            id mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
            [[[mockSKProduct stub] andReturn:priceWithCurrency] priceWithCurrency];
            [product updateWithSKProduct:mockSKProduct];

            BOOL isLoading = product.isLoading;
            expect(isLoading).to_not(be_truthy());
        });
    });
    
    describe(@"isReadyForSale", ^{
        it(@"should be ready for sale if the product has been updated with an SKProduct", ^{
            NSString* priceWithCurrency = @"$1.99";
            id mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
            [[[mockSKProduct stub] andReturn:priceWithCurrency] priceWithCurrency];
            [product updateWithSKProduct:mockSKProduct];
            
            BOOL isReadyForSale = product.isReadyForSale;
            expect(isReadyForSale).to(be_truthy());
        });
        
        it(@"shouldn't be ready for sale if the product hasn't been updated with an SKProduct", ^{
            product.price = @"$1.99";
            BOOL isReadyForSale = product.isReadyForSale;
            expect(isReadyForSale).to_not(be_truthy());
        });
    });
    
    describe(@"addObserver:", ^{
        it(@"should add an observer to the list of observers", ^ {
            int observersBefore = [product.observers count];
            [product addObserver:mockProductObserver];
            int observersAfter = [product.observers count];
            expect(observersAfter).to(equal(observersBefore+1));
        });
    });
    
    describe(@"removeObserver:", ^{
        it(@"should remove an observer from the list of observers", ^ {
            [product addObserver:mockProductObserver];
            int observersBefore = [product.observers count];
            [product removeObserver:mockProductObserver];
            int observersAfter = [product.observers count];
            expect(observersAfter).to(equal(observersBefore-1));            
        });
    });
    
    describe(@"save", ^{
        it(@"should persist the current price and state of the product", ^{
            NSString* priceWithCurrency = @"$1.99";
            const NSString* state = kStateLoading;
            id mockSaveDefaults = [OCMockObject niceMockForClass:[NSUserDefaults class]];
            [[mockSaveDefaults expect] setValue:priceWithCurrency forKey:[OCMArg any]];
            [[mockSaveDefaults expect] setValue:state forKey:[OCMArg any]];
            IAPProduct* saveProduct = [[IAPProduct alloc] initWithCatalogue:mockCatalogue identifier:productIdentifier settings:mockSaveDefaults];
            [saveProduct setPrice:priceWithCurrency];
            [saveProduct save];
            [mockSaveDefaults verify];
        });
    });
    
    describe(@"restore", ^{
        it(@"should persist the current price and state of the product", ^{
            NSString* price = @"$1.99";
            const NSString* state = kStatePurchased;
            id mockRestoreDefaults = [OCMockObject mockForClass:[NSUserDefaults class]];
            [[[mockRestoreDefaults stub] andReturn:price] valueForKey:[product priceKey]];
            [[[mockRestoreDefaults stub] andReturn:state] valueForKey:[product stateKey]];
            IAPProduct* restoreProduct = [[IAPProduct alloc] initWithCatalogue:mockCatalogue identifier:productIdentifier settings:mockRestoreDefaults];
            [restoreProduct restore];
            NSString* productPrice = restoreProduct.price;
            const NSString* productState = restoreProduct.state;
            
            expect(productPrice).to(equal(price));
            expect(productState).to(equal(state));
        });
    });
    
});

SPEC_END