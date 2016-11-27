//
//  UIViewController+CoreData.m
//  Calendario
//
//  Created by Felipe Correia on 02/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "UIViewController+CoreData.h"
#import "AppDelegate.h"

@implementation UIViewController (CoreData)

-(NSManagedObjectContext *)managedObjectContext{
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    return delegate.managedObjectContext;
}

- (NSString *)userId {
    AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
    return delegate.userId;
}

@end
