//
//  ViewController.h
//  Custom-Marker
//
//  Created by Alan Zhu on 17/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import <Mapbox/Mapbox.h>
#import <UIKit/UIKit.h>

#import "MarkerOperationDelegate.h"

@interface ViewController : UIViewController <MGLMapViewDelegate, MarkerOperationDelegate>
{
    MGLMapView * mapView;
}

@property (retain, nonatomic) IBOutlet MGLMapView * mapView;

@end

