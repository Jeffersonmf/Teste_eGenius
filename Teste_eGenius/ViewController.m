//
//  ViewController.m
//  Teste_eGenius
//
//  Created by Jefferson Marchetti on 4/17/15.
//  Copyright (c) 2015 Jefferson Marchetti. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mapViewControl.delegate = self;
    self.mapViewControl.showsUserLocation = YES;
    
    CustomAnnotation *myPin = [[CustomAnnotation alloc] initWithCoordinate:self.mapViewControl.centerCoordinate]; // Or whatever coordinates...
    [self.mapViewControl addAnnotation:myPin];
    
    //In ViewDidLoad
    if(IS_OS_8_OR_LATER) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.imgPinFixesAnnotation setBackgroundImage:[UIImage imageNamed:@"map-pin-red-md.png"] forState:UIControlStateNormal];
    [self.imgPinFixesAnnotation setBackgroundImage:[UIImage imageNamed:@"map-pin-red-md.png"] forState:UIControlStateHighlighted];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 &&
        [CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse
        ) {
    
        // Will open an confirm dialog to get user's approval
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    } else {
        [self.locationManager startUpdatingLocation]; //Will update location immediately
    }
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapViewControl addGestureRecognizer:panRec];

}

- (void)setZoomMap {

    MKCoordinateRegion region;
    region.center.latitude = 0;
    region.center.longitude = 0;
    region.span.latitudeDelta = 1;
    region.span.longitudeDelta = 1;
    region = [self.mapViewControl regionThatFits:region];
    [self.mapViewControl setRegion:region animated:TRUE];

}

- (MKAnnotationView *) mapView: (MKMapView *) mapView viewForAnnotation: (id<MKAnnotation>) annotation {
    MKPinAnnotationView *pin = (MKPinAnnotationView *) [self.mapViewControl dequeueReusableAnnotationViewWithIdentifier: @"myPin"];
    if (pin == nil) {
        pin = [[MKPinAnnotationView alloc] initWithAnnotation: annotation reuseIdentifier: @"myPin"]; // If you use ARC, take out 'autorelease'
    } else {
        pin.annotation = annotation;
    }
    pin.animatesDrop = YES;
    pin.draggable = YES;
    
    return pin;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        NSLog(@"drag ended");
        
        CLLocationCoordinate2D centre = [self.mapViewControl convertPoint:self.mapViewControl.center toCoordinateFromView:self.mapViewControl];
        
        NSLog([NSString stringWithFormat:@"%f",centre.latitude]);
        NSLog([NSString stringWithFormat:@"%f",centre.longitude]);
        
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:centre];
        [annotation setTitle:@""];
        [self.mapViewControl addAnnotation:annotation];
        
        DadosLocalizacao dadosLocalizacao;
        
        dadosLocalizacao.longitude = annotation.coordinate.longitude;
        dadosLocalizacao.latitude = annotation.coordinate.latitude;
        dadosLocalizacao.titulo = annotation.title;
        
        [UIView commitAnimations];
        
        IntegrationServices *integrationServices = [[IntegrationServices alloc] init];
        [integrationServices createConnectionThread: dadosLocalizacao];
    }
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)annotationView
didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding)
    {
        CLLocationCoordinate2D droppedAt = annotationView.annotation.coordinate;
        NSLog(@"Pin dropped at %f,%f", droppedAt.latitude, droppedAt.longitude);
    }
}


- (void)exibirMarcadorMapa {

    //Determine location of user and center of the map in pixels
    CGPoint user;
    user.x = ((self.mapViewControl.userLocation.coordinate.longitude - self.mapViewControl.region.center.longitude) / self.mapViewControl.region.span.longitudeDelta) * self.mapViewControl.frame.size.width;
    user.y = ((self.mapViewControl.userLocation.coordinate.latitude - self.mapViewControl.region.center.latitude) / self.mapViewControl.region.span.latitudeDelta) * self.mapViewControl.frame.size.height;
    
    //Define the bounding box for the button
    CGPoint bounds = CGPointMake(self.mapViewControl.frame.size.width - 35, self.mapViewControl.frame.size.height - 35);
    
    //Assume the center of the map is the origin point at (0,0)
    //Calculate the angle using trig
    float angle = atanf((user.y/user.x));
    float arrowRotation = 0;
    
    CGPoint buttonPosition = CGPointMake(0, 0);
    
    //Determine Quadrant
    if (user.y >= 0) {
        //User is located above center of the screen
        
        if (user.x >= 0) {
            //User is located to the right of the center of the screen
            //TOP RIGHT QUANDRANT
            arrowRotation = 1.57079633 - angle;
            //Determine which value we are aware of
            if (angle < 0.785398163) {
                //Less than 45 degrees, we know x and solve for y
                buttonPosition.x = (bounds.x);
                buttonPosition.y = bounds.y - (((bounds.x / 2) * tanf(angle)) + (bounds.y / 2));
            } else {
                //More than 45 degree, we know y and solve for x
                buttonPosition.y = self.mapViewControl.frame.size.height - bounds.y;
                buttonPosition.x = ((bounds.x / 2) + (0.5 * (bounds.y / (tanf(angle)))));
            }
            
        } else if (user.x < 0) {
            //User is located to the left of the center of the screen
            //TOP LEFT QUANDRANT
            arrowRotation = 4.71238898 - angle;
            //Determine which value we are aware of
            if (angle > -0.785398163) {
                //Less than 45 degrees, we know x and solve for y
                buttonPosition.x = self.mapViewControl.frame.size.width - bounds.x;
                buttonPosition.y = (((bounds.x / 2) * tanf(angle)) + (bounds.y / 2));
            } else {
                //More than 45 degree, we know y and solve for x
                buttonPosition.y = self.mapViewControl.frame.size.height - bounds.y;
                buttonPosition.x = ((bounds.x / 2) + (0.5 * (bounds.y / (tanf(angle)))));
            }
        }
        
    } else if (user.y < 0) {
        //User is located below center of the screen
        
        if (user.x >= 0) {
            //User is located to the right of the center of the screen
            //BOTTOM RIGHT QUANDRANT
            arrowRotation = 1.57079633 - angle;
            //Determine which value we are aware of
            if (angle > -0.785398163) {
                //Less than 45 degrees, we know x and solve for y
                buttonPosition.x = (bounds.x);
                buttonPosition.y = bounds.y - (((bounds.x / 2) * tanf(angle)) + (bounds.y / 2));
            } else {
                //More than 45 degree, we know y and solve for x
                buttonPosition.y = bounds.y;
                buttonPosition.x = ((bounds.x / 2) - (0.5 * (bounds.y / (tanf(angle)))));
            }
            
        } else if (user.x < 0) {
            //User is located to the left of the center of the screen
            //BOTTOM LEFT QUANDRANT
            arrowRotation = 4.71238898 - angle;
            //Determine which value we are aware of
            if (angle < 0.785398163) {
                //Less than 45 degrees, we know x and solve for y
                buttonPosition.x = self.mapViewControl.frame.size.width - bounds.x;
                buttonPosition.y = (((bounds.x / 2) * tanf(angle)) + (bounds.y / 2));
            } else {
                //More than 45 degree, we know y and solve for x
                buttonPosition.y = (bounds.y);
                buttonPosition.x = ((bounds.x / 2) - (0.5 * (bounds.y / (tanf(angle)))));
            }
            
        }
    }
    
    //Constrain buttonPosition to bounds
    if (buttonPosition.x > bounds.x) {
        buttonPosition.x = bounds.x;
    } else if (buttonPosition.x < (self.mapViewControl.frame.size.width - bounds.x)) {
        buttonPosition.x = (self.mapViewControl.frame.size.width - bounds.x);
    }
    
    if (buttonPosition.y > bounds.y) {
        buttonPosition.y = bounds.y;
    } else if (buttonPosition.y < (self.mapViewControl.frame.size.height - bounds.y)) {
        buttonPosition.y = (self.mapViewControl.frame.size.height - bounds.y);
    }
    
    //Set button position, while accounting for the height of the top UISearchBar and size of the graphic
    buttonPosition.x = (buttonPosition.x - (self.imagemPino.frame.size.width / 2));
    buttonPosition.y = ((buttonPosition.y /*+ topSearch.frame.size.height*/) - (self.imagemPino.frame.size.height / 2));
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    self.imagemPino.frame = CGRectMake(buttonPosition.x, buttonPosition.y, self.imagemPino.frame.size.width, self.imagemPino.frame.size.height);
    [UIView commitAnimations];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Wait for location callbacks
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"%@", [locations lastObject]);
}

- (IBAction)Toque:(id)sender {
    
    [self atualizarMinhaLocalizacao];
    
}

- (void)atualizarMinhaLocalizacao {

    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    MKUserLocation *userLocation = self.mapViewControl.userLocation;
    MKCoordinateRegion region =
    MKCoordinateRegionMakeWithDistance (
                                        userLocation.location.coordinate, 20000, 20000);
    [self.mapViewControl setRegion:region animated:NO];

}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    for (UITouch * touch in touches) {
        CGPoint loc = [touch locationInView:self.mapViewControl];
        if ([self.mapViewControl pointInside:loc withEvent:event]) {
            //#do whatever you need to do
            NSLog(@"Movendo o Mapa", @"");
            
            break;
        }
    }
}

- (IBAction)limparMarcacoes:(id)sender {
    
    [self.mapViewControl removeAnnotations:self.mapViewControl.annotations];
}

@end
