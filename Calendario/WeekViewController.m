//
//  WeekViewController.m
//  Calendario
//
//  Created by Felipe Correia on 12/11/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "WeekViewController.h"
#import "UIViewController+CoreData.h"
#import "UIViewController+DateOperations.h"


@interface __DayViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSArray<Event*> *events;
@property NSDate *sectionDate;

@end

@implementation __DayViewController

-(instancetype)initWithTitle:(NSString*)title {
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_events count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.title;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"EventCell"];
    [self configureCell:cell withEvent:_events[indexPath.row]];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell withEvent:(Event *)event {
    //Event *event = (Event *)object;
    cell.textLabel.text = event.startHour;
    cell.detailTextLabel.text = event.title;
}

@end


@interface WeekViewController ()

@property (weak, nonatomic) IBOutlet UITableView *monTableView;
@property (weak, nonatomic) IBOutlet UITableView *tueTableView;
@property (weak, nonatomic) IBOutlet UITableView *wedTableView;
@property (weak, nonatomic) IBOutlet UITableView *thuTableView;
@property (weak, nonatomic) IBOutlet UITableView *friTableView;
@property (weak, nonatomic) IBOutlet UITableView *satTableView;
@property (weak, nonatomic) IBOutlet UITableView *sunTableView;


@property NSDate *startDate;
@property NSArray<Event*> *weekEvents;
@property NSArray<NSArray*> *dayEvents;
@property NSArray<NSString*> *dayTitles;
@property NSArray<__DayViewController*> *tableControllers;
@property NSArray<UITableView*> *tableViews;
@property NSDateFormatter *dateFormatter;

@end

@implementation WeekViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadEventsInWeekOfDate:self.selectedDate];
    [self loadEventsForDays];
    
    [self loadControllers];
    
    [self configureTableViews];
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateFormat:@"MMMM YYYY"];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    [self updateTitle];
    //self.monViewController = [[__DayViewController alloc]initWithTitle:(NSString *)];
    //[self.monViewController setEvents:self.weekEvents];
    //self.monTableView.delegate = self.monViewController;
    //self.monTableView.dataSource = self.monViewController;
    //[self.monTableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadControllers {
    NSMutableArray *controllers = [[NSMutableArray alloc]init];
    
    for (int day=0; day<7; day++) {
        __DayViewController *dayViewController = [[__DayViewController alloc]initWithTitle:self.dayTitles[day]];
        [dayViewController setEvents:_dayEvents[day]];
        
        [controllers addObject:dayViewController];
    }
    
    self.tableControllers = [[NSArray alloc]initWithArray:controllers];
    
}


- (void)configureTableViews {
    self.tableViews = [[NSArray alloc]initWithObjects:
                           self.monTableView,
                           self.tueTableView,
                           self.wedTableView,
                           self.thuTableView,
                           self.friTableView,
                           self.satTableView,
                           self.sunTableView,
                           nil];
    
    [self.tableViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITableView *tv = (UITableView*)obj;
        
        [tv.layer setBorderWidth:0.5f];
        [tv.layer setBorderColor:[[[UIColor blueColor] colorWithAlphaComponent:1.0]CGColor]];
        [tv setRowHeight:22.0];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapTableViewWithTap:)];
        [tv addGestureRecognizer:tap];
        
        tv.delegate = self.tableControllers[idx];
        tv.dataSource = self.tableControllers[idx];
        [tv reloadData];
    }];
}

- (void)refreshTableViews {
    if (!self.tableControllers) {
        return;
    }
    
    [self.tableControllers enumerateObjectsUsingBlock:^(__DayViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __DayViewController *dayViewController = (__DayViewController*)obj;
        [dayViewController setTitle:self.dayTitles[idx]];
        [dayViewController setEvents:_dayEvents[idx]];
    }];
    
    for (UITableView *tv in self.tableViews) {
        [tv reloadData];
    }
}

#pragma mark - Date navigation

- (void)updateTitle {
    [self.navigationItem setTitle:[_dateFormatter stringFromDate:self.startDate]];
}

- (IBAction)goPreviousWeek:(id)sender {
    [self loadEventsInWeekOfDate:[self.startDate dateByAddingTimeInterval:-(7*60.0*60.0*24.0)]];
    [self loadEventsForDays];
    [self refreshTableViews];
    [self updateTitle];
}

- (IBAction)goNextWeek:(id)sender {
    [self loadEventsInWeekOfDate:[self.startDate dateByAddingTimeInterval:(7*60.0*60.0*24.0)]];
    [self loadEventsForDays];
    [self refreshTableViews];
    [self updateTitle];
}


#pragma mark - Core Data

- (void)loadEventsInWeekOfDate:(NSDate *)date {
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    long dayOfWeek = [self dayOfWeek:date];
    
    self.startDate = [date dateByAddingTimeInterval:-(dayOfWeek*60.0*60.0*24.0)];
    
    NSDate * endDate = [self.startDate dateByAddingTimeInterval:6*60.0*60.0*24.0];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%K >= %@) AND (%K <= %@)", @"date", self.startDate, @"date", endDate ]];
    
    NSError *error;
    NSArray *events = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    self.weekEvents = events;

}

- (void)loadEventsForDays {
    
    NSMutableArray *eventsToLoad = [NSMutableArray new];
    NSMutableArray *titles = [NSMutableArray new];
    
    for (int day=0; day<7; day++) {
        NSDate *date = [self.startDate dateByAddingTimeInterval:day*60.0*60.0*24.0];
        [titles addObject: [self formattedWeekDay:date]];
        
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K == %@", @"date", date];
        NSArray *filteredEvents = [self.weekEvents filteredArrayUsingPredicate:filter];
        
        [eventsToLoad addObject:filteredEvents];
        
    }
    
    self.dayEvents = [[NSArray alloc]initWithArray:eventsToLoad];
    //self.dayTitles = [[NSArray alloc]initWithArray:titles];
    self.dayTitles = titles;
}


#pragma mark - Navigation

- (void)didTapTableViewWithTap:(UIGestureRecognizer *)gr {
    //UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Teste" message:[NSString stringWithFormat:@"%lu", (unsigned long)*(idx)] preferredStyle:UIAlertControllerStyleAlert];
    //[self presentViewController:alert animated:YES completion:^{
        
    //}];
    UITableView *tv = (UITableView *)gr.view;
    int day = [self.tableViews indexOfObject:tv];
    
    self.selectedDate = [self.startDate dateByAddingTimeInterval:day*60.0*60.0*24.0];
    [self.navigationController.navigationController popToRootViewControllerAnimated:YES];
}

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

