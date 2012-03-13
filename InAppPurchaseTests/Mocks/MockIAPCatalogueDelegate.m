#import "MockIAPCatalogueDelegate.h"
#import "IAPCatalogue.h"

@interface MockIAPCatalogueDelegate() {
@private
    BOOL lpfcNotified, lpNotified, flNotified, fweNotified;
    IAPCatalogue* lpfcCatalogue, *lpCatalogue, *flCatalogue, *fweCatalogue;
    NSArray* lpfcProducts, *lpProducts;
    NSError* fweError;
}
@end

@implementation MockIAPCatalogueDelegate

- (void)iapCatalogue:(IAPCatalogue*)catalogue didLoadProductsFromCache:(NSArray*)products {
    lpfcNotified = YES;        
    lpfcCatalogue = catalogue;
    lpfcProducts = products;
}

- (void)iapCatalogue:(IAPCatalogue*)catalogue didLoadProducts:(NSArray*)products {
    lpNotified = YES;    
    lpCatalogue = catalogue;
    lpProducts = products;
}

- (void)iapCatalogueDidFinishLoading:(IAPCatalogue*)catalogue {
    flNotified = YES;
    flCatalogue = catalogue;
}

- (void)iapCatalogue:(IAPCatalogue *)catalogue didFailWithError:(NSError *)error {
    fweNotified = YES;
    fweCatalogue = catalogue;
    fweError = error;
}


- (BOOL)notifiedIAPCatalogue:(IAPCatalogue*)catalogue didLoadProductsFromCache:(NSArray*)products {
    return lpfcNotified && lpfcCatalogue == catalogue && lpfcProducts == products;
}

- (BOOL)notifiedIAPCatalogue:(IAPCatalogue*)catalogue didLoadProducts:(NSArray*)products {
    return lpNotified && lpCatalogue == catalogue && lpProducts == products;
}

- (BOOL)notifiedIAPCatalogueDidFinishLoading:(IAPCatalogue*)catalogue {
    return flNotified && flCatalogue == catalogue;
}

- (BOOL)notifiedIAPCatalogue:(IAPCatalogue *)catalogue didFailWithError:(NSError *)error {
    return fweNotified && fweCatalogue == catalogue && fweError == error;
}


@end
