//
//  DetailViewController.m
//  Calendario
//
//  Created by Felipe Correia on 02/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "DetailViewController.h"
#import "UIViewController+CoreData.h"
#import "LocationTableViewController.h"
#import "Address.h"
#import "HttpPersistance.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textTitle;
@property (weak, nonatomic) IBOutlet UITextView *textDesc;
@property (weak, nonatomic) IBOutlet UITextField *textDate;
@property (weak, nonatomic) IBOutlet UITextField *textStartHour;
@property (weak, nonatomic) IBOutlet UITextField *textFinishHour;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *removeBtn;

@property UIDatePicker *datePicker;
@property UIDatePicker *timePicker;

@property NSDateFormatter *dateFormatter;
@property NSDateFormatter *timeFormatter;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(Event *)newEvent {
    if (_event != newEvent) {
        _event = newEvent;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.event) {
        //self.detailDescriptionLabel.text = [[self.detailItem valueForKey:@"timeStamp"] description];
        [_textTitle setText:_event.title];
        [_textDesc setText:_event.desc];
        [_textDate setText: [self.dateFormatter stringFromDate:_event.date]];
        [_textStartHour setText:_event.startHour];
        [_textFinishHour setText:_event.finishHour];
        [_textLocation setText:_event.location];
    } else {
        [self.removeBtn setEnabled:NO];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_textDesc.layer setBorderColor:[[[UIColor lightGrayColor] colorWithAlphaComponent:0.5f] CGColor]];
    [_textDesc.layer setBorderWidth:.5];
    [_textDesc.layer setCornerRadius:5.0f];
    
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    self.timeFormatter = [NSDateFormatter new];
    [self.timeFormatter setDateFormat:@"HH:mm"];

    [self configureView];
    
    [self configureDatePicker];
    
    [self configureTimePickers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showLocation:(id)sender {
    [self performSegueWithIdentifier:@"showLocation" sender:sender];
}


#pragma mark - Core Data


- (IBAction)saveEvent:(id)sender {
    if (_textTitle.text.length && _textDate.text.length && _textStartHour.text.length && _textFinishHour.text.length) {
        
        HttpPersistance *http = [[HttpPersistance alloc] init];
        
        if (!self.event) {
            self.event = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
        }
        
        [self.event setTitle:_textTitle.text];
        [self.event setDesc:_textDesc.text];
        [self.event setDate:[_dateFormatter dateFromString:_textDate.text]];
        [self.event setStartHour:_textStartHour.text];
        [self.event setFinishHour:_textFinishHour.text];
        [self.event setOwner:self.userId];
        [self.event setLocation:_textLocation.text];
        [self.event setLatitude:_latitude];
        [self.event setLongitude:_longitude];
        
        NSError * error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Erro ao salvar");
        }
        
        [http postEvent:self.event];
        
        [self performSegueWithIdentifier:@"unwindToMaster" sender:sender];
        
    } else {
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Dados inválidos" message:@"Os campos título, data, hora inicial e hora final são obrigatórios." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)removeEvent:(id)sender {
    if (self.event) {
        NSString *eventId = [self.event.eventId copy];
        [self.managedObjectContext deleteObject:self.event];
        [self.managedObjectContext processPendingChanges];
        
        HttpPersistance *http = [[HttpPersistance alloc] init];
        [http removeEvent:eventId];
        
        [self performSegueWithIdentifier:@"unwindToMaster" sender:sender];
    }
}

#pragma mark - Input Views

- (void)configureDatePicker{
    _datePicker = [UIDatePicker new];
    _datePicker.datePickerMode = UIDatePickerModeDate;
    [self.textDate setInputView:_datePicker];
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [toolbar setTintColor:[UIColor grayColor]];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(showSelectedDate)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
    [self.textDate setInputAccessoryView:toolbar];
}

- (void)configureTimePickers {
    _timePicker = [UIDatePicker new];
    _timePicker.datePickerMode = UIDatePickerModeTime;
    [self.textStartHour setInputView:_timePicker];
    [self.textFinishHour setInputView:_timePicker];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(showSelectedTime)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [toolbar setItems:[NSArray arrayWithObjects:space, doneBtn, nil]];
    [self.textStartHour setInputAccessoryView:toolbar];
    [self.textFinishHour setInputAccessoryView:toolbar];
    
}

- (void)showSelectedDate {
    [_textDate setText: [self.dateFormatter stringFromDate:_datePicker.date]];
    [_textDate resignFirstResponder];
    
}

- (void)showSelectedTime {
    NSString *selectedTime = [self.timeFormatter stringFromDate:_timePicker.date];
    if ([_textStartHour isFirstResponder]) {
        [_textStartHour setText:selectedTime];
        [_textStartHour resignFirstResponder];
    } else if ([_textFinishHour isFirstResponder]) {
        [_textFinishHour setText:selectedTime];
        [_textFinishHour resignFirstResponder];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqual: @"showLocation"]) {
        LocationTableViewController *controller = [segue destinationViewController];
        
        if (self.event && self.event.latitude && self.event.longitude) {
            controller.selectedAddress = [[Address alloc] initWithLatitude:self.event.latitude withLongitude:self.event.longitude withTitle:self.event.title andWIthSubtitle:self.event.location];
            
        }
        
    }
}

@end
