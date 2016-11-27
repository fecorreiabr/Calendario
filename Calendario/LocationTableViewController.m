//
//  LocationTableViewController.m
//  Calendario
//
//  Created by Felipe Correia on 23/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "LocationTableViewController.h"
#import "DetailViewController.h"
@import MapKit;

@interface LocationTableViewController () <UISearchResultsUpdating, UINavigationControllerDelegate>

@property CLGeocoder * geocoder;
@property NSMutableArray<Address *> * addresses;
@property (strong, nonatomic) UISearchController *searchController;
@property MKMapView *map;

@end

@implementation LocationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    //[self.navigationController setNavigationBarHidden:YES];
    self.navigationController.delegate = self;
    self.map = [[MKMapView alloc] init];
    [self.tableView setTableFooterView:[UIView new]];
    [self showMap];
    
    if (_selectedAddress) {
        [self.map addAnnotation:_selectedAddress];
        [self centerMap];
    }
    
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //self.searchController.searchBar.delegate = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    _addresses = [NSMutableArray new];
    
    self.geocoder = [[CLGeocoder alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Map & Location

- (void) showMap {
    [self.tableView setBackgroundView:self.map];
}

- (void) centerMap {
    [self.map setRegion:MKCoordinateRegionMake(_selectedAddress.coordinate, MKCoordinateSpanMake(0.01f, 0.01f))];
}

- (void)geoCodeAdress: (NSString *)address {
    [_addresses removeAllObjects];
    
    [self.geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        
        if(error){
            NSLog(@"%@", error);
            return;
        }
        
       [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
           NSString *title;
           if (obj.thoroughfare) {
               title = obj.thoroughfare;
           } else {
               title = obj.locality;
           }
           
           NSString *subTitle = [NSString stringWithFormat:@"%@, %@, %@", obj.locality, obj.administrativeArea, obj.country];
           
           Address *addr = [[Address alloc] initWithPlacemark:obj withTitle:title andWithSubtitle:subTitle];

           [_addresses addObject:addr];
           
       }];
        
        [self.tableView reloadData];
    }];
}



#pragma mark - Search Bar

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    
    NSString *searchString = self.searchController.searchBar.text;
    
    if (searchString.length > 3) {
        [self geoCodeAdress:searchString];
    } else {
        [self clearTable];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_addresses count];
}

- (void) clearTable {
    [_addresses removeAllObjects];
    [self.tableView reloadData];
}

- (void)configureCell:(UITableViewCell *)cell withAddress: (Address *)address {
    cell.textLabel.text = address.title;
    cell.detailTextLabel.text = address.subtitle;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Location" forIndexPath:indexPath];
    
    [self configureCell:cell withAddress:[_addresses objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.map removeAnnotation:_selectedAddress];
    [self setSelectedAddress:_addresses[indexPath.row]];
    [self.map addAnnotation:_selectedAddress];
    
    [self clearTable];
    [self.searchController setActive:NO];
    
    [self centerMap];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (_selectedAddress.placemark && [viewController isKindOfClass:[DetailViewController class]]) {
        DetailViewController *controller = (DetailViewController *)viewController;
        [controller setLatitude:@(self.selectedAddress.coordinate.latitude)];
        [controller setLongitude:@(self.selectedAddress.coordinate.longitude)];
        [controller.textLocation setText:[NSString stringWithFormat:@"%@, %@", _selectedAddress.title, _selectedAddress.subtitle]];
    }
}
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}
*/

@end
