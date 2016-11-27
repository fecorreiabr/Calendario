//
//  UIViewController+DateOperations.h
//  Calendario
//
//  Created by Felipe Correia on 23/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (DateOperations)

@property NSDate *selectedDate;
@property (readonly) id appDelegate;

- (void) moveSelectedDateWithDays: (int) days;
- (long) dayOfWeek:(NSDate *)date;
- (NSString*)formattedWeekDay:(NSDate *)date;

@end
