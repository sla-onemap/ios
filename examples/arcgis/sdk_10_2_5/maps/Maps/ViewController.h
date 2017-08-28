//
//  ViewController.h
//  Maps
//
//  Created by Alan Zhu on 30/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@interface ViewController : UIViewController <AGSMapViewLayerDelegate, AGSLayerDelegate, AGSWMTSInfoDelegate>
{
    AGSMapView * _mapView;
}

@property (strong, nonatomic) IBOutlet AGSMapView *mapView;

//add WMTS properties...
@property (strong, nonatomic) AGSWMTSInfo *wmtsInfo;
@property (strong, nonatomic) AGSWMTSLayer *wmtsLayer;
@end

