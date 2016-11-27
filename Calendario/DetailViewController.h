//
//  DetailViewController.h
//  Calendario
//
//  Created by Felipe Correia on 02/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface DetailViewController : UIViewController

//@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) Event *event;
@property NSNumber *latitude;
@property NSNumber *longitude;
@property (weak, nonatomic) IBOutlet UITextField *textLocation;

- (void)setDetailItem:(Event *)newEvent;

@end

