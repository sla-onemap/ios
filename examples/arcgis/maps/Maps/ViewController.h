//
//  ViewController.h
//  Maps
//
//  Created by Alan Zhu on 30/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

#define esriWMTSURL @"http://sampleserver6.arcgisonline.com/arcgis/rest/services/WorldTimeZones/MapServer/WMTS"

#define omWMTSURL @"https://mapservices.onemap.sg/wmts"


@interface ViewController : UIViewController <AGSMapViewLayerDelegate, AGSLayerDelegate, AGSWMTSInfoDelegate>
{
    AGSMapView * _mapView;
}

@property (strong, nonatomic) IBOutlet AGSMapView *mapView;

//add WMTS properties...
@property (strong, nonatomic) AGSWMTSInfo *wmtsInfo;
@property (strong, nonatomic) AGSWMTSLayer *wmtsLayer;
@end

