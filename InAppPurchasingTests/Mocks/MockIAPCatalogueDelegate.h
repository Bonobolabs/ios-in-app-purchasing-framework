#import "IAPCatalogue.h"

@interface MockIAPCatalogueDelegate : NSObject<IAPCatalogueDelegate>

- (BOOL)notifiedIAPCatalogueDidUpdate:(IAPCatalogue*)catalogue;
- (BOOL)notifiedIAPCatalogueDidFinishUpdating:(IAPCatalogue*)catalogue;
- (BOOL)notifiedIAPCatalogue:(IAPCatalogue *)catalogue updateFailedWithError:(NSError *)error;

@end