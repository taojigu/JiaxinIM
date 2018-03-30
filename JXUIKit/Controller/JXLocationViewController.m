//
//  JXLocationViewController.m
//

#import "JXLocationViewController.h"

#import "JXHUD.h"
#import <MapKit/MapKit.h>

@interface JXAnnotation : NSObject<MKAnnotation>

@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *subtitle;

@end

@implementation JXAnnotation
@end

@interface JXLocationViewController ()<MKMapViewDelegate, CLLocationManagerDelegate> {
    CLLocationManager *_locationManager;
    CLGeocoder *_geocoder;
}
@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic, copy) CLLocation *currentLocation;
@end

@implementation JXLocationViewController

- (instancetype)initWithLoction:(CLLocation *)location {
    self = [super init];
    if (self) {
        self.currentLocation = location;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.locationDescribe;
    if (self.currentLocation) {
        [self setupDefaultLeftButtonItem];
    } else {
        WEAKSELF;
        
        [self setupDefaultLeftButtonItemWithTitle:JXUIString(@"cancel")];
        [self setupRightBarButtonItemWithTitle:JXUIString(@"send")
                                     andAction:^(id sender) {
                                         [weakSelf sendCurrentLocation:sender];
                                     }];
    }

    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    // 用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
    _mapView.userTrackingMode = MKUserTrackingModeFollow;
    _mapView.mapType = MKMapTypeStandard;
    if (!self.currentLocation) {
        _mapView.showsUserLocation = YES;
    } else {
        _mapView.showsUserLocation = NO;
    }
    _mapView.delegate = self;
    _mapView.pitchEnabled = YES;
    _mapView.zoomEnabled = YES;

    if (self.currentLocation) {
        [_mapView setCenterCoordinate:self.currentLocation.coordinate animated:YES];

        MKCoordinateRegion viewRegion =
                MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 2000, 2000);
        MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
        [_mapView setRegion:adjustedRegion animated:YES];

        MKPointAnnotation *ann = [[MKPointAnnotation alloc] init];
        ann.coordinate = _currentLocation.coordinate;
        [ann setSubtitle:self.locationDescribe];
        [_mapView addAnnotation:ann];
    }
    [self.view addSubview:_mapView];

    //请求定位服务
    if (!self.currentLocation) {
        if ([CLLocationManager locationServicesEnabled]) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.delegate = self;
            //兼容iOS8定位
            SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
            if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
                [_locationManager respondsToSelector:requestSelector]) {
                [_locationManager requestWhenInUseAuthorization];
            } else {
                [_locationManager startUpdatingLocation];
            }
            [sJXHUD showMessageWithActivityIndicatorView:JXUIString(@"loading") inView:self.view];
        } else {
            [sJXHUD showMessage:JXUIString(@"app could not access location") duration:1.7];
        }
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _mapView.frame = CGRectMake(0, 0, self.view.jx_width, self.view.jx_height);
}

- (void)sendCurrentLocation:(id)sender {
    if (!self.currentLocation) {
        sJXHUDMes(JXUIString(@"fail to access location"), 1.4);
        return;
    }
    if (self.locationBlock) {
        UIButton *btn = (UIButton *)sender;
        btn.enabled = NO;
        self.locationBlock(self.locationDescribe, self.currentLocation);
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self.navigationController dismissViewControllerAnimated:YES
                                                                     completion:^{
                                                                     }];
                   });
}

#pragma mark -
#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    self.currentLocation = userLocation.location;
    WEAKSELF;
    [_geocoder reverseGeocodeLocation:userLocation.location
                    completionHandler:^(NSArray *placemarks, NSError *error) {
                        CLPlacemark *placemark = [placemarks firstObject];
                        weakSelf.locationDescribe = placemark.name;
                        userLocation.subtitle = placemark.name;
                        [sJXHUD hideHUD];
                        weakSelf.title = [NSString stringWithFormat:@"%@", placemark.name];
                    }];

    /*CLLocationCoordinate2D coordinate = userLocation.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    [_mapView setRegion:region animated:YES];*/
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error {
    sJXHUDMes(JXUIString(@"fail to access location"), 1.4);
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
}

#pragma mark -
#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [_locationManager startUpdatingLocation];
    } else if (status == kCLAuthorizationStatusAuthorized) {
        // iOS 7 will redundantly call this line.
        [_locationManager startUpdatingLocation];
    } else if (status > kCLAuthorizationStatusNotDetermined) {
        [_locationManager startUpdatingLocation];
    }
}

@end
