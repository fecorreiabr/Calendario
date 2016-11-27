//
//  HttpPersistance.h
//  Calendario
//
//  Created by Felipe Correia on 30/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface HttpPersistance : NSObject

- (void)postEvent:(nonnull Event *) event;
- (void)getEventsForUserId:(nonnull NSString *) userId;
- (void)removeEvent:(nullable NSString *) eventId;

@end
