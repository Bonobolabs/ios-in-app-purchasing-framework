#import <UIKit/UIKit.h>
#import "IAPProduct.h"

@interface ProductTableViewCell : UITableViewCell<IAPProductObserver>
+ (NSString*)reusableIdentifier;
- (id)initWithProductIdentifier:(NSString*)productIdentifier title:(NSString*)title subTitle:(NSString*)subTitle;
@end
