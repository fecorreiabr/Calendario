//
//  HttpPersistance.m
//  Calendario
//
//  Created by Felipe Correia on 30/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "HttpPersistance.h"
#import "AppDelegate.h"

static NSString *const RestDBURL = @"https://iesbddm-e6eb.restdb.io/rest/events";

@interface HttpPersistance () <NSURLSessionDelegate>

//@property NSURLSessionConfiguration *sessionConfiguration;
@property NSURLSession *session;

@end

@implementation HttpPersistance

- (instancetype)init {
    self = [super init];
    if (self) {
        NSString *cachePath = @"/EventCache";
        NSURLCache *eventCache = [[NSURLCache alloc] initWithMemoryCapacity:16384 diskCapacity:268435456 diskPath:cachePath];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfiguration.URLCache = eventCache;
        sessionConfiguration.requestCachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        NSDictionary *sessionHeader = [[NSDictionary alloc] initWithObjectsAndKeys:@"ab80982b6f5299caa0cc8d260feed948743cc", @"x-apikey", nil ];
        
        sessionConfiguration.HTTPAdditionalHeaders = sessionHeader;
        
        self.session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:NSOperationQueuePriorityNormal];
    }
    return self;
}

- (void)postEvent:(Event *) event {
    NSURL *url;
    NSString *method;
    
    if (!event.eventId) {
        url = [NSURL URLWithString:RestDBURL];
        method = @"POST";
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", RestDBURL, event.eventId]];
        method = @"PUT";
    }
    
    NSError *err = nil;
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.HTTPMethod = method;
    urlRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:[event dictionaryForJson] options:kNilOptions error:&err];
    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //NSLog(@"%@", [[NSString alloc]initWithData:urlRequest.HTTPBody encoding:NSUTF8StringEncoding]);
    
    if (!err) {
        
        NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@", response);
                return;
            }
            
            //NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
                
            NSError *e;
            id responseEvent = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&e];
            
            if (e) {
                NSLog(@"%@", e);
                return;
            }
            
            NSString *eventId = responseEvent[@"_id"];
            if (eventId && [method isEqual: @"POST"]) {
                [event setEventId:eventId];
            }

        }];
        [dataTask resume];
        
    } else {
        NSLog(@"%@", err);
    }
}

- (void)removeEvent:(NSString *) eventId {
    
    if (!eventId) {
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", RestDBURL, eventId]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.HTTPMethod = @"DELETE";
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
    }];
    [dataTask resume];
}

- (void)getEventsForUserId:(NSString *) userId {
    NSString *eventsURL = [NSString stringWithFormat:@"%@?q={\"owner\":\"%@\"}", RestDBURL, userId];
    NSURL *url = [NSURL URLWithString:[eventsURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:url];
    urlRequest.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@", error);
            return;
        }
        
        NSError *e;
        NSArray *returnedEvents = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments|NSJSONReadingMutableContainers error:&e];
        
        if (e) {
            NSLog(@"%@", e);
            return;
        }
        
        AppDelegate * delegate = [[UIApplication sharedApplication] delegate];
        [delegate performSelectorInBackground:@selector(updateEventsWithDictionaryArray:) withObject:returnedEvents];
        
    }];
    [dataTask resume];
}

@end
