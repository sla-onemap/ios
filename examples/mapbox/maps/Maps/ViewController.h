//
//  ViewController.h
//  Maps
//
//  Created by Alan Zhu on 14/10/16.
//  Copyright © 2016 OneMap. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <MGLMapViewDelegate, UITabBarDelegate>
{
    MGLMapView * mapView;
    
    UIButton * gpsButton;
    
    UITabBar * tabBar;
}

@property (retain, nonatomic) IBOutlet MGLMapView * mapView;

@property (retain, nonatomic) IBOutlet UIButton * gpsButton;

@property (retain, nonatomic) IBOutlet UITabBar * tabBar;
    
@end

