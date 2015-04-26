//
//  NSObject+IntegrationServices.m
//  Teste_eGenius
//
//  Created by Jefferson Marchetti on 4/20/15.
//  Copyright (c) 2015 Jefferson Marchetti. All rights reserved.
//

#import "IntegrationServices.h"
#import <Foundation/Foundation.h>

#define kClientID       @"VHT2KA241BSBAB0MWAUYEKGH1BST1M4Z4PTUMNZ1Q3M5ZJGB"
#define kClientSecret   @"BZ5IXR2FXOEJA0MV3PINHO1NWRYFYWV43LSMFTSWVKS5H0UH"
#define kCallbackURL    @"Teste_eGenius://fousquare"

@interface IntegrationServices ()
@property(nonatomic,readwrite,strong) BZFoursquare *foursquare;
@property(nonatomic,strong) BZFoursquareRequest *request;
@property(nonatomic,copy) NSDictionary *meta;
@property(nonatomic,copy) NSArray *notifications;
@property(nonatomic,copy) NSDictionary *response;
- (void)updateView;
- (void)cancelRequest;
- (void)prepareForRequest;
- (void)checkin;
@end

enum {
    kAuthenticationSection = 0,
    kEndpointsSection,
    kResponsesSection,
    kSectionCount
};

enum {
    kAccessTokenRow = 0,
    kAuthenticationRowCount
};

enum {
    kSearchVenuesRow = 0,
    kCheckInRow,
    kAddPhotoRow,
    kEndpointsRowCount
};

enum {
    kMetaRow = 0,
    kNotificationsRow,
    kResponseRow,
    kResponsesRowCount
};

@implementation IntegrationServices : NSObject
{
    DadosLocalizacao dadosLocalizacao;
}

+ (void)initialize; {
    [[NXOAuth2AccountStore sharedStore] setClientID:@"VHT2KA241BSBAB0MWAUYEKGH1BST1M4Z4PTUMNZ1Q3M5ZJGB"
                                        secret:@"BZ5IXR2FXOEJA0MV3PINHO1NWRYFYWV43LSMFTSWVKS5H0UH"
                                        authorizationURL:[NSURL URLWithString:@"https://foursquare.com/oauth2/authenticate"]
                                        tokenURL:[NSURL URLWithString:@"https://foursquare.com/oauth2/access_token"]
                                        redirectURL:[NSURL URLWithString:@"myapp://foursquare-callback"]
                                        forAccountType:@"Foursquare"];
}


- (void)dealloc {
    _foursquare.sessionDelegate = nil;
    [self cancelRequest];
}

#pragma mark -
#pragma mark BZFoursquareRequestDelegate

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request {
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, error);
    self.meta = request.meta;
    self.notifications = request.notifications;
    self.response = request.response;
    self.request = nil;
    [self updateView];
}

#pragma mark -
#pragma mark BZFoursquareSessionDelegate

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:kAccessTokenRow inSection:kAuthenticationSection];
    NSArray *indexPaths = @[indexPath];
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo {
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
}

#pragma mark -
#pragma mark Anonymous category

- (void)updateView {
}

- (void)cancelRequest {
    if (_request) {
        _request.delegate = nil;
        [_request cancel];
        self.request = nil;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

- (void)prepareForRequest {
    [self cancelRequest];
    self.meta = nil;
    self.notifications = nil;
    self.response = nil;
}

- (void)checkin {
    [self prepareForRequest];
    NSDictionary *parameters = @{@"ll": [NSString stringWithFormat: @"%d,%d", dadosLocalizacao.latitude, dadosLocalizacao.longitude]};
    
    self.request = [_foursquare requestWithPath:@"checkins/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
    [_request start];
    [self updateView];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void) createConnectionThread: (DadosLocalizacao) dadosLocalizacaoArg
{
    NSThread* evtThread = [ [NSThread alloc] initWithTarget:self
                                                   selector:@selector(postFourSquare)
                                                     object:nil ];
    
    dadosLocalizacao = dadosLocalizacaoArg;
    
    [ evtThread start ];
}

- (void) postFourSquare
{
    NXOAuth2AccountStore* store=[NXOAuth2AccountStore sharedStore];
    
    self.foursquare = [[BZFoursquare alloc] initWithClientID:kClientID callbackURL:kCallbackURL];
    self.foursquare.clientSecret = kClientSecret;
    
    if ([self.foursquare isSessionValid]) {
        [self.foursquare startAuthorization];
        
        //Postar Localização no FourSquare
        [self checkin];
    }
    else{
        NSLog(@"Sessão expirada");
    }
    
    NSLog([NSString stringWithFormat: @"%f", dadosLocalizacao.latitude]);
    NSLog([NSString stringWithFormat: @"%f", dadosLocalizacao.longitude]);
}

@end
