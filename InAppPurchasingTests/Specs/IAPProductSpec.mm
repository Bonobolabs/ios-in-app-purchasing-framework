#import <Cedar-iOS/SpecHelper.h>
#import <StoreKit/StoreKit.h>
#import <OCMock/OCMock.h>
#import "IAPProduct+Test.h"


using namespace Cedar::Matchers;

SPEC_BEGIN(IAPProductSpec)

describe(@"IAPProduct", ^{
    __block IAPProduct* product;
    __block NSString* productIdentifier = @"com.test.identifier";
    
    beforeEach(^{
        product = [[IAPProduct alloc] initWithIdentifier:productIdentifier];
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
            NSDecimalNumber* price = [NSDecimalNumber decimalNumberWithString:@"1.99"];
            id mockSKProduct = [OCMockObject mockForClass:[SKProduct class]];
            [[[mockSKProduct stub] andReturn:price] price];
            [product updateWithSKProduct:mockSKProduct];
            
            BOOL samePrice = product.price == [mockSKProduct price];
            expect(samePrice).to(be_truthy());
        });
    });
    
    describe(@"isloading", ^{
        it(@"should be loading if the price hasn't been set", ^{
            BOOL isLoading = product.isLoading;
            expect(isLoading).to(be_truthy());
        });
        
        it(@"shouldn't be loading if the price has been set", ^ {
            product.price = [NSDecimalNumber decimalNumberWithString:@"1.99"];
            BOOL isLoading = product.isLoading;
            expect(isLoading).to_not(be_truthy());
        });
    });
    
});

SPEC_END