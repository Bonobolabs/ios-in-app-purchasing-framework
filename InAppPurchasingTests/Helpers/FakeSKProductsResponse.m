#import "FakeSKProductsResponse.h"

@interface FakeSKProductsResponse()
@property (nonatomic, readwrite, strong) NSArray* _products;
@end

@implementation FakeSKProductsResponse
@synthesize _products;

- (id)initWithProducts:(NSArray*)products {
    self = [self init];
    if (self) {
        self._products = products;   
    }
    
    return self;
}

- (NSArray*)products {
    return _products;
}

@end
