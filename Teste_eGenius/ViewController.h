//
//  ViewController.h
//  Teste_eGenius
//
//  Created by Jefferson Marchetti on 4/17/15.
//  Copyright (c) 2015 Jefferson Marchetti. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "CustomAnnotation.h"
#import "IntegrationServices.h"

@import CoreLocation;

@interface ViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapViewControl;

@property (strong, nonatomic) IBOutlet UIButton *meuBotao;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) IBOutlet UIImageView *imagemPino;

@property (nonatomic,readwrite,assign) CLLocationCoordinate2D coordinate;

@property (strong, nonatomic) IBOutlet UIButton *imgPinFixesAnnotation;

@property (strong, nonatomic) IBOutlet UIButton *btnLimparMarcacoes;


@end

