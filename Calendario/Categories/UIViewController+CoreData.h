//
//  UIViewController+CoreData.h
//  Calendario
//
//  Created by Felipe Correia on 02/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (CoreData)

@property (readonly) NSManagedObjectContext * managedObjectContext;

@property (readonly) NSString *userId;

@end
