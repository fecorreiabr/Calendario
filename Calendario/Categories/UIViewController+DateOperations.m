//
//  UIViewController+DateOperations.m
//  Calendario
//
//  Created by Felipe Correia on 23/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "UIViewController+DateOperations.h"
#import "AppDelegate.h"

@implementation UIViewController (DateOperations)

- (NSDate *) selectedDate {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return delegate.selectedDate;
}

- (void) setSelectedDate:(NSDate *)selectedDate {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate setSelectedDate:selectedDate];
}

- (id)appDelegate {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    return delegate;
}

- (void) moveSelectedDateWithDays:(int)days {
    NSDateComponents *dayComponent = [NSDateComponents new];
    dayComponent.day = days;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [self setSelectedDate: [calendar dateByAddingComponents:dayComponent toDate:self.selectedDate options:0]];
}

-(long)dayOfWeek:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSinceReferenceDate]/(60.0*60.0*24.0);
    long dayix = ((long)interval) % 7;
    return dayix;
}

- (NSString*)formattedWeekDay:(NSDate *)date {
    NSDateFormatter *weekDayFormatter = [NSDateFormatter new];
    [weekDayFormatter setDateFormat:@"E d"];
    [weekDayFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    return [weekDayFormatter stringFromDate:date];
}

@end
