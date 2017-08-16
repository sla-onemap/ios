//
//  ViewController.m
//  Maps
//
//  Created by Alan Zhu on 30/11/16.
//  Copyright © 2016 sg.onemap. All rights reserved.
//

#import "ViewController.h"

#define esriWMTSURL @"http://sampleserver6.arcgisonline.com/arcgis/rest/services/WorldTimeZones/MapServer/WMTS"

#define omWMTSURL @"https://mapservices.onemap.sg/wmts"


@interface ViewController () <AGSMapViewLayerDelegate, AGSLayerDelegate, AGSWMTSInfoDelegate>
{
    NSArray * wmtsLayerInfos;
}

@end

@implementation ViewController
@synthesize mapView;
@synthesize wmtsInfo;
@synthesize wmtsLayer;

NSString * defaultMapStyle = @"DEFAULT";

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapView = [[AGSMapView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    mapView.layerDelegate = self;
    
    [self.view addSubview:mapView];
    
    
    wmtsInfo = [[AGSWMTSInfo alloc] initWithURL:[NSURL URLWithString:esriWMTSURL]];
    
    wmtsInfo.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - AGSMapViewLayerDelegate Methods

- (void)mapViewDidLoad:(AGSMapView *)_mapView
{
    NSLog(@"mapViewDidLoad");
    
    [mapView.locationDisplay startDataSource];
}


#pragma mark - AGSLayerDelegate Methods

- (void)layerDidLoad:(AGSLayer *)layer
{
    NSLog(@"layerDidLoad");
}

- (void)layer:(AGSLayer *)layer didInitializeSpatialReferenceStatus:(BOOL)srStatusValid
{
    NSLog(@"didInitializeSpatialReferenceStatus: %@", layer.name);
}

- (void)layer:(AGSLayer *)layer didFailToLoadWithError:(NSError *)error
{
    NSLog(@"Layer Failed To Load: %@", error.localizedDescription);
}


#pragma mark - AGSWMTSInfoDelegate Methods

- (void)wmtsInfoDidLoad:(AGSWMTSInfo *)_wmtsInfo
{
    wmtsLayerInfos = [_wmtsInfo layerInfos];
    
    
    AGSWMTSLayerInfo * layerInfo = [wmtsLayerInfos objectAtIndex:0];
    
    wmtsLayer = [wmtsInfo wmtsLayerWithLayerInfo:layerInfo andSpatialReference:nil];
    
    wmtsLayer.delegate = self;
    
    [mapView addMapLayer:wmtsLayer withName:@"wmts Layer"];
    
    /*
    if(wmtsLayerInfos && wmtsLayerInfos.count > 0)
    {
        
        for(AGSWMTSLayerInfo * layerInfo in wmtsLayerInfos)
        {
            NSString * title = layerInfo.title;
            
            if(title && [title.uppercaseString isEqualToString:defaultMapStyle])
            {
                currentBaseMapLayer = [AGSWMTSLayer
                                       wmtsLayerWithWMTSInfo:wmtsInfo
                                       wmtsLayerInfo:layerInfo
                                       spatialReference:nil];
                
                [currentBaseMapLayer setDelegate:self];
                
                return;
            }
        }
    }
     
    */
}

- (void)wmtsInfo:(AGSWMTSInfo *)wmtsInfo didFailToLoad:(NSError *)error
{
    NSLog(@"WMTS Info Failed To Load: %@", error.localizedDescription);
}


@end
