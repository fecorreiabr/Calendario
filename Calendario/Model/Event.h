//
//  Event.h
//  Calendario
//
//  Created by Felipe Correia on 02/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSManagedObject

// Insert code here to declare functionality of your managed object subclass

@property (readonly) NSString * startFinishHour;

//- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSDictionary *) dictionaryForJson;
//- (void) setEventFromDictionary: (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END

#import "Event+CoreDataProperties.h"
