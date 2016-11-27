//
//  Address.h
//  Calendario
//
//  Created by Felipe Correia on 23/10/16.
//  Copyright © 2016 Iesb. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface Address : NSObject <MKAnnotation>

-(nonnull instancetype) initWithPlacemark:(nonnull CLPlacemark *) location withTitle:(nonnull NSString *) title andWithSubtitle:(nonnull NSString *) subtitle;

-(nonnull instancetype) initWithLatitude:(nonnull NSNumber*) latitude withLongitude:(nonnull NSNumber*) longitude withTitle:(nonnull NSString*) title andWIthSubtitle:(nonnull NSString *) subtitle;

@property (nullable, readonly) CLPlacemark * placemark;

@property (nonatomic, readonly, copy, nonnull) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;

@end
