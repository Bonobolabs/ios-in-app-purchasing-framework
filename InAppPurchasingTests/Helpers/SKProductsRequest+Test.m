#import "SKProductsRequest+Test.h"
#import "FakeSKProductsResponse.h"

@implementation SKProductsRequest (Test)

static NSMutableArray *requests;
static NSMutableArray *started;

+ (void)initialize {
    requests = [NSMutableArray array];
    started = [NSMutableArray array];
}

+ (NSArray*)requests {
    return requests;
}

+ (int)requestCount {
    return [requests count];
}

+ (void)resetAll {
    [requests removeAllObjects];
    [started removeAllObjects];
}

+ (SKProductsRequest*)lastRequest {
    return [requests lastObject];
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    self = [super init];
    
    if (self) {
        [requests addObject:self];
    }
    
    return self;
}

- (void)start {
    [started addObject:self];
}

- (BOOL)wasStarted {
    return [started containsObject:self];
}

- (void)respondSuccess:(NSArray*)products {
    FakeSKProductsResponse* response = [[FakeSKProductsResponse alloc] initWithProducts:products];
    [self.delegate productsRequest:self didReceiveResponse:response];
    [self.delegate requestDidFinish:self];
}

- (NSError*)respondError:(NSString*)errorDescription {
    NSError* error = [NSError errorWithDomain:@"" code:0 userInfo:[NSDictionary dictionaryWithObjectsAndKeys: NSLocalizedDescriptionKey, @"ran out of money", nil]];
    [self.delegate request:self didFailWithError:error];
    return error;
}
    
@end
