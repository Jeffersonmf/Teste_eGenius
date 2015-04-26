#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize coordinate;

- (NSString *)subtitle {
    return nil;
}

- (NSString *)title {
    return nil;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)coord {
    coordinate=coord;
    return self;
}

-(CLLocationCoordinate2D)coord {
    return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
    coordinate = newCoordinate;
}

@end