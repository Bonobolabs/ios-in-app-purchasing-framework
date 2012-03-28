#import "ViewController.h"
#import "ProductTableViewCell.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray* products;
@end

@implementation ViewController
@synthesize products = _products;

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initProducts];
    }
    
    return self;
}

- (void)initProducts {
    NSMutableArray* products = [NSMutableArray array];
    
    NSMutableDictionary* singleBanana = [NSMutableDictionary dictionary];
    [singleBanana setValue:@"Single Banana" forKey:@"title"];
    [singleBanana setValue:@"A big yellow banana mmm." forKey:@"subTitle"];
    [singleBanana setValue:@"com.bonobolabs.InAppPurchasingExample.SingleBanana" forKey:@"identifier"];
    [products addObject:singleBanana];
    
    NSMutableDictionary* bunchOfBananas = [NSMutableDictionary dictionary];
    [bunchOfBananas setValue:@"Bunch of Bananas" forKey:@"title"];
    [bunchOfBananas setValue:@"4 big yellow bananas mmm." forKey:@"subTitle"];
    [bunchOfBananas setValue:@"com.bonobolabs.InAppPurchasingExample.BunchofBananas" forKey:@"identifier"];
    [products addObject:bunchOfBananas];    
    self.products = products;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.products count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ProductTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[ProductTableViewCell reusableIdentifier]];
    
    if (!cell) {
        NSDictionary* productDetails = [self.products objectAtIndex:indexPath.row]; 
        NSString* identifier = [productDetails valueForKey:@"identifier"];
        NSString* title = [productDetails valueForKey:@"title"];
        NSString* subTitle = [productDetails valueForKey:@"subTitle"];
        cell = [[ProductTableViewCell alloc] initWithProductIdentifier:identifier title:title subTitle:subTitle]; 
    }
    
    return cell;
}



@end
