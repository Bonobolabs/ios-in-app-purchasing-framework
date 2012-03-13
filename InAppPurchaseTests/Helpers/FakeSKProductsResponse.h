#import <StoreKit/StoreKit.h>

@interface FakeSKProductsResponse : SKProductsResponse
@property (nonatomic, readonly) NSArray* products;
- (id)initWithProducts:(NSArray*)products;
@end
