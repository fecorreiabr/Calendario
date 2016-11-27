//
//  Event.m
//  Calendario
//
//  Created by Felipe Correia on 02/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "Event.h"

@implementation Event

// Insert code here to add functionality to your managed object subclass

/*-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        [self setValuesForKeysWithDictionary:dictionary];
    }
    return self;
}*/

-(NSString *)startFinishHour{
    return [NSString stringWithFormat:@"%@ - %@", self.startHour, self.finishHour];
}

-(NSDictionary *)dictionaryForJson {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSString *stringDate = [dateFormatter stringFromDate:self.date];
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:
        self.title, @"title",
        self.desc, @"desc",
        stringDate, @"date",
        self.startHour, @"startHour",
        self.finishHour, @"finishHour",
        self.owner, @"owner",
        self.location, @"location",
        self.latitude, @"latitude",
        self.longitude, @"longitude",
            nil];
}
/*
-(void)setEventFromDictionary:(NSDictionary *)dictionary {
    self.eventId =
}*/

-(void)setDate:(NSDate *)date {
    [self willChangeValueForKey:@"date"];
    if ([date isKindOfClass:[NSDate class]]) {
        [self setPrimitiveValue:date forKey:@"date"];
    } else if ([date isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [self setPrimitiveValue:[dateFormatter dateFromString:(NSString *)date] forKey:@"date"];
        
    }
    [self didChangeValueForKey:@"date"];
}

-(void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"_id"]) {
        self.eventId = value;
    }
}

-(id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end
