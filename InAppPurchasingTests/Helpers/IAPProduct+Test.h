#import "IAPProduct+Friend.h"

@interface IAPProduct(Test)
- (void)setPrice:(NSString*)price;
- (NSMutableArray*)observers;
- (void)save;
- (NSString*)priceKey;
- (NSString*)stateKey;
- (void)restore;
@end
