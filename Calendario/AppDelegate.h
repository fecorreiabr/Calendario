//
//  AppDelegate.h
//  Calendario
//
//  Created by Felipe Correia on 02/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (strong, nonatomic) NSDate *selectedDate;
@property NSString *userId;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)updateEventsWithDictionaryArray:(NSArray *)dictArray;

@end

