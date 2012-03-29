#import "ProductTableViewCell.h"
#import "IAPStoreManager.h"
#import "IAPProduct.h"

@interface ProductTableViewCell()
@property (nonatomic, strong) UIButton* actionButton;
@property (nonatomic, strong) IAPProduct* product;
@end

@implementation ProductTableViewCell
@synthesize actionButton;
@synthesize product;

+ (NSString*)reusableIdentifier {
    return @"ProductTableViewCell";
}

- (id)initWithProductIdentifier:(NSString*)productIdentifier title:(NSString*)title subTitle:(NSString*)subTitle {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[self class] reusableIdentifier]];
    
    if (self) {
        [self initActionButton];
        [self initProduct:productIdentifier];
        self.textLabel.text = title;
        self.detailTextLabel.text = subTitle;
    }
    
    return self;
}

- (void)dealloc {
    [self.product removeObserver:self];
}

- (void)initActionButton {
    self.actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.actionButton.frame = CGRectMake(0, 0, 112, 37);
    [self.actionButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = self.actionButton;
}

- (void)initProduct:(NSString*)productIdentifier {
    self.product = [[IAPStoreManager sharedInstance] productForIdentifier:productIdentifier];
    [self.product addObserver:self];
    [self setButtonState];
}

- (void)setButtonState {
    BOOL enabled = NO;
    NSString* title = @"";
    
    if (self.product.isLoading) {
        title = @"Loading...";
    }
    else if (self.product.isPurchasing) {
        title = @"Purchasing...";
    }
    else if (self.product.isError) {
        title = @"Error";
    }
    else if (self.product.isPurchased) {
        title = @"Purchased";
    }
    else if (self.product.isReadyForSale) {
        title = self.product.price;
        enabled = YES;
    }

        
    [self.actionButton setEnabled:enabled];
    [self.actionButton setTitle:title forState:UIControlStateNormal];
}

- (void)iapProductJustErrored:(IAPProduct*)iapProduct {
    [self setButtonState]; 
}

- (void)iapProductJustStartedLoading:(IAPProduct*)iapProduct {
    [self setButtonState];    
}

- (void)iapProductJustBecameReadyForSale:(IAPProduct*)iapProduct {
    [self setButtonState];
}

- (void)iapProductWasJustPurchased:(IAPProduct*)iapProduct {
    [self setButtonState];
}

- (void)iapProductWasJustRestored:(IAPProduct*)iapProduct {
    [self setButtonState];
}

- (void)iapProductIsPurchasing:(IAPProduct*)iapProduct {
    [self setButtonState];
}

- (void)actionButtonTapped:(id)sender {
    [self.product purchase];
}

@end
