#import <StoreKit/StoreKit.h>

@interface SKProductsRequest (Test)
+ (void)initialize;
+ (NSDictionary*)requests;
+ (int)requestCount;
+ (void)resetAll;
+ (SKProductsRequest*)lastRequest;
+ (NSSet*)lastProductIdentifiers;

- (BOOL)wasStarted;
- (void)respondSuccess:(NSArray*)products;
- (NSError*)respondError:(NSString*)errorDescription;


@end
