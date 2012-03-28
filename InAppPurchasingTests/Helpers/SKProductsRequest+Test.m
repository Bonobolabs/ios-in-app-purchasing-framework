#import "SKProductsRequest+Test.h"
#import "FakeSKProductsResponse.h"
// We know we're being bad and overriding methods implemented in the primary class but it's just for testing
#pragma GCC diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation SKProductsRequest (Test)

static NSMutableArray *requests;
static NSMutableArray *started;
static NSMutableArray *identifiers;

+ (void)initialize {
    requests = [NSMutableArray array];
    started = [NSMutableArray array];
    identifiers = [NSMutableArray array];
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
    [identifiers removeAllObjects];
}

+ (SKProductsRequest*)lastRequest {
    return [requests lastObject];
}

+ (NSSet*)lastProductIdentifiers {
    return [identifiers lastObject];
}


- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    self = [self init];
    
    if (self) {
        [requests addObject:self];
        [identifiers addObject:productIdentifiers];
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
