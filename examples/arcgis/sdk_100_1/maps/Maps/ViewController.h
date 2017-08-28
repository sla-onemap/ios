//
//  ViewController.h
//  Maps
//
//  Created by Alan Zhu on 4/8/17.
//  Copyright © 2017 Singapore Land Authority. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ViewController : UIViewController
{
    AGSMapView * _mapView;
}

@property(retain, nonatomic) IBOutlet AGSMapView * mapView;

@end

