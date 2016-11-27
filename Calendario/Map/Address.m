//
//  Address.m
//  Calendario
//
//  Created by Felipe Correia on 23/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import "Address.h"

@interface Address() {

    CLLocationCoordinate2D _coordinate;
    
}

@end

@implementation Address
-(instancetype)initWithPlacemark:(CLPlacemark *)location withTitle:(NSString *)title andWithSubtitle:(NSString *)subtitle {
    self = [super init];
    if(self){
        _placemark = location;
        _title = title;
        _subtitle = subtitle;
    }
    return self;
}

-(instancetype)initWithLatitude:(NSNumber *)latitude withLongitude:(NSNumber *)longitude withTitle:(NSString *)title andWIthSubtitle:(NSString *)subtitle {
    self = [super init];
    if (self) {
        _coordinate = CLLocationCoordinate2DMake(latitude.doubleValue, longitude.doubleValue);
        _title = title;
        _subtitle = subtitle;
    }
    return self;
}

-(CLLocationCoordinate2D)coordinate {
    if (_placemark) {
        return [[_placemark location] coordinate];
    } else {
        return _coordinate;
    }
    
}

@end
