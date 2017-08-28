//
//  ViewController.m
//  Maps
//
//  Created by Alan Zhu on 4/8/17.
//  Copyright © 2017 Singapore Land Authority. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()
{
    AGSMap * map;
    
    NSArray <AGSWMTSLayerInfo *> * layerInfos;
    
    AGSWMTSLayer * currentBaseMapLayer;
    
    AGSWMTSService * wmtsService;
}

@end

@implementation ViewController
@synthesize mapView = _mapView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.mapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.mapView];
    
    
    map = [[AGSMap alloc] init];
    
    [self.mapView setMap:map];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //NSString * wmtsURL = @"http://sampleserver6.arcgisonline.com/arcgis/rest/services/WorldTimeZones/MapServer/WMTS";
    
    NSString * om2_prod_wmts_url = @"http://mapservices.onemap.sg/wmts";
    
# warning Note: We are shall use the improved WMTS map link for this example. It is currently going through UAT thus we will push it to production soon.
    
    NSString * om2_uat_wmts_url = @"http://mapproxy.onemap.sg/wmts/1.0.0/WMTSCapabilities.xml";
    
    NSURL * url = [NSURL URLWithString:om2_uat_wmts_url];
    
    wmtsService = [[AGSWMTSService alloc] initWithURL:url];
    
    [wmtsService loadWithCompletion:^(NSError * _Nullable error)
    {
        if (error)
        {
            NSLog(@"%@",error.localizedDescription);
        }
        else
        {
            if(wmtsService.serviceInfo)
            {
                layerInfos = [wmtsService.serviceInfo layerInfos];
                
                if(layerInfos && layerInfos.count > 0)
                {
                    AGSWMTSLayerInfo * layerInfo = layerInfos[0];
                    
                    NSLog(@"%@", layerInfo.layerID);
                    
                    currentBaseMapLayer = [AGSWMTSLayer WMTSLayerWithLayerInfo:layerInfo];
                    
                    [currentBaseMapLayer loadWithCompletion:^(NSError * _Nullable error)
                     {
                         [self wmtsLayerLoadCompletion:error];
                     }];
                }
            }
        }
    }];
}

- (void)wmtsLayerLoadCompletion:(NSError *)error
{
    if (error)
    {
        NSLog(@"%@",error.localizedDescription);
    }
    else
    {
        AGSBasemap * basemap = [AGSBasemap basemapWithBaseLayer:currentBaseMapLayer];
        
        [map setBasemap:basemap];
        
        [basemap loadWithCompletion:^(NSError * _Nullable error)
         {
             if (error)
             {
                 NSLog(@"%@",error.localizedDescription);
             }
             else
             {
                 [self.mapView.locationDisplay setShowLocation:YES];
                 
                 [ self.mapView.locationDisplay setAutoPanMode:AGSLocationDisplayAutoPanModeRecenter];
                 
                 [self.mapView.locationDisplay startWithCompletion:^(NSError * _Nullable error) {
                     
                 }];
             }
         }];
    }
}

@end
