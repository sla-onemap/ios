//
//  ViewController.m
//  Maps
//
//  Created by Alan Zhu on 4/8/17.
//  Copyright © 2017 Singapore Land Authority. All rights reserved.
//

#import "ViewController.h"
#import <ArcGIS/ArcGIS.h>

@interface ViewController ()
{
    AGSMapView * mapView;
    
    AGSMap * map;
    
    NSArray <AGSWMTSLayerInfo *> * layerInfos;
    
    AGSWMTSLayer * currentBaseMapLayer;
    
    AGSWMTSService * wmtsService;
}

@property (nonatomic, strong) IBOutlet AGSMapView * mapView;

@property (nonatomic, strong) AGSMap * map;

@end

@implementation ViewController
@synthesize mapView;
@synthesize map;

NSString * defaultMapStyle = @"DEFAULT";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    mapView = [[AGSMapView alloc] initWithFrame:self.view.bounds];
    
    map = [[AGSMap alloc] init];
    
    [mapView setMap:map];
    
    [self.view addSubview:mapView];
    
    
    
    NSURL * url = [NSURL URLWithString:@"https://mapservices.onemap.sg/wmts"];
    
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
                    /*
                    for(AGSWMTSLayerInfo * layerInfo in layerInfos)
                    {
                        NSString * title = layerInfo.title;
                        
                        if(title && [title.uppercaseString isEqualToString:defaultMapStyle])
                        {
                            */
                    
                    AGSWMTSLayerInfo * layerInfo = layerInfos [0];
                    
                            currentBaseMapLayer = [AGSWMTSLayer WMTSLayerWithLayerInfo:layerInfo];
                            
                            [currentBaseMapLayer loadWithCompletion:^(NSError * _Nullable error)
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
                                            AGSEnvelope * fullExtent = currentBaseMapLayer.fullExtent;
                                            
                                            [mapView setViewpointGeometry:fullExtent completion:nil];
                                        }
                                    }];
                                }
                            }];
                    /*
                        }
                    }
                    */
                }
            }
        }
    }];
}
@end
