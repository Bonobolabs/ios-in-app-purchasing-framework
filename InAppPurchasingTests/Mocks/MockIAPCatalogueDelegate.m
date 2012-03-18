#import "MockIAPCatalogueDelegate.h"
#import "IAPCatalogue.h"

@interface MockIAPCatalogueDelegate() {
@private
    BOOL lpNotified, flNotified, fweNotified;
    IAPCatalogue* lpCatalogue, *flCatalogue, *fweCatalogue;
    NSError* fweError;
}
@end

@implementation MockIAPCatalogueDelegate

- (void)iapCatalogueDidUpdate:(IAPCatalogue *)catalogue {
    lpNotified = YES;    
    lpCatalogue = catalogue;
}

- (void)iapCatalogueDidFinishUpdating:(IAPCatalogue*)catalogue {
    flNotified = YES;
    flCatalogue = catalogue;
}

- (void)iapCatalogue:(IAPCatalogue *)catalogue updateFailedWithError:(NSError *)error {
    fweNotified = YES;
    fweCatalogue = catalogue;
    fweError = error;
}

- (BOOL)notifiedIAPCatalogueDidUpdate:(IAPCatalogue*)catalogue {
    return lpNotified && lpCatalogue == catalogue;
}

- (BOOL)notifiedIAPCatalogueDidFinishUpdating:(IAPCatalogue*)catalogue {
    return flNotified && flCatalogue == catalogue;
}

- (BOOL)notifiedIAPCatalogue:(IAPCatalogue *)catalogue updateFailedWithError:(NSError *)error {
    return fweNotified && fweCatalogue == catalogue && fweError == error;
}


@end
