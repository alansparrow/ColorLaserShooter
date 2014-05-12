//
//  IAPTableViewController.m
//  Box Jumping
//
//  Created by Alan Sparrow on 5/7/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "IAPTableViewController.h"
#import "ColorShooterIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "AppDelegate.h"




@interface IAPTableViewController ()
{
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}
@end

@implementation IAPTableViewController

- (id)init
{
    // Call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        
    }
    
    return self;
}

- (IBAction)back:(id)sender
{
    // Go back
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    CCScene *scene = [CCBReader loadAsScene:@"GameMenuScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self reload];
    
    // Hide Ads
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app hideAdBanner];
    
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.title = @"Color Shop";
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:164.f/255.f green:16.f/255.f blue:52.f/255.f alpha:1.f],
      UITextAttributeTextColor,
      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.f],
      UITextAttributeTextShadowColor,
      [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
      UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"Helvetica Neue" size:0.0],
      UITextAttributeFont,
      nil]];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(back:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    
}

- (void)restoreTapped:(id)sender {
    NSLog(@"Restore button tapped");
    [[ColorShooterIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)reload
{
    _products = nil;
    [self.tableView reloadData];
    [[ColorShooterIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Product count: %d", _products.count);
    return _products.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Check for a reusable cell first, use that if it exists
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UItableViewCell"];
    
    // If there is no reusable cell of this type, create new one
    if (!cell) {
        // Create an instance of UITableViewCell, with default appearance
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"UITableViewCell"];
    }
    
    SKProduct *product = (SKProduct *) _products[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %@", [_priceFormatter stringFromNumber:product.price],
                           product.localizedTitle];
    cell.textLabel.textColor = [UIColor colorWithRed:164.f/255.f
                                               green:16.f/255.f
                                                blue:52.f/255.f
                                               alpha:1.f];
    //cell.textLabel.textColor = [UIColor redColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    [_priceFormatter setLocale:product.priceLocale];
    NSString *content = [NSString stringWithFormat:@"%@", product.localizedDescription];
    
    cell.detailTextLabel.text = content;
    cell.detailTextLabel.numberOfLines = 5;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    
    if ([[ColorShooterIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        buyButton.frame = CGRectMake(0, 0, 72, 37);
        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    
    // Configure the cell...
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.f;
}

- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[ColorShooterIAPHelper sharedInstance] buyProduct:product];
    
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            *stop = YES;
        }
    }];
    
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
