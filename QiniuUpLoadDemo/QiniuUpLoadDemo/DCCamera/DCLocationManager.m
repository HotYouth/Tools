//
//  DCLocationManager.m
//  CameraDemo
//
//  Created by 王忠诚 on 2017/5/3.
//  Copyright © 2017年 王忠诚. All rights reserved.
//

#import "DCLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface DCLocationManager ()<CLLocationManagerDelegate>
{
    LocationBlock _successBlock;
    LocationErrorBlock _failureBlock;
}
@property (nonatomic,assign)BOOL canuse;

@property (nonatomic,strong)CLLocationManager *locationManager;

@end

@implementation DCLocationManager

static DCLocationManager *_manager;


+ (instancetype)manager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_manager == nil) {
            _manager = [[self alloc]init];
        }
    });
    return _manager;
}


- (void)startLocationWithSuccess:(LocationBlock)success andFailure:(LocationErrorBlock)failure {
    _successBlock = [success copy];
    _failureBlock = [failure copy];
    _canuse = [self canuseLocation];
    if (_canuse) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 100;
        [_locationManager requestWhenInUseAuthorization];
        [_locationManager startUpdatingLocation];
    }else {
        NSLog(@"定位服务不可用");
    }
}

- (void)stopLocation {
    [_locationManager stopUpdatingLocation];
}

- (BOOL)canuseLocation {
    return [CLLocationManager locationServicesEnabled];
}



#pragma mark - locationManager
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [_locationManager stopUpdatingLocation];
    if ([error code] == kCLErrorDenied){
        //访问被拒绝
        _failureBlock(error);
    }
    if ([error code] == kCLErrorLocationUnknown) {
        //无法获取位置信息
        _failureBlock(error);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [_locationManager stopUpdatingLocation];
    CLLocation *currentLocation = [locations lastObject];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks[0];
            if (placeMark.name.length == 0) {
                NSLog(@"无法获取到当前位置");
                _successBlock(@"无法获取到当前位置");
            }else {
                NSDictionary *addressDictionary = [placeMark addressDictionary];
                NSString *State = addressDictionary[@"State"]; //省
                NSString *City = addressDictionary[@"City"]; //市
                NSString *SubLocality = addressDictionary[@"SubLocality"]; //区
                NSString *SubThoroughfare = addressDictionary[@"SubThoroughfare"]; //具体位置
                NSString *Thoroughfare = addressDictionary[@"Thoroughfare"]; //街道名称
                State = State.length == 0 ? @"" : State;
                City = City.length == 0 ? @"" : City;
                SubLocality = SubLocality.length == 0 ? @"" : SubLocality;
                Thoroughfare = Thoroughfare.length == 0 ? @"" : Thoroughfare;
                SubThoroughfare = SubThoroughfare.length == 0 ? @"" : SubThoroughfare;
                NSString *addressStr = [NSString stringWithFormat:@"%.8f,%.8f&&%@%@%@%@%@",placeMark.location.coordinate.latitude,placeMark.location.coordinate.longitude,State,City,SubLocality,Thoroughfare,SubThoroughfare];
                NSLog(@" %@",addressStr);
                _successBlock(addressStr);
            }
        }else if (error == nil && placemarks.count == 0) {
            NSLog(@"无法获取到当前位置");
            _successBlock(@"无法获取到当前位置");
        }else if (error) {
            NSLog(@"定位失败 %@",error);
            _failureBlock(error);
        }
    }];
}

@end
