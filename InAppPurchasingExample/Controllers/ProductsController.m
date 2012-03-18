//
//  ProductsController.m
//  InAppPurchasingExample
//
//  Created by Adam Darton on 12-03-14.
//  Copyright (c) 2012 Bonobo. All rights reserved.
//

#import "ProductsController.h"

@implementation ProductsController

@synthesize iapCatalogue;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.iapCatalogue = [[IAPCatalogue alloc] init];
    [self.iapCatalogue load:self];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Button Actions -

-(IBAction)onBackButtonTouchUp:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - IAPCatalogueDelegate -

-(void)iapCatalogue:(IAPCatalogue*)catalogue didLoadProductsFromCache:(NSArray*)products{
    NSLog(@"Loaded From Cache %d", [products count]);
    
}
-(void)iapCatalogue:(IAPCatalogue*)catalogue didLoadProducts:(NSArray*)products{
    NSLog(@"Loaded %d", [products count]);
}
-(void)iapCatalogueDidFinishLoading:(IAPCatalogue*)catalogue{
    NSLog(@"Loaded catalogue");    
}
-(void)iapCatalogue:(IAPCatalogue*)catalogue didFailWithError:(NSError*)error{
    NSLog(@"Failed: %@", error.description);    
}

@end
