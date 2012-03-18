//
//  ProductsController.h
//  InAppPurchasingExample
//
//  Created by Adam Darton on 12-03-14.
//  Copyright (c) 2012 Bonobo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAPCatalogue.h"

@interface ProductsController : UITableViewController<IAPCatalogueDelegate>

@property (nonatomic, strong) IAPCatalogue* iapCatalogue;

-(IBAction)onBackButtonTouchUp:(id)sender;

@end
