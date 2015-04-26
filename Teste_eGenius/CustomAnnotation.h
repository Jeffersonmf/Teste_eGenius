//
//  UIView+CustomAnnotation.h
//  Teste_eGenius
//
//  Created by Jefferson Marchetti on 4/18/15.
//  Copyright (c) 2015 Jefferson Marchetti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject <MKAnnotation>{
    
    CLLocationCoordinate2D coordinate;
    
}
- (id)initWithCoordinate:(CLLocationCoordinate2D)coord;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end

