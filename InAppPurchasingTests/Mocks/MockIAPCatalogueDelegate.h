#import "IAPCatalogue.h"

@interface MockIAPCatalogueDelegate : NSObject<IAPCatalogueDelegate>

- (BOOL)notifiedIAPCatalogue:(IAPCatalogue*)catalogue didLoadProductsFromCache:(NSArray*)products;
- (BOOL)notifiedIAPCatalogue:(IAPCatalogue*)catalogue didLoadProducts:(NSArray*)products;
- (BOOL)notifiedIAPCatalogueDidFinishLoading:(IAPCatalogue*)catalogue;
- (BOOL)notifiedIAPCatalogue:(IAPCatalogue *)catalogue didFailWithError:(NSError *)error;

@end