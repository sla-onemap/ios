//
//  ViewController.h
//  Maps
//
//  Created by Alan Zhu on 30/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ViewController : UIViewController
{
    AGSMapView * mapView;
    
    AGSWMTSInfo * wmtsInfo;
    
    AGSWMTSLayer * wmtsLayer;
}

@property(strong, nonatomic) IBOutlet AGSMapView * mapView;

@property (strong, nonatomic) AGSWMTSInfo * wmtsInfo;

@property (strong, nonatomic) AGSWMTSLayer * wmtsLayer;

@end

