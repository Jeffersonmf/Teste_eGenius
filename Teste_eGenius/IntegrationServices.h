//
//  NSObject+IntegrationServices.h
//  Teste_eGenius
//
//  Created by Jefferson Marchetti on 4/20/15.
//  Copyright (c) 2015 Jefferson Marchetti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BZFoursquare.h"
#import "BZFoursquareRequest.h"
#import "NXOAuth2.h"
#import <UIKit/UIKit.h>

typedef struct
{
    __unsafe_unretained NSString *titulo;
    double latitude;
    double longitude;
} DadosLocalizacao;

@interface IntegrationServices : NSObject 
- (void) createConnectionThread: (DadosLocalizacao) dadosLocalizacaoArg;
- (void) postFourSquare;

@end
