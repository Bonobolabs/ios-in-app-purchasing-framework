#import "IAPCatalogue.h"

@interface IAPCatalogue()
- (void)setPaymentQueue:(SKPaymentQueue*)paymentQueue;
- (void)updateProducts:(NSArray*)skProducts;
- (void)setProducts:(NSDictionary*)products;
@end
